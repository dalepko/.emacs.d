(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)


;;--[defaults]--------------------------------------------------

;; Force UTF-8 as the default coding system
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq-default buffer-file-coding-system 'utf-8-unix)

(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

(put 'erase-buffer 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

(global-set-key [f9] #'compile)
(global-set-key [f1] #'helm-apropos)

(use-package treesit
  :init
  (setq treesit-language-source-alist
        '((bash "https://github.com/tree-sitter/tree-sitter-bash" "v0.23.1")
          (javascript "https://github.com/tree-sitter/tree-sitter-javascript"
                      "master"
                      "src")
          (json "https://github.com/tree-sitter/tree-sitter-json")
          (markdown "https://github.com/tree-sitter-grammars/tree-sitter-markdown"
                    "split_parser"
                    "tree-sitter-markdown/src")
          (markdown-inline "https://github.com/tree-sitter-grammars/tree-sitter-markdown"
                           "split_parser"
                           "tree-sitter-markdown-inline/src")
          (python "https://github.com/tree-sitter/tree-sitter-python")
          (rust "https://github.com/tree-sitter/tree-sitter-rust")
          (toml "https://github.com/tree-sitter/tree-sitter-toml")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript"
               "master"
               "tsx/src")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                      "master"
                      "typescript/src")
          (yaml "https://github.com/ikatyang/tree-sitter-yaml")))
  (setq major-mode-remap-alist
        '((bash-mode . bash-ts-mode)
          (javascript-mode . js-ts-mode)
          (json-mode . json-ts-mode)
          (markdown-mode . markdown-ts-mode)
          (python-mode . python-ts-mode)
          (rust-mode . rust-ts-mode)
          (toml-mode . toml-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (yaml-mode . yaml-ts-mode))))

;;--[UI]--------------------------------------------------------

(use-package smart-mode-line
  :ensure t
  :config
  (sml/setup))

(use-package rich-minority
  :ensure t
  :config
  (rich-minority-mode 1)
  :custom
  (rm-blacklist (mapconcat 'identity
                           '(" AC" " Ind" " MRev" " Interactive" " $"
                             " ARev" " ElDoc" " Guide" " Projectile"
                             " WK" " yas"
                             " Projectile\\[[^]]*\\]" " Apheleia")
                           "\\\\|"))
  (rm-text-properties
   '(("\\` Ovwrt\\'" 'face 'font-lock-warning-face)
     ("\\` FlyC:" 'face 'font-lock-warning-face))))

(use-package diff-hl
  :ensure t
  :after magit
  :config
  (global-diff-hl-mode 1)
  :custom
  (diff-hl-draw-borders nil)
  :custom-face
  (diff-hl-change ((t (:background "steel blue" :foreground "blue3"))))
  (diff-hl-delete ((t (:inherit magit-diff-removed-highlight))))
  (diff-hl-insert ((t (:inherit magit-diff-added-highlight)))))

(use-package eldoc
  :bind ("M-h" . eldoc)
  :custom
  (eldoc-display-functions '(eldoc-display-in-buffer))
  (eldoc-idle-delay 0.4)
  :config
  (global-eldoc-mode 1))

(use-package helpful
  :ensure t
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key))
  :custom
  (helm-describe-function-function #'helpful-callable)
  (helm-describe-variable-function #'helpful-variable))

;;--[completion]------------------------------------------------

(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)           ; Enable auto-completion
  (corfu-auto-delay 0.1)   ; Super fast popup delay
  (corfu-auto-prefix 2))   ; Start completing after 2 characters

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))
        orderless-component-separator " +\\|[-/]"))

