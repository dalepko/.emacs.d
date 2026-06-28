;;; acp-changes-summary-widget.el --- Changes summary widget for ACP REPL  -*- lexical-binding: t; -*-
(require 'compat)
(require 'wid-edit)
(require 'acp-diff)
(require 'seq)

(defface acp-changes-summary-added-face
  `((t :foreground "#6dff6b"))
  "Face for number of added lines."
  :group 'acp)

(defface acp-changes-summary-removed-face
  `((t :foreground "coral"))
  "Face for number of removed lines."
  :group 'acp)

(defvar acp-changes-summary-keymap
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map widget-keymap)
    (define-key map (kbd "TAB") #'acp-changes-summary-toggle-diff)
    (define-key map (kbd "RET") #'acp-changes-summary-open-file)
    map)
  "Keymap for changes summary rows.  TAB toggles the diff display.
RET opens the file at the first hunk position.")

(define-widget 'acp-changes-summary-widget 'item
  "A diff summary widget displaying filename and added/removed line counts.

The value is a list of plists, each with :filename, :added, :removed,
and :diff keys.  TAB on a file row toggles the diff display."
  :format "%v"
  :value-create #'acp-changes-summary-widget--value-create
  :value-delete #'acp-changes-summary-widget--value-delete)

(defun acp-changes-summary-widget--value-create (widget)
  (let ((overlays nil))
    (insert (propertize "\n" 'face '(:underline t :extend t)))
    (dolist (entry (widget-get widget :value))
      (let* ((added (plist-get entry :added))
             (removed (plist-get entry :removed))
             (row-start (point)))
        (insert (propertize "modified  " 'face '(:weight bold)))
        (insert (propertize (plist-get entry :filename) 'face '(:weight bold)))
        (insert (propertize " " 'display '(space :align-to (- right 11))))
        (when (> added 0)
          (insert (propertize (format "+%d" added) 'face 'acp-changes-summary-added-face))
          (insert " "))
        (when (> removed 0)
          (insert (propertize (format "-%d" removed) 'face 'acp-changes-summary-removed-face)))
        (insert "\n")
        (let ((overlay (make-overlay row-start (point) nil t nil)))
          (overlay-put overlay 'keymap acp-changes-summary-keymap)
          (overlay-put overlay 'acp-changes-summary-entry entry)
          (push overlay overlays))))
    (widget-put widget :overlays overlays)))

(defun acp-changes-summary-widget--value-delete (widget)
  (widget-children-value-delete widget)
  (dolist (overlay (widget-get widget :overlays))
    (delete-overlay overlay)))

(defun acp-changes-summary-toggle-diff ()
  "Toggle display of the diff for the file entry at point."
  (interactive)
  (save-excursion
    (let* ((inhibit-read-only t)
           (overlay (acp-changes-summary--overlay-at-point))
           (entry (overlay-get overlay 'acp-changes-summary-entry))
           (is-expanded (overlay-get overlay 'acp-changes-summary-expanded)))
      (goto-char (overlay-start overlay))
      (forward-line 1)
      (if is-expanded
          (delete-region (point) (overlay-end overlay))
        (insert (acp-diff-format (plist-get entry :diff))))
      (move-overlay overlay (overlay-start overlay) (point))
      (overlay-put overlay 'acp-changes-summary-expanded (not is-expanded)))))

(defun acp-changes-summary-open-file ()
  "Open the file for the summary entry at point.
Navigate to the line of the first hunk header in the diff."
  (interactive)
  (let ((position (acp-changes-summary--resolve-diff-position)))
    (find-file-other-window (car position))
    (when (cadr position)
      (goto-char (point-min))
      (forward-line (1- (cadr position))))))

(defun acp-changes-summary--resolve-diff-position ()
  (let* ((overlay (acp-changes-summary--overlay-at-point))
         (entry (overlay-get overlay 'acp-changes-summary-entry))
         (filename (plist-get entry :filename))
         (cursor-position (point))
         (diff-start (save-excursion
                       (goto-char (overlay-start overlay))
                       (forward-line 1)
                       (point)))
         (file-offset 0))
    (if (< cursor-position diff-start)
        (list filename nil)
      (save-excursion
        (beginning-of-line)

        (while (and (not (looking-at "@@ -[0-9,]+,?[0-9]* \\+\\([0-9]+\\)"))
                    (>= (point) diff-start))
          (when (memq (char-after) '(?+ ?\ ))
            (setq file-offset (1+ file-offset)))
          
          (forward-line -1))

        (if (< (point) diff-start)
            (error "hunk header not found")))
      
      (when (> file-offset 0)
        (setq file-offset (1- file-offset)))

      (list filename (+ (string-to-number (match-string 1)) file-offset)))))

(defun acp-changes-summary--overlay-at-point ()
  (seq-some
   (lambda (o) (and (overlay-get o 'acp-changes-summary-entry) o))
   (overlays-at (point))))

(provide 'acp-changes-summary-widget)
;;; acp-changes-summary-widget.el ends here
