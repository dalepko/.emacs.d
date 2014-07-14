(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(backup-by-copying t)
 '(backup-directory-alist (quote ((".*" . "~/.emacs.d/backup"))))
 '(custom-enabled-themes (quote (solarized-light)))
 '(custom-safe-themes (quote ("1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" default)))
 '(delete-old-versions t)
 '(ediff-split-window-function (quote split-window-horizontally))
 '(global-git-gutter-mode t)
 '(ido-enable-flex-matching t)
 '(ido-everywhere t)
 '(ido-mode (quote both) nil (ido))
 '(indent-tabs-mode nil)
 '(menu-bar-mode nil)
 '(package-archives (quote (("gnu" . "http://elpa.gnu.org/packages/") ("melpa" . "http://melpa.milkbox.net/packages/"))))
 '(safe-local-variable-values (quote ((project-venv-name . "tina-develop") (project-venv-name . "netlink2"))))
 '(scss-compile-at-save nil)
 '(sgml-basic-offset 4)
 '(show-paren-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flymake-errline ((t (:background "white"))))
 '(flymake-warnline ((t (:background "white"))))
 '(git-gutter:added ((t (:foreground "color-40" :weight bold))))
 '(match ((t (:background "magenta")))))

(global-set-key (kbd "M-<up>") '(lambda () (interactive) (scroll-other-window -1)))
(global-set-key (kbd "M-<down>") '(lambda () (interactive) (scroll-other-window 1)))
(global-set-key [f11] 'previous-error)
(global-set-key [f12] 'next-error)

(autoload 'my-python-setup "~/.emacs.d/python-setup.el")
(add-hook 'python-mode-hook 'my-python-setup)

(require 'auto-complete-config)
(ac-config-default)