(when (fboundp 'helm-M-x)
  (global-set-key (kbd "M-x") 'helm-M-x))

(when (require 'helm nil 'noerror)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-x b") 'helm-buffers-list)
  (global-set-key [(control o)] 'helm-projectile)
  (global-set-key [(control f)] 'helm-imenu)
  (global-set-key [f3] 'helm-projectile-grep)
  (add-hook 'helm-minibuffer-set-up-hook #'helm-hide-minibuffer-maybe))

;;--[editing]---------------------------------------------------

(use-package windmove
  :config
  (windmove-default-keybindings 'meta))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C-*" . mc/mark-next-like-this)
         ("C-ù" . mc/mark-previous-like-this)
         ("C-c *" . mc/mark-all-like-this)
         :map mc/keymap
         ("<return>" . nil)))

;;--[code quality]----------------------------------------------

(use-package flycheck
  :ensure t
  :bind (:map flycheck-mode-map ("C-c ! l" . helm-flycheck))
  :hook ((web-mode . flycheck-mode)
         (vue-web-mode . flycheck-mode)
         (python-ts-mode . flycheck-mode)
         (js-ts-mode . flycheck-mode)
         (typescript-ts-mode . flycheck-mode)
         (ansible-mode . flycheck-mode))
  :custom
  (flycheck-javascript-eslint-executable "eslint_d")
  :config
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-add-mode 'javascript-eslint 'vue-web-mode)
  (flycheck-define-checker flycheck-ansible-lint
    "An Ansible playbook syntax checker using ansible-lint."
    :command ("ansible-lint" "--profile=production" "--strict" "--nocolor" "--parseable" source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line (optional ":" column) ": " (message) ". (warning)" line-end)
     (error line-start (file-name) ":" line (optional ":" column) ": " (message) line-end))
    :modes (yaml-ts-mode yaml-mode)))

(use-package apheleia
  :ensure t
  :config
  (setf (alist-get 'python-ts-mode apheleia-mode-alist)
        '(ruff-isort ruff))
  (setf (alist-get 'eslint_d apheleia-formatters)
        '("eslint_d" "--fix-to-stdout" "--stdin" "--stdin-filename" filepath))
  (setf (alist-get 'vue-web-mode apheleia-mode-alist)
        '(eslint_d))
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist)
        '(eslint_d))
  (setf (alist-get 'js-ts-mode apheleia-mode-alist)
        '(eslint_d))
  (apheleia-global-mode +1))

;;--[LSP]-------------------------------------------------------

(use-package eglot
  :ensure nil
  :custom
  (eglot-ignored-server-capabilities
   '(:documentFormattingProvider :documentRangeFormattingProvider :documentOnTypeFormattingProvider))
  :config
  (setq eglot-stay-out-of '(flymake))
  (defun projet-root-for-node (orig-fun &rest args)
    (locate-dominating-file default-directory "package.json"))

  (defun overload-projet-root-for-node (orig-fun modes &rest args)
    (if (not (cl-some (lambda (x) (member x '(vue-web-mode typescript-ts-mode js-ts-mode))) modes))
        (apply orig-fun modes args)
      (advice-add 'project-root :around #'projet-root-for-node)
      (apply orig-fun modes args)
      (advice-remove 'project-root #'projet-root-for-node)))

  (defun typescript-eglot-init-options (&rest _)
    (let ((vue-typescript-plugin-path (shell-command-to-string "npm list -g --parseable @vue/typescript-plugin 2>/dev/null")))
      `(:plugins [(:name "@vue/typescript-plugin"
                         :location ,(string-trim vue-typescript-plugin-path)
                         :languages ["javascript", "typescript", "vue"])])))

  ;; disable this slow function
  (cl-defun jsonrpc--log-event (connection origin
                                           &key _kind message
                                           foreign-message log-text json
                                           type ((:id ref-id))
                                           &allow-other-keys))

  (add-to-list 'eglot-server-programs
               `((vue-web-mode :language-id "vue") . ("typescript-language-server" "--stdio" :initializationOptions ,#'typescript-eglot-init-options)))
  (add-to-list 'eglot-server-programs
               `(((js-ts-mode js-mode) :language-id "javascript") . ("typescript-language-server" "--stdio" :initializationOptions ,#'typescript-eglot-init-options)))
  (add-to-list 'eglot-server-programs
               `((typescript-ts-mode :language-id "typescript") . ("typescript-language-server" "--stdio" :initializationOptions ,#'typescript-eglot-init-options)))
  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) .
                 ("rust-analyzer" :initializationOptions (:check (:command "clippy")))))
  (add-to-list 'eglot-server-programs '(((python-ts-mode python-mode)) . ("ty" "server")))

  (advice-add 'eglot--connect :around #'overload-projet-root-for-node)

  :hook
  ((js-ts-mode . eglot-ensure)
   (tsx-ts-mode . eglot-ensure)
   (vue-web-mode . eglot-ensure)
   (rust-ts-mode . eglot-ensure)
   (python-ts-mode . eglot-ensure)
   (typescript-ts-mode . eglot-ensure)))

(use-package flycheck-eglot
  :ensure t
  :after (flycheck eglot)
  :custom
  (flycheck-eglot-exclusive nil)
  :hook
  (eglot-managed-mode . (lambda ()
                          (when (member major-mode '(vue-web-mode js-ts-mode typescript-ts-mode tsx-ts-mode))
                            (flycheck-eglot-mode 1)))))

;;--[languages]-------------------------------------------------

(use-package python
  :config
  ;; prevent pdbpp from replacing the pdb module which breaks realgud
  (let* ((python_path (getenv "PYTHONPATH"))
         (python_path_suffix (if python_path (concat ":" python_path) "")))
    (if (null (cl-search "_pdbpp_path_hack" python_path_suffix))
        (setenv "PYTHONPATH" (concat "_pdbpp_path_hack" python_path_suffix)))))

(use-package pytest
  :load-path "~/.emacs.d/lisp"
  :after python
  :commands (pytest pytest-again)
  :bind (:map python-ts-mode-map
              ([shift f9] . pytest)
              ([f9] . pytest-again)))

(use-package python-venv
  :load-path "~/.emacs.d/lisp"
  :hook ((python-ts-mode . python-venv-setup)))

(use-package realgud
  :ensure t
  :defer t
  :bind (:map realgud-track-mode-map
              ([M-right])
              ([M-up])
              ([M-down])
              :map realgud:shortkey-mode-map
              ([M-up])
              ([M-down]))
  :config
  (defun realgud-fix-check-prompt (from to &optional cmd-mark opt-cmdbuf
                                        shortkey-on-tracing? no-warn-if-no-match?)
    (string-match (concat comint-prompt-regexp "$")
                  (buffer-substring-no-properties from to)))

  (advice-add #'realgud:track-from-region :before-while #'realgud-fix-check-prompt))

(use-package typescript-ts-mode
  :hook (typescript-ts-mode . (lambda () (setq-local tab-width 2))))

(use-package js
  :hook (js-ts-mode . (lambda () (setq-local tab-width 2))))

(use-package web-mode
  :ensure t
  :mode (("\\.html?\\'" . web-mode)
         ("\\.vue\\'" . vue-web-mode))
  :custom
  (web-mode-code-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-enable-auto-indentation nil)
  (web-mode-enable-current-element-highlight t)
  (web-mode-markup-indent-offset 2)
  (web-mode-script-padding 0)
  (web-mode-style-padding 0)
  (web-mode-engines-alist '(("django" . "\\.html\\'")))
  (web-mode-indentation-params
   '(("lineup-args"       . ())
     ("lineup-calls"      . ())
     ("lineup-concats"    . t)
     ("lineup-quotes"     . t)
     ("lineup-ternary"    . t)
     ("case-extra-offset" . t)))
  :custom-face
  (web-mode-function-call-face ((t nil)))
  :config
  (define-derived-mode vue-web-mode web-mode "Vue Web" "Vue Mode"
    (setq tab-width 2)))

(use-package rust-mode
  :ensure t
  :bind (:map rust-ts-mode-map ([f9] . rust-test)))

(use-package haskell-mode
  :ensure t
  :custom
  (haskell-ask-also-kill-buffers nil)
  (haskell-indentation-show-indentations nil)
  (haskell-indentation-show-indentations-after-eol nil)
  (haskell-stylish-on-save t)
  (haskell-tags-on-save t)
  :hook
  (haskell-mode . interactive-haskell-mode)
  (interactive-haskell-mode . (lambda ()
                                (define-key interactive-haskell-mode-map (kbd "M-.") 'haskell-mode-goto-loc)
                                (define-key interactive-haskell-mode-map (kbd "C-c C-t") 'haskell-mode-show-type-at))))

(use-package hspec
  :load-path "~/.emacs.d/lisp"
  :bind (:map interactive-haskell-mode-map
              ("<S-f9>" . hspec-run)
              ("<f9>" . hspec-rerun)))

(use-package yaml-mode
  :ensure t
  :init
  (defun is-ansible-file ()
    (when buffer-file-name
      (let ((root (locate-dominating-file buffer-file-name ".git")))
        (when root
          (string= (file-name-nondirectory (directory-file-name root))
                   "architecture")))))
  :hook (yaml-ts-mode . (lambda () (if (is-ansible-file) (ansible-mode 1)))))

(use-package ansible
  :ensure t
  :hook (ansible-mode . (lambda ()
                          (python-venv-activate)
                          (flycheck-select-checker 'flycheck-ansible-lint))))

(use-package terraform-mode
  :ensure t
  :hook (terraform-mode . terraform-format-on-save-mode))

(use-package fish-mode
  :ensure t
  :hook (fish-mode . (lambda () (setq tab-width 4))))

;;--[tools]-----------------------------------------------------

(use-package magit
  :ensure t
  :bind (([f12] . #'magit-status)))

(use-package acp
  :load-path "~/.emacs.d/acp"
  :bind (("C-c t" . #'acp)))

;;--[utils]-----------------------------------------------------

(defun toggle-camelcase-underscores ()
  "Toggle between camelcase and underscore notation for the symbol at point."
  (interactive)
  (save-excursion
    (let* ((bounds (bounds-of-thing-at-point 'symbol))
           (start (car bounds))
           (end (cdr bounds))
           (currently-using-underscores-p (progn (goto-char start)
                                                 (re-search-forward "_" end t))))
      (if currently-using-underscores-p
          (progn
            (upcase-initials-region start end)
            (replace-string "_" "" nil start end)
            (downcase-region start (1+ start)))
        (replace-regexp "\\([A-Z]\\)" "_\\1" nil (1+ start) end)
        (downcase-region start (cdr (bounds-of-thing-at-point 'symbol)))))))

;;--[environment]-----------------------------------------------

(setenv "LANG" "fr_FR.UTF-8")

(when (string-equal system-type "darwin")
  (setenv "LIBRARY_PATH" "/opt/homebrew/Cellar/gcc/16.1.0/lib/gcc/current/gcc/aarch64-apple-darwin25/16/")
  (setq mac-command-modifier 'super)
  (setq mac-right-option-modifier 'ns-right-alternate-modifier)
  (setq mac-option-modifier 'meta)
  (global-set-key (kbd "s-v") #'yank)
  (global-set-key (kbd "s-c") #'kill-ring-save))

(when (eq system-type 'windows-nt)
  (add-to-list 'exec-path "C:/Program Files/zig/")
  (add-to-list 'exec-path "C:/Program Files/Git/usr/bin")
  (add-to-list 'exec-path "C:/Program Files/GnuPG/bin/"))

(add-to-list 'exec-path (expand-file-name "~/.local/bin"))
(add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))
(add-to-list 'exec-path "/opt/node/bin")
(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path "/opt/homebrew/bin/")
(add-to-list 'exec-path (expand-file-name "~/.nvm/versions/node/v22.15.1/bin/"))
(add-to-list 'exec-path (expand-file-name "~/.pyenv/shims"))
(setenv "PATH" (concat
                "/opt/node/bin:/usr/local/bin"
                ":"
                (expand-file-name "~/.cargo/bin")
                ":"
                (expand-file-name "~/.nvm/versions/node/v22.15.1/bin/")
                ":"
                (expand-file-name "~/.pyenv/shims")
                ":"
                "/opt/homebrew/bin/"
                ":"
                (getenv "PATH")))

(if (member (system-name) '("MacBookPro.lan" "Deepki-DDFDGDTYW4.local" "Mac.lan"))
    (let ((netskope-ca (expand-file-name "~/.nskp-cert/netskope-cert-bundle.pem")))
      (load-library "gnutls")
      (setenv "CURL_CA_BUNDLE" netskope-ca)
      (setenv "REQUESTS_CA_BUNDLE" netskope-ca)
      (setenv "SSL_CERT_FILE" netskope-ca)
      (setenv "NODE_EXTRA_CA_CERTS" netskope-ca)
      (setenv "AWS_PROFILE" "ssoAppTesting")
      (cl-pushnew netskope-ca gnutls-trustfiles :test #'equal)))


(let ((creds-file (expand-file-name "~/.config/creds.fish")))
  (when (file-exists-p creds-file)
    (with-temp-buffer
      (insert-file-contents creds-file)
      (while (not (eobp))
        (let ((line (buffer-substring-no-properties
                     (line-beginning-position)
                     (line-end-position))))
          (when (string-match "^set  *-gx  *\\([A-Z0-9_]*\\)  *\\([^ ].*[^ ]\\) *$" line)
            (let ((name (match-string 1 line))
                  (value (substitute-env-vars (match-string 2 line))))
              (setenv name value)
              (message "Set env var %s from creds file" name))))
        (forward-line 1)))))

;; installed node packages (npm -g list):
;; ├── @agentclientprotocol/claude-agent-acp@0.25.3
;; ├── @vue/typescript-plugin@2.2.8
;; ├── corepack@0.34.5
;; ├── eslint_d@15.0.2
;; ├── npm@10.9.2
;; ├── typescript-language-server@4.3.4
;; └── typescript@5.8.3
