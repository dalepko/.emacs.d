;;; python-venv.el --- Virtualenv management for Python -*- lexical-binding: t -*-
(require 'python)

;; (defconst python-venv--mode-line-indicator '(:eval (python-venv--get-name)))

(defun python-venv--scripts-dir (venv-root)
  "Return the scripts directory within VENV-ROOT."
  (concat venv-root (if (eq system-type 'windows-nt) "/Scripts" "/bin")))

(defun python-venv--get-file-contents (filename)
  "Read a file and return its contents as a string."
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-string)))

;;;###autoload
(defun python-venv-activate ()
  "Activate the project's virtualenv or pyenv."
  (interactive)
  (let* ((venv-root (locate-dominating-file "." ".venv"))
         (pyenv-root (locate-dominating-file "." ".python-version"))
         (old-venv (getenv "VIRTUAL_ENV"))
         (new-venv (cond
                    (venv-root (concat venv-root ".venv"))
                    (pyenv-root (let* ((pyenv-version-file (concat pyenv-root ".python-version"))
                                       (target-pyenv (string-trim (python-venv--get-file-contents pyenv-version-file))))
                                  (require 'pyenv-mode)
                                  (pyenv-mode-full-path target-pyenv)))))
         (new-venv (and new-venv (expand-file-name new-venv))))
    (when (and new-venv (not (equal new-venv old-venv)))
      (if (and old-venv (equal (car exec-path) (python-venv--scripts-dir old-venv)))
          (setq exec-path (cdr exec-path)))
      (setenv "VIRTUAL_ENV" new-venv)
      (setq exec-path (cons (python-venv--scripts-dir new-venv) exec-path))
      (setenv "PATH" (mapconcat 'identity exec-path ":")))))

;; (defun python-venv--get-name ()
;;   (when (eq major-mode #'python-ts-mode)
;;     (when-let ((venv (getenv "VIRTUAL_ENV"))
;;                (venv-name (file-name-nondirectory venv)))
;;       (format "[%s]" venv-name))))

;;;###autoload
(defun python-venv-setup ()
  "Set up virtualenv support for the current Python buffer."
  ;; (unless (eq (car mode-line-format) python-venv--mode-line-indicator)
  ;;   (setq mode-line-format (cons python-venv--mode-line-indicator mode-line-format)))
  (python-venv-activate))

(provide 'python-venv)
;;; python-venv.el ends here
