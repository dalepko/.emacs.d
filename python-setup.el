;;; -*- lexical-binding: t -*-
(require 'eldoc-box)
(require 'company)
(require 'realgud)
(require 'python)
(require 'which-func)
(require 'gud)
(require 'subr-x)
(require 'pythonic)
(require 'eglot)
(require 'cl-lib)
(require 'flycheck)
(require 'reformatter)

(defvar pytest-last-file nil)
(defvar pytest-last-func nil)

(defconst CHECK_PYTHON_SYNTAX_SCRIPT
  (concat (file-name-directory (or load-file-name (buffer-file-name))) "check_python_syntax.py"))

(reformatter-define ruff-format-imports
  :program "ruff"
  :args (list "check" "--select" "I" "--fix" "--stdin-filename" (or (buffer-file-name) input-file))
  :lighter " RuffFmtImports"
  :group 'ruff-format-imports)

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

;; to prevent pdbpp from replacing the pdb module which breaks realgud
(let* ((python_path (getenv "PYTHONPATH"))
       (python_path_suffix (if python_path (concat ":" python_path) "")))
  (if (null (cl-search "_pdbpp_path_hack" python_path_suffix))
      (setenv "PYTHONPATH" (concat "_pdbpp_path_hack" python_path_suffix))))


(define-minor-mode pytest-error-minor-mode
  "Highlight errors in pytest buffer"
  :lighter " Pytest"
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
  (let* ((project-root (projectile-project-root))
         (command  (format "py.test%s --tb=short -vvs"
                           (if verbose " --pdb" "")))
         (last-pdb-buffer (find-last-pdb-buffer))
         (last-pdb-window (if last-pdb-buffer (get-buffer-window last-pdb-buffer))))
    (cleanup-pdb-buffers)
    (if func
        (let ((node_id (concat filename
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
            (let ((default-directory project-root))
              (realgud:pdb command)))
        (select-window last-pdb-window)
        (let ((default-directory project-root))
          (realgud:pdb command)))
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
  (flycheck-mode t)
  (eldoc-box-hover-mode t)
  (ruff-format-imports-on-save-mode t)
  (format-all-mode t)
  (eglot-ensure)
  (company-mode t)
  (add-to-list 'flycheck-checkers 'python-ruff))


(defun pyenv ()
  (interactive)
  (pyenv-mode t)
  (call-interactively 'pyenv-mode-set))


(defun activate-pyenv ()
  (pyenv-mode t)
  (let* ((root (locate-dominating-file "." ".python-version"))
         (current-pyenv (and python-shell-virtualenv-root (file-name-nondirectory python-shell-virtualenv-root))))
    (if root
        (let* ((pyenv-version-file (concat root ".python-version"))
               (target-pyenv (string-trim (get-file-contents pyenv-version-file))))
          (if (not (string-equal target-pyenv current-pyenv))
              (progn
                (setq python-shell-extra-pythonpaths `(,root))
                (pyenv-mode-set target-pyenv)))))))


;; fix bug in realgud always reselecting the command window
(defun realgud-fix-check-prompt (from to &optional cmd-mark opt-cmdbuf
				      shortkey-on-tracing? no-warn-if-no-match?)
  (string-match (concat comint-prompt-regexp "$")
                (buffer-substring-no-properties from to)))

(advice-add #'realgud:track-from-region :before-while  #'realgud-fix-check-prompt)


(defun pyenv-folder (workspace)
  (list (expand-file-name "~/.pyenv")))



(flycheck-define-checker python-ruff
  "A Python syntax and style checker using the ruff utility.
To override the path to the ruff executable, set
`flycheck-python-ruff-executable'.
See URL `http://pypi.python.org/pypi/ruff'."
  :command ("ruff"
            "check"
            (eval (when buffer-file-name
                    (concat "--stdin-filename=" buffer-file-name)))
            "-")
  :standard-input t
  :error-filter (lambda (errors)
                  (let ((errors (flycheck-sanitize-errors errors)))
                    (seq-map #'flycheck-flake8-fix-error-level errors)))
  :error-patterns
  ((warning line-start
            (file-name) ":" line ":" (optional column ":") " "
            (id (one-or-more (any alpha)) (one-or-more digit)) " "
            (message (one-or-more not-newline))
            line-end))
  :modes python-mode
  :next-checkers ((warning . python-pylint)
                  (warning . python-mypy))
  )
