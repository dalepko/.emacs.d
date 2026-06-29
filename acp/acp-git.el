;;; acp-git.el --- Git worktree snapshot helper -*- lexical-binding: t; -*-

(defun acp-git--run (&rest args)
  "Run git with ARGS and return trimmed stdout."
  (string-trim (with-output-to-string
                 (with-current-buffer standard-output
                   (apply #'call-process "git" nil t nil args)))))

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
    (let* ((default-directory git-dir)
           (index-file (expand-file-name "index" (acp-git--run "rev-parse" "--git-dir")))
           (temp-index (make-temp-file "acp-git-index-"))
           (process-environment
            (cons (format "GIT_INDEX_FILE=%s" temp-index)
                  process-environment))
           commit-hash)
      (copy-file index-file temp-index t)
      (unwind-protect
          (progn
            (acp-git--run "add" "--all")
            (setq commit-hash (acp-git--run "stash" "create"))
            (if (string-empty-p commit-hash)
                (acp-git--run "rev-parse" "HEAD")
              commit-hash))
        (delete-file temp-index)))))

(defun acp-git-diff (from-commit to-commit)
  "Return the unified diff between FROM-COMMIT and TO-COMMIT."
  (let* ((git-dir (or (locate-dominating-file default-directory ".git")
                      default-directory))
         (default-directory git-dir))
    (acp-git--run "diff" "--unified" from-commit to-commit)))

(provide 'acp-git)
;;; acp-git.el ends here
