(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(background-color "#002b36")
 '(background-mode dark)
 '(backup-by-copying t)
 '(backup-directory-alist (quote ((".*" . "~/.emacs.d/backup"))))
 '(circe-default-nick "dcouderc")
 '(circe-network-options
   (quote
    (("Freenode" :nickserv-password nickserv-password :nick "dcouderc"))))
 '(clean-buffer-list-delay-general 1)
 '(cursor-color "#839496")
 '(custom-enabled-themes (quote (misterioso)))
 '(custom-safe-themes
   (quote
    ("fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6" "1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" default)))
 '(delete-old-versions t)
 '(ediff-split-window-function (quote split-window-horizontally))
 '(eshell-cmpl-cycle-completions nil)
 '(flycheck-display-errors-delay 0.5)
 '(foreground-color "#839496")
 '(frame-resize-pixelwise t)
 '(global-git-gutter-mode t)
 '(haskell-indentation-ifte-offset 4)
 '(haskell-indentation-layout-offset 4)
 '(haskell-indentation-left-offset 4)
 '(haskell-indentation-show-indentations nil)
 '(haskell-indentation-show-indentations-after-eol nil)
 '(haskell-indentation-where-post-offset 4)
 '(haskell-indentation-where-pre-offset 4)
 '(ido-enable-flex-matching t)
 '(ido-everywhere t)
 '(ido-ignore-files
   (quote
    ("\\`CVS/" "\\`#" "\\`.#" "\\`\\.\\./" "\\`\\./" ".orig$")))
 '(ido-mode (quote both) nil (ido))
 '(indent-tabs-mode nil)
 '(kept-new-versions 10)
 '(menu-bar-mode nil)
 '(midnight-mode t nil (midnight))
 '(package-archives
   (quote
    (("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa" . "http://melpa.milkbox.net/packages/"))))
 '(rich-minority-mode t)
 '(rm-blacklist (quote (" hl-p" " AC" " GitGutter" " MRev" " $")))
 '(safe-local-variable-values
   (quote
    ((project-venv-name . "tina-2.2")
     (project-venv-name . "tina-develop")
     (project-venv-name . "netlink2"))))
 '(scss-compile-at-save nil)
 '(sgml-basic-offset 4)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(vc-make-backup-files t)
 '(version-control t)
 '(web-mode-markup-indent-offset 2))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flymake-warnline ((t (:background "black"))))
 '(git-gutter:added ((t (:foreground "color-40" :weight bold))))
 '(match ((t (:background "magenta"))))
 '(web-mode-html-attr-name-face ((t (:foreground "green")))))

(global-set-key (kbd "M-<up>") '(lambda () (interactive) (scroll-other-window -1)))
(global-set-key (kbd "M-<down>") '(lambda () (interactive) (scroll-other-window 1)))
(global-set-key [f11] 'previous-error)
(global-set-key [f12] 'next-error)

(global-set-key [M-left] 'windmove-left)
(global-set-key [M-right] 'windmove-right)
(global-set-key [M-up] 'windmove-up)
(global-set-key [M-down] 'windmove-down)

(autoload 'my-python-setup "~/.emacs.d/python-setup.el")
(add-hook 'python-mode-hook 'my-python-setup)
(add-hook 'erlang-mode-hook 'my-erlang-setup)

(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

(setq web-mode-engines-alist '(("django"    . "\\.html\\'")))

(add-hook 'web-mode-hook (lambda () (add-to-list 'write-file-functions 'delete-trailing-whitespace)))

(defun my-flymake-show-help ()
  (when (get-char-property (point) 'flymake-overlay)
    (let ((help (get-char-property (point) 'help-echo)))
      (if help (message "%s" help)))))

(when (load "flymake" t)
  (defun flymake-erlang-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name temp-file
                                           (file-name-directory buffer-file-name))))
      (list "~/.emacs.d/eerlc" (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks '("\\.erl\\'" flymake-erlang-init)))

(defun my-erlang-setup ()
  (add-to-list 'write-file-functions 'delete-trailing-whitespace)
  (add-hook 'post-command-hook 'my-flymake-show-help)
  (auto-complete-mode))

(defun nickserv-password (_)
  (with-temp-buffer
    (insert-file-contents-literally "~/.emacs.d/circe.pass")
    (plist-get (read (buffer-string)) :nickserv-password)))

(global-set-key [(f9)] 'compile)
(global-set-key [(f1)] 'man)

(require 'auto-complete-config)
(ac-config-default)

(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)

(load "lui-logging" nil t)
(enable-lui-logging-globally)
