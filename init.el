(if (file-exists-p "~/.cask/cask.el")
    (require 'cask "~/.cask/cask.el"))

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
 '(clean-buffer-list-delay-general 1)
 '(cursor-color "#839496")
 '(custom-enabled-themes (quote (misterioso)))
 '(custom-safe-themes
   (quote
    ("8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "f3d6a49e3f4491373028eda655231ec371d79d6d2a628f08d5aa38739340540b" "b571f92c9bfaf4a28cb64ae4b4cdbda95241cd62cf07d942be44dc8f46c491f4" "66132890ee1f884b4f8e901f0c61c5ed078809626a547dbefbb201f900d03fd8" "3632cf223c62cb7da121be0ed641a2243f7ec0130178722554e613c9ab3131de" "7e83d0aacca4c0e4e9441f920a66ee4de73decc1bb9dd7fcc2c1857948e604c8" "a444b2e10bedc64e4c7f312a737271f9a2f2542c67caa13b04d525196562bf38" "e8a9dfa28c7c3ae126152210e3ccc3707eedae55bdc4b6d3e1bb3a85dfb4e670" "de8fa309eed1effea412533ca5d68ed33770bdf570dcaa458ec21eab219821fd" "8abee8a14e028101f90a2d314f1b03bed1cde7fd3f1eb945ada6ffc15b1d7d65" "9cb6358979981949d1ae9da907a5d38fb6cde1776e8956a1db150925f2dad6c1" "5999e12c8070b9090a2a1bbcd02ec28906e150bb2cdce5ace4f965c76cf30476" "3a9249d4c34f75776e130efd7e02c4a0a7c90ad7723b50acc5806112394ec2dd" "fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6" "1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" default)))
 '(delete-old-versions t)
 '(ediff-split-window-function (quote split-window-horizontally))
 '(eldoc-idle-delay 0.4)
 '(eshell-cmpl-cycle-completions nil)
 '(fci-rule-color "#383838")
 '(flycheck-display-errors-delay 0.5)
 '(flycheck-eslintrc "~/.emacs.d/eslint/.eslintrc.js")
 '(flycheck-javascript-eslint-executable "~/.emacs.d/eslint/node_modules/.bin/eslint")
 '(flycheck-python-pylint-executable "~/.emacs.d/epylint")
 '(flycheck-typescript-tslint-executable "/opt/node/bin/tslint")
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
 '(helm-boring-buffer-regexp-list
   (quote
    ("\\` " "\\`\\*helm" "\\`\\*Echo Area" "\\`\\*Minibuf" "\\`\\*")))
 '(helm-buffer-details-flag nil)
 '(helm-ls-git-show-abs-or-relative (quote relative))
 '(helm-mode-fuzzy-match t)
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
 '(js-indent-level 2)
 '(kept-new-versions 10)
 '(menu-bar-mode nil)
 '(midnight-mode t nil (midnight))
 '(overseer-command "~/.cask/bin/cask exec ert-runner")
 '(projectile-mode t nil (projectile))
 '(projectile-mode-line
   (quote
    (:eval
     (if
         (file-remote-p default-directory)
         " Projectile"
       (format " [%s]"
               (projectile-project-name))))))
 '(projectile-use-git-grep t)
 '(rich-minority-mode t)
 '(rm-blacklist
   (quote
    (" hl-p" " AC" " GitGutter" " Ind" " MRev" " Interactive" " $" " ARev" " company" " tide" " ElDoc")))
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
 '(web-mode-code-indent-offset 2)
 '(web-mode-css-indent-offset 2)
 '(web-mode-enable-auto-indentation nil)
 '(web-mode-markup-indent-offset 2)
 '(web-mode-script-padding 0)
 '(web-mode-style-padding 0))

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

(global-set-key (kbd "ESC <left>") 'windmove-left)
(global-set-key (kbd "ESC <right>") 'windmove-right)
(global-set-key (kbd "ESC <up>") 'windmove-up)
(global-set-key (kbd "ESC <down>") 'windmove-down)

(global-set-key [M-left] 'windmove-left)
(global-set-key [M-right] 'windmove-right)
(global-set-key [M-up] 'windmove-up)
(global-set-key [M-down] 'windmove-down)


(global-set-key [(f9)] 'compile)
(global-set-key [(f1)] 'man)

(put 'erase-buffer 'disabled nil)
(put 'downcase-region 'disabled nil)


(autoload 'my-python-setup "~/.emacs.d/python-setup.el")
(add-hook 'python-mode-hook 'my-python-setup)
(add-hook 'erlang-mode-hook 'my-erlang-setup)

(defun my-erlang-setup ()
  (add-to-list 'write-file-functions 'delete-trailing-whitespace)
  (auto-complete-mode))


;;--[web-mode]----------------------------------------------------------

(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.vue\\'" . web-mode))

(setq web-mode-engines-alist '(("django"    . "\\.html\\'")))

(add-hook 'web-mode-hook
          (lambda ()
            (company-mode)
            (flycheck-mode)
            (add-to-list 'write-file-functions 'delete-trailing-whitespace)))

(eval-after-load 'flycheck
  '(flycheck-add-mode 'javascript-eslint 'web-mode))


;;--[helm/projectile]----------------------------------------------------

(require 'helm-config)
(global-set-key [(control o)] 'helm-projectile)
(global-set-key [f3] 'helm-projectile-grep)


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



(setq exec-path (append exec-path '("~/.local/bin" "/opt/node/bin")))
(setenv "PATH" (concat (getenv "PATH") ":/opt/node/bin"))

;;--[ert]--------------------------------------------------------------------

(defvar last-ert-test nil)


(defun rerun-ert ()
  (interactive)
  (save-buffer)
  (load-file (buffer-file-name))
  (ert last-ert-test))

(defun run-ert (selector)
  (interactive
   (list (let ((default (if ert--selector-history
                            ;; Can't use `first' here as this form is
                            ;; not compiled, and `first' is not
                            ;; defined without cl.
                            (car ert--selector-history)
                          "t")))
           (read
            (completing-read (if (null default)
                                 "Run tests: "
                               (format "Run tests (default %s): " default))
                             obarray #'ert-test-boundp nil nil
                             'ert--selector-history default nil)))
         ))
  (setq last-ert-test selector)
  (rerun-ert))

(define-key emacs-lisp-mode-map [(f9)] 'rerun-ert)
(define-key emacs-lisp-mode-map [(shift f9)] 'run-ert)


;;--[typescript-mode setup]-----------------------------------------------

(defun setup-tide-mode ()
  (require 'ansi-color)
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (eldoc-mode +1)
  (add-hook 'before-save-hook 'tide-format-before-save nil t)
  (define-key typescript-mode-map [(f9)] 'run-jasmine)
  (company-mode +1))

(add-hook 'typescript-mode-hook #'setup-tide-mode)

(define-compilation-mode jasmine-compilation-mode "Jasmine"
  "Jasmine compilation mode."
  (progn
    (set (make-local-variable 'compilation-error-regexp-alist)
         '(("(\\([^:)]*\\):\\([0-9]*\\):\\([0-9]*\\))" 1 2 3)))
    (add-hook 'compilation-filter-hook
              (lambda ()
                (toggle-read-only)
                (ansi-color-apply-on-region compilation-filter-start (point))
                (toggle-read-only))
              nil t)
    ))

(defun run-jasmine ()
  (interactive)
  (let* ((root tide-project-root)
         (eljasmine (expand-file-name "~/.emacs.d/eljasmine/src/main.js"))
         (node (locate-file tide-node-executable exec-path exec-suffixes 1))
         (compilation-environment '(concat "NODE_PATH=" root "node_modules"))
         (command (concat (shell-quote-argument node)
                          " "
                          (shell-quote-argument eljasmine)))
         (default-directory root))
    (compile command 'jasmine-compilation-mode)))
