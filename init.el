(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;;--[binds]------------------------------------------------------

(global-set-key (kbd "M-<up>") (lambda () (interactive) (scroll-other-window -1)))
(global-set-key (kbd "M-<down>") (lambda () (interactive) (scroll-other-window 1)))
(global-set-key [f12] #'magit-status)
(global-set-key (kbd "M-h") #'eldoc)

(global-set-key (kbd "<home>") #'move-beginning-of-line)
(global-set-key (kbd "<end>") #'move-end-of-line)
(global-set-key (kbd "ESC <left>") #'windmove-left)
(global-set-key (kbd "ESC <right>") #'windmove-right)
(global-set-key (kbd "ESC <up>") #'windmove-up)
(global-set-key (kbd "ESC <down>") #'windmove-down)

(global-set-key [M-left] #'windmove-left)
(global-set-key [M-right] #'windmove-right)
(global-set-key [M-up] #'windmove-up)
(global-set-key [M-down] #'windmove-down)

(global-set-key [(f9)] #'compile)
(global-set-key [(f1)] #'helm-apropos)
;; (global-set-key (kbd "C-s") 'helm-occur)

(put 'erase-buffer 'disabled nil)
(put 'downcase-region 'disabled nil)


(use-package smart-mode-line
  :config
  (sml/setup))

(use-package corfu
  :ensure t
  :init (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 1)
  (corfu-quit-at-boundary 'separtor)
  (corfu-quit-no-match 'separator))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-default nil)
  (orderless-component-separtor "[ -/]"))

;;--[python-mode]------------------------------------------------------

(autoload 'my-python-setup "~/.emacs.d/python-setup.el")
(add-hook 'python-mode-hok #'my-python-setup)
(add-hook 'python-ts-mode-hook #'my-python-setup)
(add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
(add-hook 'fish-mode-hook (lambda () (setq tab-width 4)))

(defun get-file-contents (filename)
  "Read a file and return foo-file as a string."
  (with-temp-buffer
    (insert-file-contents filename)
    (buffer-string)))



(defun activate-venv ()
  (interactive)
  (let* ((venv-root (locate-dominating-file "." ".venv"))
         (pyenv-root (locate-dominating-file "." ".python-version"))
         (old-venv (getenv "VIRTUAL_ENV"))
         (new-venv (cond
                    (venv-root (concat venv-root ".venv"))
                    (pyenv-root (let* ((pyenv-version-file (concat pyenv-root ".python-version"))
                                       (target-pyenv (string-trim (get-file-contents pyenv-version-file))))
                                  (require 'pyenv-mode)
                                  (pyenv-mode-full-path target-pyenv)))))
         (new-venv (and new-venv (expand-file-name new-venv))))
    (when (and new-venv (not (equal new-venv old-venv)))
      (if (and old-venv (equal (car exec-path) (concat old-venv "/bin")))
          (setq exec-path (cdr exec-path)))
      (setenv "VIRTUAL_ENV" new-venv)
      (setq exec-path (cons (concat new-venv "/bin") exec-path))
      (setenv "PATH" (mapconcat 'identity exec-path ":")))))

;;--[web-mode]----------------------------------------------------------


(setq web-mode-engines-alist '(("django" . "\\.html\\'")))

(add-hook 'web-mode-hook
          (lambda ()
            (flycheck-mode)))

(with-eval-after-load 'flycheck
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-add-mode 'javascript-eslint 'vue-web-mode))


(setq web-mode-indentation-params
  '(("lineup-args"       . ())
    ("lineup-calls"      . ())
    ("lineup-concats"    . t)
    ("lineup-quotes"     . t)
    ("lineup-ternary"    . t)
    ("case-extra-offset" . t)
    ))

(define-derived-mode vue-web-mode web-mode "Vue Web" "Vue Mode"
  ;; (eslint-fix-auto-mode)
  (eglot-ensure)
  (setq tab-width 2))


(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.vue\\'" . vue-web-mode))

(add-hook 'js-mode-hook (lambda ()
                          (define-key js-mode-map "\M-." nil)
                          (eglot-ensure)
                          (setq tab-width 2)))

;;--[helm/projectile]----------------------------------------------------

(when (fboundp 'helm-M-x)
  (global-set-key (kbd "M-x") 'helm-M-x))

(when (require 'helm nil 'noerror)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-x b") 'helm-buffers-list)
  (global-set-key (kbd "C-h f") 'helm-apropos)
  (global-set-key [(control o)] 'helm-projectile)
  (global-set-key [(control f)] 'helm-imenu)
  (global-set-key [f3] 'helm-projectile-grep)
  (add-hook 'helm-minibuffer-set-up-hook #'helm-hide-minibuffer-maybe))


;;--[haskell-mode configuration]------------------------------------------

(add-hook 'haskell-mode-hook 'interactive-haskell-mode)

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

;;--[erlang]--------------------------------------------------------------

(add-hook 'erlang-mode-hook #'my-erlang-setup)
(defun my-erlang-setup ()
  (auto-complete-mode))

;;--[typescript-mode setup]-----------------------------------------------

(defun setup-ts-mode ()
  (interactive)
  (eglot-ensure)
  (make-local-variable 'eldoc-display-functions)
  ;; (eslint-fix-auto-mode)
  (setq tab-width 2)
  (setq eldoc-display-functions '(eldoc-display-in-buffer)))

(add-hook 'typescript-ts-mode-hook #'setup-ts-mode)

(when (fboundp 'define-compilation-mode)
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
      )))

(put 'upcase-region 'disabled nil)

(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))

(setenv "LANG" "fr_FR.UTF-8")


;;--[multiple cursor]--------------------------------------------

(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C-*") 'mc/mark-next-like-this)
(global-set-key (kbd "C-ù") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c *") 'mc/mark-all-like-this)
(define-key mc/keymap (kbd "<return>") nil)


;;--[helpful]----------------------------------------------------

(global-set-key (kbd "C-h f") #'helpful-callable)
(global-set-key (kbd "C-h v") #'helpful-variable)
(global-set-key (kbd "C-h k") #'helpful-key)

;;--[git-gutter-fringe]------------------------------------------

(require 'git-gutter-fringe)
(define-fringe-bitmap 'git-gutter-fr:added
  [224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224]
  nil nil 'center)
(define-fringe-bitmap 'git-gutter-fr:modified
  [224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224]
  nil nil 'center)
(define-fringe-bitmap 'git-gutter-fr:deleted
  [0 0 0 0 0 0 0 0 0 0 0 0 0 128 192 224 240 248]
  nil nil 'center)

;;--[emacs-mac]--------------------------------------------

(when (string-equal system-type "darwin")
  ; (toggle-frame-fullscreen))modifier
  (setq mac-command-modifier 'super)
  (setq mac-right-option-modifier 'ns-right-alternate-modifier)
  (setq mac-option-modifier 'meta)
  (global-set-key (kbd "s-v") #'yank)
  (global-set-key (kbd "s-c") #'kill-ring-save))

;;--[rich-minority]----------------------------------------------

(setq rm-regex-list '(" AC" " Ind" " MRev" " Interactive" " $" " Black"
                      " ARev" " tide" " ElDoc" " Guide" " Projectile"
                      " WK" " yas" " import" " Isort"
                      " GitGutter" " Projectile\\[[^]]*\\]" " FmtAll" " RuffFmtImports" " RuffFmt"))
(setq rm-blacklist (mapconcat 'identity rm-regex-list "\\|"))


;;--[flycheck]------------------------------------------

(with-eval-after-load 'flycheck
  (define-key flycheck-mode-map (kbd "C-c ! l") 'helm-flycheck))


;;--{utils]-----------------------------------------------------

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


;;---[eglot]-----------------------------------------------------------

(defun projet-root-for-node (orig-fun &rest args)
  (locate-dominating-file default-directory "package.json"))


(defun overload-projet-root-for-node (orig-fun modes &rest args)
  (if (not (cl-some (lambda (x) (member x '(vue-web-mode js-mode))) modes))
      (apply orig-fun modes args)
    (advice-add 'project-root :around #'projet-root-for-node)
    (apply orig-fun modes args)
    (advice-remove 'project-root #'projet-root-for-node)))

(defun typescript-eglot-init-options ()
  (let ((vue-typescript-plugin-path (shell-command-to-string "npm list --global --parseable @vue/typescript-plugin | head -n1 | tr -d \"\n\"")))
    `(:plugins [(:name "@vue/typescript-plugin"
                 :location ,vue-typescript-plugin-path
                 :languages ["javascript", "typescript", "vue"])])))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `((vue-web-mode :language-id "vue") . ("typescript-language-server" "--stdio" :initializationOptions ,(typescript-eglot-init-options))))
  (add-to-list 'eglot-server-programs
               `((js-mode :language-id "javascript") . ("typescript-language-server" "--stdio" :initializationOptions ,(typescript-eglot-init-options))))
  (add-to-list 'eglot-server-programs
               `((typescript-ts-mode :language-id "typescript") . ("typescript-language-server" "--stdio" :initializationOptions ,(typescript-eglot-init-options))))
  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) .
                 ("rust-analyzer" :initializationOptions (:check (:command "clippy")))))
  ;;(add-to-list 'eglot-server-programs '((python-ts-mode) . ("uvx" "ty" "server" )))

  (setq eglot-stay-out-of '(flymake))
  (require 'flycheck-eglot)
  ;; disable this slow function
  (cl-defun jsonrpc--log-event (connection origin
                                           &key _kind message
                                           foreign-message log-text json
                                           type ((:id ref-id))
                                           &allow-other-keys))
  (advice-add 'eglot--connect :around #'overload-projet-root-for-node))


(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (if (member major-mode '(vue-web-mode js-mode typescript-ts-mode rust-mode))
                (progn
                  (flycheck-eglot-mode t)
                  (format-all-mode t)
                  (setq flycheck-checker 'eglot-check)))))

;;--[rust-mode]--------------------------------------------

(add-hook 'rust-mode-hook (lambda ()
                            (eglot-ensure)
                            (define-key rust-mode-map [(f9)] 'rust-test)))


;;--[terraform]--------------------------------------------

(add-hook 'terraform-mode-hook #'terraform-format-on-save-mode)

;;--[treesitter-sources]------------------------------------

(setq treesit-language-source-alist
      '((bash "https://github.com/tree-sitter/tree-sitter-bash")
        (cmake "https://github.com/uyha/tree-sitter-cmake")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (elisp "https://github.com/Wilfred/tree-sitter-elisp")
        (go "https://github.com/tree-sitter/tree-sitter-go")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (make "https://github.com/alemuller/tree-sitter-make")
        (markdown "https://github.com/ikatyang/tree-sitter-markdown")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (tsx        "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (yaml "https://github.com/ikatyang/tree-sitter-yaml")))


;;--[eldoc]---------------------------------------------

(setq eldoc-display-functions '(eldoc-display-in-buffer))

;;--[format-all]---------------------------------------------

(add-hook 'format-all-mode-hook #'format-all-ensure-formatter)


;;--[agent-shell]---------------------------------------------

(use-package agent-shell
  :defer t
  :autoload agent-shell-anthropic-start-claude-code
  :bind (("C-c a" . #'agent-shell-anthropic-start-claude-code))
  :config
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t)))


;;--[gitlab-duo]---------------------------------------------

;; (autoload 'gitlab-duo-start "~/.emacs.d/gitlab-duo.el" "Start the gitlab DUO chat." t)
;; (global-set-key (kbd "C-c t") #'gitlab-duo-start)


(use-package acp
  :load-path "~/.emacs.d/acp"
  :bind (("C-c t" . #'acp)))

;;--[ansible]---------------------------------------------

(with-eval-after-load 'flycheck
  (flycheck-define-checker flycheck-ansible-lint
    "An Ansible playbook syntax checker using ansible-lint."
    :command ("ansible-lint" "--profile=production" "--strict" "--nocolor" "--parseable" source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line (optional ":" column) ": " (message) ". (warning)" line-end)
     (error line-start (file-name) ":" line (optional ":" column) ": " (message) line-end))
    :modes yaml-mode))


(defun is-ansible-file ()
  (when buffer-file-name
    (let ((root (locate-dominating-file buffer-file-name ".git")))
      (when root
        (string= (file-name-nondirectory (directory-file-name root)) "architecture")))))

(add-hook 'yaml-mode-hook (lambda () (if (is-ansible-file) (ansible-mode 1))))
(add-hook 'ansible-mode-hook
          (lambda ()
            (activate-venv)
            (flycheck-mode)
            (flycheck-select-checker 'flycheck-ansible-lint)))

;;--[paths for external executables]-------------------------
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
;; ├── @vue/typescript-plugin@2.2.8
;; ├── cloc@2.4.0-cloc
;; ├── corepack@0.23.0
;; ├── npm@10.8.2
;; ├── prettier@3.5.3
;; ├── pyright@1.1.398
;; ├── typescript-language-server@4.3.4
;; └── typescript@5.8.3

(put 'dired-find-alternate-file 'disabled nil)
