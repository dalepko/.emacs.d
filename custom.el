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
