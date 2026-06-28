;;; acp-git.el --- Git worktree snapshot helper -*- lexical-binding: t; -*-

(defun acp-git-snapshot-create ()
  "Create a git snapshot of the current working directory state.

Copies the Git index to a temporary file, stages all changes
against the temporary index, and uses `git stash create' to
produce a commit object representing the current worktree state.

Returns a commit hash string for the snapshot.  If there are no
changes in the worktree, returns the hash of HEAD instead."
  (let ((git-dir (locate-dominating-file default-directory ".git")))
    (unless git-dir
      (error "acp-git-snapshot: not inside a Git repository"))
    (let* ((index-file (expand-file-name ".git/index" git-dir))
           (temp-index (make-temp-file "acp-git-index-"))
           (default-directory git-dir)
           (process-environment
            (cons (format "GIT_INDEX_FILE=%s" temp-index)
                  process-environment))
           commit-hash)
      (copy-file index-file temp-index t)
      (unwind-protect
          (progn
            (call-process "git" nil nil nil "add" "--all")
            (setq commit-hash (string-trim (with-output-to-string
                                             (with-current-buffer standard-output
                                               (call-process "git" nil t nil "stash" "create")))))
            (if (string-empty-p commit-hash)
                (string-trim (with-output-to-string
                               (with-current-buffer standard-output
                                 (call-process "git" nil t nil "rev-parse" "HEAD"))))
              commit-hash))
        (delete-file temp-index)))))

(defun acp-git-diff (from-commit to-commit)
  "Return the unified diff between FROM-COMMIT and TO-COMMIT."
  (let* ((git-dir (or (locate-dominating-file default-directory ".git")
                      default-directory))
         (default-directory git-dir))
    (with-temp-buffer
      (call-process "git" nil t nil "diff" "--unified" from-commit to-commit)
      (buffer-string))))

(provide 'acp-git)
;;; acp-git.el ends here
