
(when (load "which-func")
  (setq pytest-last-file nil)
  (setq pytest-last-func nil)

  (defun run-pytest (verbose filename func)
    (let ((command  (format "cd %s && py.test%s -v"
                            (file-name-directory filename)
                            (if verbose " -s" ""))))
      (if func
          (let ((node_id (concat (file-name-nondirectory filename)
                                 "::"
                                 (mapconcat 'identity (split-string func "\\.") " "))))
            (setq command (concat command " " node_id)))
        (setq command (concat command " " (file-name-nondirectory filename))))

      (setq pytest-last-file filename)
      (setq pytest-last-func func)
      (compilation-start command t '(lambda (mode) "*py.test*"))))

  (defun pytest (&optional verbose)
    (interactive "P")
    (run-pytest verbose buffer-file-name (which-function)))

  (defun pytest-again (&optional verbose)
    (interactive "P")
    (if pytest-last-file
        (run-pytest verbose pytest-last-file pytest-last-func)
      (run-pytest verbose buffer-file-name (which-function))))

  (define-key python-mode-map [(shift f10)] 'pytest)
  (define-key python-mode-map [(f10)] 'pytest-again))


(when (load "flymake" t)
  (setq epylint "~/.emacs.d/epylint")
  (setq epylint-filename nil)
  (make-variable-buffer-local 'epylint-run)

  (defun flymake-pylint-init ()
    (interactive)
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
		       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))

      (if (not epylint-filename)
	  (add-hook 'kill-buffer-hook
		    '(lambda ()
		       (call-process epylint nil nil nil "--kill" epylint-filename)))
	(if (not (string= local-file epylint-filename))
	    (call-process epylint nil nil nil "--kill" epylint-filename)))

      (setq epylint-filename local-file)
      (list epylint (list local-file))))

  (add-to-list 'flymake-allowed-file-name-masks
	       '("\\.py\\'" flymake-pylint-init)))


(defun my-flymake-show-help ()
  (when (get-char-property (point) 'flymake-overlay)
    (let ((help (get-char-property (point) 'help-echo)))
      (if help (message "%s" help)))))


(setq venv-indicator '(:exec venv-current-name))

(eq venv-indicator venv-indicator)

(defun my-python-setup ()
  (require 'virtualenvwrapper)
  (if (not (eq (car mode-line-format) venv-indicator))
      (setq mode-line-format (cons venv-indicator mode-line-format)))
  (car mode-line-format)
  (hack-local-variables)
  (define-key python-mode-map (kbd "RET") 'newline-and-indent)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace)
  (add-hook 'post-command-hook 'my-flymake-show-help)
  (when (boundp 'project-venv-name)
    (venv-workon project-venv-name))
  (jedi:setup)
  (flymake-mode t))
