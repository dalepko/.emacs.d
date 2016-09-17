(require 'cask "~/.cask/cask.el")
(cask-initialize)

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
    ("8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "f3d6a49e3f4491373028eda655231ec371d79d6d2a628f08d5aa38739340540b" "b571f92c9bfaf4a28cb64ae4b4cdbda95241cd62cf07d942be44dc8f46c491f4" "66132890ee1f884b4f8e901f0c61c5ed078809626a547dbefbb201f900d03fd8" "3632cf223c62cb7da121be0ed641a2243f7ec0130178722554e613c9ab3131de" "7e83d0aacca4c0e4e9441f920a66ee4de73decc1bb9dd7fcc2c1857948e604c8" "a444b2e10bedc64e4c7f312a737271f9a2f2542c67caa13b04d525196562bf38" "e8a9dfa28c7c3ae126152210e3ccc3707eedae55bdc4b6d3e1bb3a85dfb4e670" "de8fa309eed1effea412533ca5d68ed33770bdf570dcaa458ec21eab219821fd" "8abee8a14e028101f90a2d314f1b03bed1cde7fd3f1eb945ada6ffc15b1d7d65" "9cb6358979981949d1ae9da907a5d38fb6cde1776e8956a1db150925f2dad6c1" "5999e12c8070b9090a2a1bbcd02ec28906e150bb2cdce5ace4f965c76cf30476" "3a9249d4c34f75776e130efd7e02c4a0a7c90ad7723b50acc5806112394ec2dd" "fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6" "1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" default)))
 '(delete-old-versions t)
 '(ediff-split-window-function (quote split-window-horizontally))
 '(eshell-cmpl-cycle-completions nil)
 '(fci-rule-color "#383838")
 '(flycheck-display-errors-delay 0.5)
 '(flycheck-python-pylint-executable "~/.emacs.d/epylint")
 '(foreground-color "#839496")
 '(frame-resize-pixelwise t)
 '(global-git-gutter-mode t)
 '(haskell-ask-also-kill-buffers nil)
 '(haskell-indentation-show-indentations nil)
 '(haskell-indentation-show-indentations-after-eol nil)
 '(haskell-process-args-stack-ghci
   (quote
    ("--ghc-options=-ferror-spans" "--with-ghc=/home/david/.local/bin/ghci-ng")))
 '(haskell-stylish-on-save t)
 '(haskell-tags-on-save t)
 '(help-at-pt-display-when-idle (quote (haskell-msg)) nil (help-at-pt))
 '(help-at-pt-timer-delay 0.5)
 '(ido-enable-flex-matching t)
 '(ido-everywhere t)
 '(ido-ignore-files
   (quote
    ("\\`CVS/" "\\`#" "\\`.#" "\\`\\.\\./" "\\`\\./" "\\.orig$" "\\.bak$")))
 '(ido-mode (quote both) nil (ido))
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(kept-new-versions 10)
 '(menu-bar-mode nil)
 '(midnight-mode t nil (midnight))
 '(rich-minority-mode t)
 '(rm-blacklist
   (quote
    (" hl-p" " AC" " GitGutter" " Ind" " MRev" " Interactive" " $")))
 '(safe-local-variable-values
   (quote
    ((project-venv-name . "tina")
     (project-venv-name . "tina-2.2")
     (project-venv-name . "tina-develop")
     (project-venv-name . "netlink2"))))
 '(scroll-bar-mode nil)
 '(scss-compile-at-save nil)
 '(sgml-basic-offset 4)
 '(shell-file-name "/bin/bash")
 '(shell-pop-universal-key "C-p")
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
 '(default ((t (:family "Liberation Mono"))))
 '(cursor ((t (:background "dark gray"))))
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


(defun my-erlang-setup ()
  (add-to-list 'write-file-functions 'delete-trailing-whitespace)
  (auto-complete-mode))

(defun nickserv-password (_)
  (with-temp-buffer
    (insert-file-contents-literally "~/.emacs.d/circe.pass")
    (plist-get (read (buffer-string)) :nickserv-password)))

(global-set-key [(f9)] 'compile)
(global-set-key [(f1)] 'man)

;;--[haskell-mode configuration]------------------------------------------

(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-hook 'haskell-mode-hook
          (lambda ()
            (require 'company)
            (set (make-local-variable 'company-backends)
                 (append '((company-capf company-dabbrev-code))
                         company-backends))
            (company-mode)))

(add-hook 'interactive-haskell-mode-hook
          (lambda ()
            (define-key interactive-haskell-mode-map (kbd "M-.") 'haskell-mode-goto-loc)
            (define-key interactive-haskell-mode-map (kbd "C-c C-t") 'haskell-mode-show-type-at)
            (define-key interactive-haskell-mode-map [(shift f9)] 'hspec-run)
            (define-key interactive-haskell-mode-map [(f9)] 'hspec-rerun)))

(autoload 'hspec-run "~/.emacs.d/hspec.el")
(autoload 'hspec-rerun "~/.emacs.d/hspec.el")

(add-hook 'interactive-haskell-mode-hook
          (lambda ()
            (define-key interactive-haskell-mode-map [(shift f9)] 'hspec-run)
            (define-key interactive-haskell-mode-map [(f9)] 'hspec-rerun)))


;;------------------------------------------------------------------------

(setq exec-path (append exec-path '("~/.local/bin")))

(put 'erase-buffer 'disabled nil)
(put 'downcase-region 'disabled nil)
