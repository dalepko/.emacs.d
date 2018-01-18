;;; -*- lexical-binding: t -*-

(require 'company)
(require 'company-jedi)
(require 'gud)
(require 'python)
(require 'which-func)
(require 'gud)

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
;(define-key realgud-track-mode-map [M-right] 'windmove-right)

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
   (remove-if-not
    (lambda (buffer) (with-current-buffer buffer pdb-tracker))
    (buffer-list))))


(defun run-pytest (verbose filename func)

  (let ((command  (format "py.test%s --tb=short -vs"
                          ;;(file-name-directory filename)
                          (if verbose " -s --pdb" "")))
        (is-in-pdb pdb-tracker))
    (cleanup-pdb-buffers)
    (if func
        (let ((node_id (concat filename;;(file-name-nondirectory filename)
                               "::"
                               (mapconcat 'identity (split-string func "\\.") "::"))))
          (setq command (concat command " " node_id)))
      (setq command (concat command " " filename)))

    (setq pytest-last-file filename)
    (setq pytest-last-func func)
    (let ((buffer (if is-in-pdb (pdb command)
                    (flet ((switch-to-buffer (buffer) (pop-to-buffer buffer))) (pdb command)))))
      (setq pdb-tracker t)
      (pytest-error-minor-mode))))


(defun pytest (&optional verbose)
  (interactive "P")
  (run-pytest verbose buffer-file-name (which-function)))

(defun pytest-again (&optional verbose)
  (interactive "P")
  (if pytest-last-file
      (run-pytest verbose pytest-last-file pytest-last-func)
    (run-pytest verbose buffer-file-name (which-function))))


(defconst venv-indicator '(:exec venv-current-name))

(defun my-python-setup ()
  (if (not (eq (car mode-line-format) venv-indicator))
      (setq mode-line-format (cons venv-indicator mode-line-format)))

  (add-to-list 'company-backends #'company-jedi)

  (hack-local-variables)
  (define-key python-mode-map [(shift f9)] 'pytest)
  (define-key python-mode-map [(f9)] 'pytest-again)
  (define-key python-mode-map (kbd "RET") 'newline-and-indent)

  (when (boundp 'project-venv-name)
    (venv-workon project-venv-name))
  (company-mode t)
  (jedi:setup)
  (flycheck-mode t)
  (isort-mode))


(defun pyenv ()
  (interactive)
  (add-to-list 'exec-path (expand-file-name "~/.pyenv/bin"))
  (add-to-list 'exec-path (expand-file-name "~/.pyenv/shims"))
  (setenv "PATH" (mapconcat 'identity exec-path path-separator))
  (pyenv-mode t)
  (call-interactively 'pyenv-mode-set))
