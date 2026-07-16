;;; acp-diff.el --- Unified diff generation for file edits  -*- lexical-binding: t; -*-
(require 'diff)
(require 'magit-diff)

(defface acp-diff-hunk-heading-face
  '((t :inherit magit-diff-hunk-heading-highlight :extend t))
  "Face for diff hunk headings"
  :group 'acp)

(defface acp-diff-context-face
  '((t :inherit magit-diff-context-highlight :extend t))
  "Face for diff context lines"
  :group 'acp)

(defface acp-diff-added-face
  '((t :inherit magit-diff-added-highlight :extend t))
  "Face for diff added lines"
  :group 'acp)

(defface acp-diff-removed-face
  '((t :inherit magit-diff-removed-highlight :extend t))
  "Face for diff removed lines"
  :group 'acp)

(defun acp-diff-create (base-file old-text new-text)
  "Create a unified diff between BASE-FILE and BASE-FILE with OLD-TEXT
replaced by NEW-TEXT.

If BASE-FILE does not exist, treat it as empty.
If OLD-TEXT is nil, insert NEW-TEXT (new file creation).
Signal an error if OLD-TEXT is non-nil and cannot be found in the content.

Returns the unified diff string produced by `diff-no-select'."
  (with-temp-buffer
    (condition-case _
        (insert-file-contents base-file)
      (file-missing (setq base-file "/dev/null")))

    (cond
     ((null old-text)
      (goto-char (point-max))
      (insert new-text))
     ((search-forward old-text nil t)
      (replace-match new-text t t))
     (t (error "acp-diff: old-text not found in %s" base-file)))

    (let ((target-file (make-temp-file (file-name-nondirectory base-file) nil nil (buffer-string))))
      (unwind-protect
          (acp-diff-cleanup-diff
           (with-output-to-string
             (let ((exit-code
                    (call-process diff-command nil standard-output nil "--unified" base-file target-file)))
               (unless (or (= exit-code 0) (= exit-code 1))
                 (error "diff failed")))))
        (delete-file target-file)))))

(defun acp-diff-cleanup-diff (diff)
  "Remove all lines before the first hunk header in DIFF."
  (save-match-data
    (if (string-match "\\`\\(?:.\\|\n\\)*\\(@@ \\)" diff)
        (substring diff (match-beginning 1))
      (error "invalid diff content"))))

(defun acp-diff-create-and-format (base-file old-text new-text)
  "Create and format a unified diff in one step.
Calls `acp-diff-create' then `acp-diff-format' on the result."
  (acp-diff-format (acp-diff-create base-file old-text new-text)))

(defun acp-diff-format (diff)
  (let* ((lines (string-lines diff nil t))
         (formatted-lines (mapcar (lambda (line)
                                    (if-let ((face (pcase line
                                                     ((pred (string-prefix-p " ")) 'acp-diff-context-face)
                                                     ((pred (string-prefix-p "+")) 'acp-diff-added-face)
                                                     ((pred (string-prefix-p "-")) 'acp-diff-removed-face)
                                                     (_ nil))))
                                        (propertize line 'face face)
                                      (if (string-prefix-p "@@" line)
                                          (propertize line 'face 'acp-diff-hunk-heading-face)
                                        line)))
                                  lines)))
    (apply #'concat formatted-lines)))

(defun acp-diff-parse (patch)
  "Parse PATCH (a unified diff string) into a list of per-file plists.

Each plist contains:
  :filename — the file path from the +++ line
  :added    — number of added lines (lines starting with +)
  :removed  — number of removed lines (lines starting with -)
  :diff     — the full diff text for that file (including hunk headers)

Returns nil when PATCH is empty or nil."
  (when (and patch (not (string-empty-p patch)))
    (unless (string-suffix-p "\n" patch)
      (setq patch (concat patch "\n")))
    (let ((lines (string-lines patch nil t))
          (results nil)
          (current-diff nil)
          (current-added 0)
          (current-removed 0)
          (current-file nil))
      (dolist (line lines)
        (cond
         ;; Start of a new file section
         ((string-match "\\`diff --git" line)
          (when current-file
            (push (list :filename current-file
                        :added current-added
                        :removed current-removed
                        :diff (string-join (nreverse current-diff) ""))
                  results))
          (setq current-diff nil
                current-added 0
                current-removed 0
                current-file nil))
         ;; Extract filename from "+++ b/<path>"
         ((string-match "\\`\\+\\+\\+ \\(?:[ab]\\)?/?" line)
          (setq current-file (string-trim (substring line (match-end 0)))))
         ;; Accumulate diff lines after we've seen the file header
         (t
          (when current-file
            (push line current-diff)
            (cond ((string-prefix-p "+" line) (setq current-added (1+ current-added)))
                  ((string-prefix-p "-" line) (setq current-removed (1+ current-removed))))))))
      (when current-file
        (push (list :filename current-file
                    :added current-added
                    :removed current-removed
                    :diff (string-join (nreverse current-diff) ""))
              results))
      (nreverse results))))

(provide 'acp-diff)
;;; acp-diff.el ends here
