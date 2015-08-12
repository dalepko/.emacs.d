
(when (load "which-func")
  (setq pytest-last-file nil)
  (setq pytest-last-func nil)

  (defvar pytest-error-minor-mode-map
    (let ((map (make-sparse-keymap)))
      (define-key map [mouse-2] 'compile-goto-error)
      (define-key map [follow-link] 'mouse-face)
      (define-key map "\C-c\C-c" 'compile-goto-error)
      (define-key map "\C-c\C-k" 'kill-compilation)
      (define-key map "\M-n" 'compilation-next-error)
      (define-key map "\M-p" 'compilation-previous-error)
      (define-key map "\M-{" 'compilation-previous-file)
      (define-key map "\M-}" 'compilation-next-file)
      map)
    "Keymap for `pytest-error-minor-mode-map'.")

  (define-minor-mode pytest-error-minor-mode
    "Highlight errors in pytest buffer"
    nil " Pytest"
    :group 'compilation
    (if pytest-error-minor-mode
        (compilation-setup t)
      (compilation--unsetup)))

  (defun undedicate-window (window old-sentinel proc msg)
    (cond ((and (windowp window) (memq (process-status proc) '(signal exit)))
           (set-window-dedicated-p window nil)))
    (funcall old-sentinel proc msg))

  (defun run-pytest (verbose filename func)
    (let ((command  (format "py.test%s -v"
                            ;;(file-name-directory filename)
                            (if verbose " -s --pdb" ""))))
      (if func
          (let ((node_id (concat filename;;(file-name-nondirectory filename)
                                 "::"
                                 (mapconcat 'identity (split-string func "\\.") "::"))))
            (setq command (concat command " " node_id)))
        (setq command (concat command " " (file-name-nondirectory filename))))

      (setq pytest-last-file filename)
      (setq pytest-last-func func)
      (let ((buffer (save-window-excursion
                      (when (and (boundp 'gud-comint-buffer) (buffer-live-p gud-comint-buffer))
                        (set-buffer gud-comint-buffer)
                        (erase-buffer))
                      (pdb command)
                      (setq gud-find-expr-function (lambda () (symbol-name (sexp-at-point))))
                      (pytest-error-minor-mode)
                      (current-buffer))))
        (save-selected-window
          (switch-to-buffer-other-window buffer)
          (let* ((process (get-buffer-process buffer))
                 (old-sentinel (process-sentinel process)))
            (set-window-dedicated-p nil t)
            (set-process-sentinel process
                                  `(lambda (proc msg)
                                     (undedicate-window ,(selected-window)
                                                        (quote ,old-sentinel)
                                                        proc msg)))
            )))))
      ;(compilation-start command t '(lambda (mode) "*py.test*"))))

  (defun pytest (&optional verbose)
    (interactive "P")
    (run-pytest verbose buffer-file-name (which-function)))

  (defun pytest-again (&optional verbose)
    (interactive "P")
    (if pytest-last-file
        (run-pytest verbose pytest-last-file pytest-last-func)
      (run-pytest verbose buffer-file-name (which-function))))

  (define-key python-mode-map [(shift f9)] 'pytest)
  (define-key python-mode-map [(f9)] 'pytest-again))


(when (load "flymake" t)
  (setq epylint "~/.emacs.d/epylint")

  (defun flymake-pylint-init ()
    (interactive)
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
		       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))

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
