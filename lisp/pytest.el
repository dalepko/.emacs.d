;;; pytest.el --- Run pytest from Emacs with pdb integration -*- lexical-binding: t -*-

(require 'realgud)
(require 'python)
(require 'which-func)
(require 'cl-lib)
(require 'project)
(require 'seq)

(defvar pytest--last-file nil)
(defvar pytest--last-func nil)

(defvar-local pytest--pdb-tracker nil)

(defvar pytest--error-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mouse-2] 'compile-goto-error)
    (define-key map [follow-link] 'mouse-face)
    (define-key map "\C-c\C-c" 'compile-goto-error)
    (define-key map "\C-c\C-k" 'kill-compilation)
    (define-key map "\M-{" 'compilation-previous-file)
    (define-key map "\M-}" 'compilation-next-file)
    (define-key map "\M-p" 'comint-previous-input)
    (define-key map "\M-n" 'comint-next-input)
    (define-key map "\M-r" 'comint-previous-matching-input)
    (define-key map "\M-s" 'comint-next-matching-input)
    (define-key map [(shift f9)] 'pytest)
    (define-key map [(f9)] 'pytest-again)
    map)
  "Keymap for `pytest--error-minor-mode'.")

(define-minor-mode pytest--error-minor-mode
  "Highlight errors in pytest buffer"
  :lighter " Pytest"
  :group 'compilation
  (if pytest--error-minor-mode
      (compilation-setup t)
    (compilation--unsetup)))

(defun pytest--cleanup-buffers ()
  (interactive)
  (mapcar
   #'kill-buffer
   (cl-remove-if-not
    (lambda (buffer) (with-current-buffer buffer pytest--pdb-tracker))
    (buffer-list))))

(defun pytest--find-last-pdb-buffer ()
  (seq-find #'get-buffer-window
            (seq-filter (lambda (buffer) (with-current-buffer buffer pytest--pdb-tracker))
                        (buffer-list))))

(defun pytest--run (verbose filename func)
  (let* ((project-root (project-root (project-current t)))
         (pytest-path (or (executable-find "py.test") "py.test"))
         (command  (format "%s%s --tb=short -vvs"
                           pytest-path
                           (if verbose " --pdb" "")))
         (last-pdb-buffer (pytest--find-last-pdb-buffer))
         (last-pdb-window (if last-pdb-buffer (get-buffer-window last-pdb-buffer))))
    (pytest--cleanup-buffers)
    (if func
        (let ((node_id (concat filename
                               "::"
                               (mapconcat 'identity (split-string func "\\.") "::"))))
          (setq command (concat command " " node_id)))
      (setq command (concat command " " filename)))
    (setq pytest--last-file filename)
    (setq pytest--last-func func)
    (save-selected-window
      (if (null last-pdb-window)
          (cl-letf (((symbol-function #'switch-to-buffer)
                     (lambda (buffer) (pop-to-buffer buffer))))
            (let ((default-directory project-root))
              (realgud:pdb command)))
        (select-window last-pdb-window)
        (let ((default-directory project-root))
          (realgud:pdb command)))
      (setq pytest--pdb-tracker t)
      (pytest--error-minor-mode))))

;;;###autoload
(defun pytest (&optional verbose)
  (interactive "P")
  (let* ((func (which-function))
         (func-is-ok (null (cl-search " " func)))
         (func-clean (if func-is-ok func nil)))
    (pytest--run verbose buffer-file-name func-clean)))

;;;###autoload
(defun pytest-again (&optional verbose)
  (interactive "P")
  (if pytest--last-file
      (pytest--run verbose pytest--last-file pytest--last-func)
    (pytest--run verbose buffer-file-name (which-function))))

(provide 'pytest)
;;; pytest.el ends here
