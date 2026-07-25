;;; acp-git.el --- Git worktree snapshot helper -*- lexical-binding: t; -*-

(defmacro acp-git--with-tmp-index (&rest body)
  (declare (indent 0))
  `(let* ((git-dir (expand-file-name (string-trim (acp-git--run "rev-parse" "--git-dir"))))
          (index-file (expand-file-name "index" git-dir))
          (temp-index (make-temp-file "acp-git-index-"))
          (process-environment
           (cons (format "GIT_INDEX_FILE=%s" temp-index)
                 process-environment)))
     (copy-file index-file temp-index t)
     (unwind-protect
         (progn ,@body)
       (delete-file temp-index))))

(defun acp-git-snapshot-create ()
  "Create a git snapshot of the current working directory state.

Copies the Git index to a temporary file, stages all changes
against the temporary index, and uses `git stash create' to
produce a commit object representing the current worktree state.

Returns a commit hash string for the snapshot.  If there are no
changes in the worktree, returns the hash of HEAD instead."
  (acp-git--with-tmp-index
    (acp-git--run "add" "--all")
    (let ((commit-hash (string-trim (acp-git--run "stash" "create"))))
      (if (string-empty-p commit-hash)
          (string-trim (acp-git--run "rev-parse" "HEAD"))
        commit-hash))))

(defun acp-git-diff (from-commit to-commit)
  "Return the unified diff between FROM-COMMIT and TO-COMMIT."
  (acp-git--run "diff" "--unified" from-commit to-commit))

(defun acp-git--run (&rest args)
  "Run git with ARGS and return trimmed stdout."
  (with-output-to-string
    (with-current-buffer standard-output
      (let ((status (apply #'call-process "git" nil t nil args)))
        (when (not (= status 0))
          (error "git command failed: %s" (buffer-substring-no-properties (point-min) (point-max))))))))

(defun acp-git--run-with-input (input &rest args)
  "Run git with ARGS using `input` as starndard input and return trimmed stdout."
  (with-output-to-string
    (with-current-buffer standard-output
      (insert input)
      (let ((status (apply #'call-process-region nil nil "git" t t nil args)))
        (when (not (= status 0))
          (error "git command failed: %s" (buffer-substring-no-properties (point-min) (point-max))))))))

(provide 'acp-git)
;;; acp-git.el ends here
