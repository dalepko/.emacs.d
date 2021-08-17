;;; -*- lexical-binding: t -*-
(require 'company)
(require 'company-jedi)
(require 'realgud)
(require 'python)
(require 'which-func)
(require 'gud)
(require 'subr-x)
(require 'pythonic)
(require 'importmagic)
(require 'py-isort)
(require 'lsp)
(require 'lsp-pyright)
(require 'cl-lib)

(defvar pytest-last-file nil)
(defvar pytest-last-func nil)

(defvar pytest-error-minor-mode-map
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
  "Keymap for `pytest-error-minor-mode-map'.")

;; remove annoying key binding
(define-key realgud-track-mode-map [M-right] 'windmove-right)
(define-key realgud-track-mode-map [M-up] 'windmove-up)
(define-key realgud-track-mode-map [M-down] 'windmove-down)
(define-key realgud:shortkey-mode-map [M-up] 'windmove-up)
(define-key realgud:shortkey-mode-map [M-down] 'windmove-down)


(defvar-local pdb-tracker nil)

(define-minor-mode pytest-error-minor-mode
  "Highlight errors in pytest buffer"
  nil " Pytest"
  :group 'compilation
  (if pytest-error-minor-mode
      (compilation-setup t)
    (compilation--unsetup)))


(defun cleanup-pdb-buffers ()
  (interactive)
  (mapcar
   #'kill-buffer
   (cl-remove-if-not
    (lambda (buffer) (with-current-buffer buffer pdb-tracker))
    (buffer-list))))


(defun find-last-pdb-buffer ()
  (seq-find #'get-buffer-window (seq-filter (lambda (buffer) (with-current-buffer buffer pdb-tracker)) (buffer-list))))


(defun run-pytest (verbose filename func)
  (let* ((command  (format "py.test%s --tb=short -vvs"
                           ;;(file-name-directory filename)
                           (if verbose " --pdb" "")))
         (last-pdb-buffer (find-last-pdb-buffer))
         (last-pdb-window (if last-pdb-buffer (get-buffer-window last-pdb-buffer))))
    (cleanup-pdb-buffers)
    (if func
        (let ((node_id (concat filename;;(file-name-nondirectory filename)
                               "::"
                               (mapconcat 'identity (split-string func "\\.") "::"))))
          (setq command (concat command " " node_id)))
      (setq command (concat command " " filename)))

    (setq pytest-last-file filename)
    (setq pytest-last-func func)
    (save-selected-window
      (if (null last-pdb-window)
          (cl-letf (((symbol-function #'switch-to-buffer)
                     (lambda (buffer) (pop-to-buffer buffer))))
            (realgud:pdb command))
        (select-window last-pdb-window)
        (realgud:pdb command))
      (setq pdb-tracker t)
      (pytest-error-minor-mode))))



(defun pytest (&optional verbose)
  (interactive "P")
  (let* ((func (which-function))
         (func-is-ok (null (cl-search " " func)))
         (func-clean (if func-is-ok func nil)))
    (run-pytest verbose buffer-file-name func-clean)))

(defun pytest-again (&optional verbose)
  (interactive "P")
  (if pytest-last-file
      (run-pytest verbose pytest-last-file pytest-last-func)
    (run-pytest verbose buffer-file-name (which-function))))


(defconst venv-indicator '(:exec venv-current-name))

(defun get-file-contents (filename)
  "Read a file and return foo-file as a string."
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-string)))

(defun my-python-setup ()
  (if (not (eq (car mode-line-format) venv-indicator))
      (setq mode-line-format (cons venv-indicator mode-line-format)))

  (hack-local-variables)
  (define-key python-mode-map [(shift f9)] 'pytest)
  (define-key python-mode-map [(f9)] 'pytest-again)
  (define-key python-mode-map (kbd "RET") 'newline-and-indent)

  (when (boundp 'project-venv-name)
    (venv-workon project-venv-name))
  (activate-pyenv)
  (importmagic-mode t)
  (company-mode t)
  ;; (jedi:setup)
  ;; (setq flycheck-checker 'python-pylint)
  (flycheck-mode t)
  (py-autopep8-enable-on-save)
  (fix-pyright)
  (lsp)
  (add-hook 'before-save-hook 'py-isort-before-save))

(defun py-isort--find-settings-path ()
  (expand-file-name
   (or (locate-dominating-file buffer-file-name ".git")
       (locate-dominating-file buffer-file-name "setup.cfg")
       (locate-dominating-file buffer-file-name "setup.py")
       (file-name-directory buffer-file-name))))

(defun pyenv-init()
  (add-to-list 'exec-path (expand-file-name "~/.pyenv/bin"))
  (add-to-list 'exec-path (expand-file-name "~/.pyenv/shims"))
  (setenv "PATH" (mapconcat 'identity exec-path path-separator))
  (pyenv-mode t))


(defun pyenv ()
  (interactive)
  (pyenv-init)
  (call-interactively 'pyenv-mode-set))


(defun activate-pyenv ()
  (let* ((root (locate-dominating-file "." ".python-version"))
         (current-pyenv (and python-shell-virtualenv-root (file-name-nondirectory python-shell-virtualenv-root))))
    (if root
        (let* ((pyenv-version-file (concat root ".python-version"))
               (target-pyenv (string-trim (get-file-contents pyenv-version-file))))
          (if (not (string-equal target-pyenv current-pyenv))
              (progn
                (pyenv-init)
                (setq python-shell-extra-pythonpaths `(,root))
                (pyenv-mode-set target-pyenv)))))))



;; prevent autopep8 from running on files with syntax errors

(defun autopep8-check-syntax-error (errbuf file)
  (zerop (call-process "python" nil nil nil "-m" "py_compile" file)))

(advice-add #'py-autopep8--call-executable :before-while  #'autopep8-check-syntax-error)


;; fix bug in realgud always reselecting the command window

(defun realgud-fix-check-prompt (from to &optional cmd-mark opt-cmdbuf
				      shortkey-on-tracing? no-warn-if-no-match?)
  (string-match (concat comint-prompt-regexp "$")
                (buffer-substring-no-properties from to)))

(advice-add #'realgud:track-from-region :before-while  #'realgud-fix-check-prompt)


(defun fix-pyright()
  (let ((pyright (gethash 'pyright lsp-clients)))
    (when (not (lsp--client-library-folders-fn pyright))
      (setf (lsp--client-library-folders-fn pyright) #'pyenv-folder))))


(defun pyenv-folder (workspace)
  (list (expand-file-name "~/.pyenv")))
