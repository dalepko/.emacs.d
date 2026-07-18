(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(auto-save-visited-mode t)
 '(background-color "#002b36")
 '(background-mode dark)
 '(backup-by-copying t)
 '(backup-directory-alist '((".*" . "~/.emacs.d/backup")))
 '(before-save-hook '(delete-trailing-whitespace))
 '(clean-buffer-list-delay-general 1)
 '(css-indent-offset 2)
 '(custom-enabled-themes '(gruvbox-dark-medium))
 '(custom-safe-themes
   '("5a0ddbd75929d24f5ef34944d78789c6c3421aa943c15218bac791c199fc897d"
     "1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" default))
 '(delete-old-versions t)
 '(ediff-split-window-function 'split-window-horizontally)
 '(ediff-window-setup-function 'ediff-setup-windows-plain)
 '(eshell-cmpl-cycle-completions nil)
 '(ess-default-style 'DEFAULT)
 '(ess-own-style-list
   '((ess-indent-offset . 2) (ess-offset-arguments . open-delim)
     (ess-offset-arguments-newline . prev-call) (ess-offset-block . prev-line)
     (ess-offset-continued . straight) (ess-align-nested-calls "ifelse")
     (ess-align-arguments-in-calls "function[ \11]*(") (ess-align-continuations-in-calls . t)
     (ess-align-blocks control-flow) (ess-indent-from-lhs arguments fun-decl-opening)
     (ess-indent-from-chain-start . t) (ess-indent-with-fancy-comments . t)))
 '(fci-rule-color "#383838")
 '(fill-column 100)
 '(foreground-color "#839496")
 '(frame-resize-pixelwise t)
 '(help-at-pt-display-when-idle '(haskell-msg) nil (help-at-pt))
 '(help-at-pt-timer-delay 0.5)
 '(history-delete-duplicates t)
 '(importmagic-style-configuration-alist '((multiline . backslashes) (max_columns . 120)))
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(kept-new-versions 10)
 '(menu-bar-mode nil)
 '(native-comp-debug 0)
 '(native-comp-jit-compilation-deny-list '(".*/realgud/.*" ".*/realgud.el"))
 '(ns-≥right-alternate-modifier 'none)
 '(overseer-command "~/.cask/bin/cask exec ert-runner")
 '(package-archives
   '(("melpa" . "https://melpa.org/packages/") ("gnu" . "http://elpa.gnu.org/packages/")))
 '(package-selected-packages
   '(ansible ansible-vault apheleia consult-flycheck corfu diff-hl dockerfile-mode fish-mode
             flycheck-eglot git gruvbox-theme haskell-mode helpful kaolin-themes magit magit-popup
             marginalia markdown-preview-mode multiple-cursors orderless orgtbl-join phi-search
             po-mode pyenv-mode realgud rust-mode shell-pop smart-mode-line terraform-mode vertico
             web-mode yaml-mode yasnippet))
 '(realgud-populate-common-fn-keys-function 'identity)
 '(ring-bell-function 'ignore)
 '(safe-local-variable-values
   '((format-all-formatters ("Python" ruff))
     (flycheck-python-mypy-cache-dir . "/Users/david.couderc/dev/invoice_parsing/.mypy_cache")
     (flycheck-python-mypy-config . "/Users/david.couderc/dev/invoice_parsing/mypy.ini")
     (flycheck-python-mypy-cache-dir . "/Users/david.couderc/dev/telecollecte/.mypy_cache")
     (flycheck-python-mypy-config . "/Users/david.couderc/dev/telecollecte/mypy.ini")))
 '(scroll-bar-mode nil)
 '(scss-compile-at-save nil)
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(vc-make-backup-files t)
 '(version-control t)
 '(visible-bell nil)
 '(which-key-mode t)
 '(yas-global-mode t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flymake-warnline ((t (:background "black"))) t))
