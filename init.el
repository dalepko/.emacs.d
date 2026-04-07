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
 '(company-backends
   '(company-bbdb company-semantic company-cmake company-capf company-clang company-files
                  (company-dabbrev-code company-gtags company-etags company-keywords)
                  company-oddmuse company-dabbrev))
 '(company-box-doc-delay 0.1)
 '(company-idle-delay 0.1)
 '(css-indent-offset 2)
 '(custom-enabled-themes '(gruvbox-dark-medium))
 '(custom-safe-themes
   '("5a0ddbd75929d24f5ef34944d78789c6c3421aa943c15218bac791c199fc897d"
     "1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" default))
 '(delete-old-versions t)
 '(diff-hl-draw-borders nil)
 '(ediff-split-window-function 'split-window-horizontally)
 '(ediff-window-setup-function 'ediff-setup-windows-plain)
 '(eglot-ignored-server-capabilities
   '(:documentFormattingProvider :documentRangeFormattingProvider :documentOnTypeFormattingProvider))
 '(eldoc-idle-delay 0.4)
 '(eshell-cmpl-cycle-completions nil)
 '(eslint-fix-executable "~/.emacs.d/eslint/node_modules/.bin/eslint")
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
 '(flycheck-checkers
   '(ada-gnat asciidoctor asciidoc awk-gawk bazel-build-buildifier bazel-module-buildifier
              bazel-starlark-buildifier bazel-workspace-buildifier c/c++-clang c/c++-gcc
              c/c++-cppcheck cfengine coffee coffee-coffeelint css-csslint css-stylelint cuda-nvcc
              cwl d-dmd dockerfile-hadolint elixir-credo emacs-lisp emacs-lisp-checkdoc
              ember-template erlang-rebar3 erlang eruby-erubis eruby-ruumba fortran-gfortran
              go-gofmt go-vet go-build go-test go-errcheck go-unconvert go-staticcheck groovy haml
              haml-lint handlebars haskell-stack-ghc haskell-ghc haskell-hlint html-tidy
              javascript-eslint javascript-jshint javascript-standard json-jsonlint json-python-json
              json-jq jsonnet less less-stylelint llvm-llc lua-luacheck lua
              markdown-markdownlint-cli markdown-mdl markdown-pymarkdown nix nix-linter opam perl
              perl-perlcritic php php-phpmd php-phpcs php-phpcs-changed processing proselint
              protobuf-protoc protobuf-prototool pug puppet-parser puppet-lint python-flake8
              python-ruff python-pylint python-pycompile python-pyright python-mypy r-lintr r racket
              rpm-rpmlint rst-sphinx rst ruby-rubocop ruby-chef-cookstyle ruby-standard ruby-reek
              ruby ruby-jruby rust-cargo rust rust-clippy scala scala-scalastyle scheme-chicken
              scss-lint sass-stylelint scss-stylelint sass/scss-sass-lint sass scss sh-bash
              sh-posix-dash sh-posix-bash sh-zsh sh-shellcheck slim slim-lint sql-sqlint statix
              systemd-analyze tcl-nagelfar terraform terraform-tflint tex-chktex tex-lacheck texinfo
              textlint typescript-tslint verilog-verilator vhdl-ghdl xml-xmlstarlet xml-xmllint
              yaml-actionlint yaml-jsyaml yaml-ruby yaml-yamllint eglot-check))
 '(flycheck-disabled-checkers '(python-pylint))
 '(flycheck-display-errors-delay 0.1)
 '(flycheck-eglot-exclusive nil)
 '(flycheck-flake8rc ".flake8")
 '(flycheck-javascript-eslint-executable "~/.emacs.d/eslint/node\12_modules/.bin/eslint")
 '(flycheck-posframe-prefix "\15 ➤ ")
 '(flycheck-python-pylint-executable "~/.emacs.d/epylint")
 '(foreground-color "#839496")
 '(format-all-default-formatters
   '(("Assembly" asmfmt) ("ATS" atsfmt) ("Bazel" buildifier) ("BibTeX" emacs-bibtex) ("C" clang-format)
     ("C#" csharpier) ("C++" clang-format) ("Cabal Config" cabal-fmt) ("Clojure" zprint)
     ("CMake" cmake-format) ("Crystal" crystal) ("CSS" prettier) ("Cuda" clang-format) ("D" dfmt)
     ("Dart" dart-format) ("Dhall" dhall) ("Dockerfile" dockfmt) ("Elixir" mix-format)
     ("Elm" elm-format) ("Emacs Lisp" emacs-lisp) ("Erlang" efmt) ("F#" fantomas)
     ("Fish" fish-indent) ("Fortran Free Form" fprettify) ("GLSL" clang-format) ("Go" gofmt)
     ("GraphQL" prettier) ("Haskell" brittany) ("HCL" hclfmt) ("HTML" html-tidy)
     ("HTML+EEX" mix-format) ("HTML+ERB" erb-format) ("Hy" emacs-hy) ("Java" clang-format)
     ("JavaScript" prettier) ("JSON" prettier) ("JSON5" prettier) ("Jsonnet" jsonnetfmt)
     ("JSX" prettier) ("Kotlin" ktlint) ("LaTeX" latexindent) ("Less" prettier)
     ("Literate Haskell" brittany) ("Lua" lua-fmt) ("Markdown" prettier) ("Meson" muon-fmt)
     ("Nix" nixpkgs-fmt) ("Objective-C" clang-format) ("OCaml" ocp-indent) ("Perl" perltidy)
     ("PHP" prettier) ("Protocol Buffer" clang-format) ("PureScript" purty) ("Python" ruff)
     ("R" styler) ("Reason" bsrefmt) ("ReScript" rescript) ("Ruby" rufo) ("Rust" rustfmt)
     ("Scala" scalafmt) ("SCSS" prettier) ("Shell" shfmt) ("Solidity" prettier) ("SQL" sqlformat)
     ("Svelte" prettier) ("Swift" swiftformat) ("Terraform" terraform-fmt) ("TOML" prettier)
     ("TSX" prettier) ("TypeScript" prettier) ("V" v-fmt) ("Verilog" istyle-verilog)
     ("Vue" prettier) ("XML" html-tidy) ("YAML" prettier) ("Zig" zig) ("_Angular" prettier)
     ("_Beancount" bean-format) ("_Caddyfile" caddy-fmt) ("_Flow" prettier) ("_Gleam" gleam)
     ("_Ledger" ledger-mode) ("_Nginx" nginxfmt) ("_Snakemake" snakefmt)))
 '(format-all-show-errors 'never)
 '(frame-resize-pixelwise t)
 '(git-gutter:update-interval 1)
 '(global-company-mode t)
 '(global-diff-hl-mode t)
 '(global-git-gutter-mode t)
 '(groovy-indent-offset 2)
 '(haskell-ask-also-kill-buffers nil)
 '(haskell-indentation-show-indentations nil)
 '(haskell-indentation-show-indentations-after-eol nil)
 '(haskell-stylish-on-save t)
 '(haskell-tags-on-save t)
 '(helm-boring-buffer-regexp-list
   '("\\` " "\\`\\*helm" "\\`\\*Echo Area" "\\`\\*Minibuf" "\\`\\*helpful" "\\`\\*Flycheck"
     "\\`\\*EGLOT"))
 '(helm-buffer-details-flag nil)
 '(helm-describe-function-function 'helpful-callable)
 '(helm-describe-variable-function 'helpful-variable)
 '(helm-display-buffer-default-height 15)
 '(helm-echo-input-in-header-line t)
 '(helm-grep-file-path-style 'relative)
 '(helm-ls-git-show-abs-or-relative 'relative)
 '(helm-mode-fuzzy-match t)
 '(helm-projectile-set-input-automatically nil)
 '(helm-split-window-inside-p t)
 '(help-at-pt-display-when-idle '(haskell-msg) nil (help-at-pt))
 '(help-at-pt-timer-delay 0.5)
 '(history-delete-duplicates t)
 '(ido-enable-flex-matching t)
 '(ido-everywhere nil)
 '(ido-ignore-files
   '("\\`CVS/" "\\`#" "\\`.#" "\\`\\.\\./" "\\`\\./" "\\.orig$" "\\.bak$"))
 '(ido-mode 'both nil (ido))
 '(importmagic-style-configuration-alist '((multiline . backslashes) (max_columns . 120)))
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(jedi:environment-virtualenv '("pyvenv"))
 '(js-indent-level 2)
 '(js2-strict-missing-semi-warning nil)
 '(js2-strict-trailing-comma-warning nil)
 '(kept-new-versions 10)
 '(menu-bar-mode nil)
 '(midnight-mode t nil (midnight))
 '(native-comp-debug 0)
 '(native-comp-jit-compilation-deny-list '(".*/realgud/.*" ".*/realgud.el"))
 '(ns-≥right-alternate-modifier 'none)
 '(overseer-command "~/.cask/bin/cask exec ert-runner")
 '(package-archives
   '(("melpa" . "https://melpa.org/packages/") ("gnu" . "http://elpa.gnu.org/packages/")
     ("localelpa" . "~/.emacs.d/localelpa-packages/")))
 '(package-selected-packages
   '(0x0 agent-shell ansible ansible-vault base16-theme company-ansible company-box company-terraform
         dockerfile-mode eldoc-box eslint-fix fish-mode flycheck flycheck-eglot font-lock-studio
         format-all git git-gutter-fringe gruvbox-theme haskell-mode helm-flycheck helm-projectile
         helm-xref helpful kaolin-themes magit magit-popup markdown-preview-mode multiple-cursors
         nodejs-repl orgtbl-join phi-search po-mode projectile pyenv-mode realgud realgud-pdbpp
         rich-minority rust-mode shell-pop smart-mode-line vdiff virtualenvwrapper web-beautify
         web-mode which-key yaml-mode yasnippet zig-mode))
 '(paradox-execute-asynchronously t)
 '(paradox-github-token t)
 '(projectile-enable-caching t)
 '(projectile-mode t nil (projectile))
 '(projectile-mode-line nil)
 '(projectile-use-git-grep t)
 '(py-autopep8-on-save-p 'is-buffer-valid-python)
 '(py-autopep8-options '("--max-line-length=140"))
 '(pyenv-mode-mode-line-format
   '(:eval (when (pyenv-mode-version) (concat "(" (pyenv-mode-version) ") "))))
 '(realgud-populate-common-fn-keys-function 'identity)
 '(ring-bell-function 'ignore)
 '(rm-text-properties
   '(("\\` Ovwrt\\'" 'face 'font-lock-warning-face) ("\\` FlyC:" 'face 'font-lock-warning-face)))
 '(rust-format-on-save t)
 '(safe-local-variable-values
   '((format-all-formatters ("Python" ruff))
     (flycheck-python-mypy-cache-dir . "/Users/david.couderc/dev/invoice_parsing/.mypy_cache")
     (flycheck-python-mypy-config . "/Users/david.couderc/dev/invoice_parsing/mypy.ini")
     (flycheck-python-mypy-cache-dir . "/Users/david.couderc/dev/telecollecte/.mypy_cache")
     (flycheck-python-mypy-config . "/Users/david.couderc/dev/telecollecte/mypy.ini")
     (project-venv-name . "tina") (project-venv-name . "tina-2.2")
     (project-venv-name . "tina-develop") (project-venv-name . "netlink2")))
 '(savehist-mode t)
 '(scroll-bar-mode nil)
 '(scss-compile-at-save nil)
 '(shell-file-name "/bin/bash")
 '(shell-pop-universal-key "C-p")
 '(show-paren-mode t)
 '(sml/position-percentage-format "")
 '(sml/use-projectile-p 'before-prefixes)
 '(terraform-indent-level 2)
 '(tool-bar-mode nil)
 '(typescript-indent-level 2)
 '(vc-make-backup-files t)
 '(version-control t)
 '(visible-bell nil)
 '(web-mode-code-indent-offset 2)
 '(web-mode-css-indent-offset 2)
 '(web-mode-enable-auto-indentation nil)
 '(web-mode-enable-current-element-highlight t)
 '(web-mode-markup-indent-offset 2)
 '(web-mode-script-padding 0)
 '(web-mode-style-padding 0)
 '(which-key-mode t)
 '(yas-global-mode t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Menlo" :height 140))))
 '(diff-hl-change ((t (:background "steel blue" :foreground "blue3"))))
 '(diff-hl-delete ((t (:inherit magit-diff-removed-highlight))))
 '(diff-hl-insert ((t (:inherit magit-diff-added-highlight))))
 '(eldoc-box-border ((t (:background "gray69"))))
 '(flymake-warnline ((t (:background "black"))) t)
 '(web-mode-function-call-face ((t nil))))

(setenv "LIBRARY_PATH" "/opt/homebrew//Cellar/gcc/15.1.0/lib/gcc/current/gcc/aarch64-apple-darwin24/15/")

(when (fboundp 'sml/setup)
  (sml/setup))

(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

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

;;--[python-mode]------------------------------------------------------

(autoload 'my-python-setup "~/.emacs.d/python-setup.el")
(add-hook 'python-mode-hook #'my-python-setup)
(add-hook 'python-ts-mode-hook #'my-python-setup)
(add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
(add-hook 'fish-mode-hook (lambda () (setq tab-width 4)))

;;--[web-mode]----------------------------------------------------------


(setq web-mode-engines-alist '(("django" . "\\.html\\'")))

(add-hook 'web-mode-hook
          (lambda ()
            (company-mode)
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

;; (defun run-jasmine ()
;;   (interactive)
;;   (let* ((root tide-project-root)
;;          (eljasmine (expand-file-name "~/.emacs.d/eljasmine/src/main.js"))
;;          (node (locate-file tide-node-executable exec-path exec-suffixes 1))
;;          (compilation-environment '(concat "NODE_PATH=" root "node_modules"))
;;          (command (concat (shell-quote-argument node)
;;                           " "
;;                           (shell-quote-argument eljasmine)))
;;          (default-directory root))
;;     (compile command 'jasmine-compilation-mode)))

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

;;--[company-box]------------------------------------------

(add-hook 'company-mode-hook 'company-box-mode) ;

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
                      " ARev" " company" " tide" " ElDoc" " Guide" " Projectile"
                      " WK" " yas" " import" " Isort" " company-box"
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
(add-hook 'terraform-mode-hook #'company-terraform-init)

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

(with-eval-after-load 'agent-shell
  (setq agent-shell-anthropic-authentication
      (agent-shell-anthropic-make-authentication :login t)))

;;--[gitlab-duo]---------------------------------------------

(autoload 'gitlab-duo-start "~/.emacs.d/gitlab-duo.el" "Start the gitlab DUO chat." t)
(global-set-key (kbd "C-c t") #'gitlab-duo-start)

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
(add-to-list 'exec-path (expand-file-name "~/.nvm/versions/node/v22.15.1/bin/"))
(add-to-list 'exec-path "/opt/homebrew/bin/")
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
