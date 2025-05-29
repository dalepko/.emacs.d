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
                  company-oddmuse company-dabbrev company-tabnine))
 '(company-box-doc-delay 0.1)
 '(company-idle-delay 0.1)
 '(css-indent-offset 2)
 '(custom-enabled-themes '(gruvbox-dark-medium))
 '(custom-safe-themes
   '("5aedf993c7220cbbe66a410334239521d8ba91e1815f6ebde59cecc2355d7757"
     "75b371fce3c9e6b1482ba10c883e2fb813f2cc1c88be0b8a1099773eb78a7176"
     "51fa6edfd6c8a4defc2681e4c438caf24908854c12ea12a1fbfd4d055a9647a3"
     "8363207a952efb78e917230f5a4d3326b2916c63237c1f61d7e5fe07def8d378"
     "5a0ddbd75929d24f5ef34944d78789c6c3421aa943c15218bac791c199fc897d"
     "7c33cf70beb849ea3cd74430676164dbcc2550e6a2cad69c6792505ec78f3887"
     "fbf73690320aa26f8daffdd1210ef234ed1b0c59f3d001f342b9c0bbf49f531c"
     "5291b60ee27dfc12078f787929498ce82efe5e4d42decdbb994be80cdb2def1f"
     "74e2ed63173b47d6dc9a82a9a8a6a9048d89760df18bc7033c5f91ff4d083e37"
     "fc1275617f9c8d1c8351df9667d750a8e3da2658077cfdda2ca281a2ebc914e0"
     "0170347031e5dfa93813765bc4ef9269a5e357c0be01febfa3ae5e5fcb351f09"
     "11cc65061e0a5410d6489af42f1d0f0478dbd181a9660f81a692ddc5f948bf34"
     "c9415c9f5a5ed67914d1d64a0ea7d743ef93516f1f2c8501bc5ffb87af2066d3"
     "7e5d400035eea68343be6830f3de7b8ce5e75f7ac7b8337b5df492d023ee8483"
     "b9e406b52f60a61c969f203958f406fed50b5db5ac16c127b86bbddd9d8444f7"
     "d9a28a009cda74d1d53b1fbd050f31af7a1a105aa2d53738e9aa2515908cac4c"
     "78c01e1b7f3dc9e47bdd48f74dc98dc1a345c291f83b68ac8a1b40191f24d658"
     "620b9018d9504f79344c8ef3983ea4e83d209b46920f425240889d582be35881"
     "0c6a36393d5782839b88e4bf932f20155cb4321242ce75dc587b4f564cb63d90"
     "7236acec527d58086ad2f1be6a904facc9ca8bf81ed1c19098012d596201b3f1"
     "da137fc61c9a77457720f6c24094cacb9a2a62240d53aeb9f44dccfe5d6df53e"
     "a4395e069de3314001de4e139d6a3b1a83dcf9c3fdc68ee7b13eef6c2cba4ae3"
     "d9741f492c26b4e1c93874ee10476ca233e496827740b3fdb3aa6b6df871d449"
     "527df6ab42b54d2e5f4eec8b091bd79b2fa9a1da38f5addd297d1c91aa19b616"
     "c968804189e0fc963c641f5c9ad64bca431d41af2fb7e1d01a2a6666376f819c"
     "722e1cd0dad601ec6567c32520126e42a8031cd72e05d2221ff511b58545b108"
     "cea3ec09c821b7eaf235882e6555c3ffa2fd23de92459751e18f26ad035d2142"
     "3c9250705b4750e314d4e78c584b862415e183e16f76cc6fc18f0bd6f3d69b37"
     "ef04dd1e33f7cbd5aa3187981b18652b8d5ac9e680997b45dc5d00443e6a46e3"
     "eae831de756bb480240479794e85f1da0789c6f2f7746e5cc999370bbc8d9c8a"
     "7a1190ad27c73888f8d16142457f59026b01fa654f353c17f997d83565c0fc65"
     "df21cdadd3f0648e3106338649d9fea510121807c907e2fd15565dde6409d6e9"
     "cbd8e65d2452dfaed789f79c92d230aa8bdf413601b261dbb1291fb88605110c"
     "85d609b07346d3220e7da1e0b87f66d11b2eeddad945cac775e80d2c1adb0066"
     "f5f3a6fb685fe5e1587bafd07db3bf25a0655f3ddc579ed9d331b6b19827ea46"
     "9be1d34d961a40d94ef94d0d08a364c3d27201f3c98c9d38e36f10588469ea57"
     "ad16a1bf1fd86bfbedae4b32c269b19f8d20d416bd52a87cd50e355bf13c2f23"
     "93268bf5365f22c685550a3cbb8c687a1211e827edc76ce7be3c4bd764054bad"
     "b8929cff63ffc759e436b0f0575d15a8ad7658932f4b2c99415f3dde09b32e97"
     "16dd114a84d0aeccc5ad6fd64752a11ea2e841e3853234f19dc02a7b91f5d661"
     "f984e2f9765a69f7394527b44eaa28052ff3664a505f9ec9c60c088ca4e9fc0b"
     "36282815a2eaab9ba67d7653cf23b1a4e230e4907c7f110eebf3cdf1445d8370"
     "264b639ee1d01cd81f6ab49a63b6354d902c7f7ed17ecf6e8c2bd5eb6d8ca09c"
     "840db7f67ce92c39deb38f38fbc5a990b8f89b0f47b77b96d98e4bf400ee590a"
     "a62f0662e6aa7b05d0b4493a8e245ab31492765561b08192df61c9d1c7e1ddee"
     "45a8b89e995faa5c69aa79920acff5d7cb14978fbf140cdd53621b09d782edcf"
     "1d079355c721b517fdc9891f0fda927fe3f87288f2e6cc3b8566655a64ca5453"
     "986e7e8e428decd5df9e8548a3f3b42afc8176ce6171e69658ae083f3c06211c"
     "50ff65ab3c92ce4758cc6cd10ebb3d6150a0e2da15b751d7fbee3d68bba35a94"
     "4bf5c18667c48f2979ead0f0bdaaa12c2b52014a6abaa38558a207a65caeb8ad"
     "5a7830712d709a4fc128a7998b7fa963f37e960fd2e8aa75c76f692b36e6cf3c"
     "ffe80c88e3129b2cddadaaf78263a7f896d833a77c96349052ad5b7753c0c5a5"
     "3380a2766cf0590d50d6366c5a91e976bdc3c413df963a0ab9952314b4577299"
     "8be07a2c1b3a7300860c7a65c0ad148be6d127671be04d3d2120f1ac541ac103"
     "85e6bb2425cbfeed2f2b367246ad11a62fb0f6d525c157038a0d0eaaabc1bfee"
     "12670281275ea7c1b42d0a548a584e23b9c4e1d2dabb747fd5e2d692bcd0d39b"
     "aea30125ef2e48831f46695418677b9d676c3babf43959c8e978c0ad672a7329"
     "6271fc9740379f8e2722f1510d481c1df1fcc43e48fa6641a5c19e954c21cc8f"
     "50b64810ed1c36dfb72d74a61ae08e5869edc554102f20e078b21f84209c08d1"
     "25c06a000382b6239999582dfa2b81cc0649f3897b394a75ad5a670329600b45"
     "d2bd16a8bcf295dce0b70e1d2b5c17bb34cb28224a86ee770d56e6c22a565013"
     "3de3f36a398d2c8a4796360bfce1fa515292e9f76b655bb9a377289a6a80a132"
     "7bef2d39bac784626f1635bd83693fae091f04ccac6b362e0405abf16a32230c"
     "aded4ec996e438a5e002439d58f09610b330bbc18f580c83ebaba026bbef6c82"
     "0c3b1358ea01895e56d1c0193f72559449462e5952bded28c81a8e09b53f103f"
     "446cc97923e30dec43f10573ac085e384975d8a0c55159464ea6ef001f4a16ba"
     "6145e62774a589c074a31a05dfa5efdf8789cf869104e905956f0cbd7eda9d0e"
     "78c1c89192e172436dbf892bd90562bc89e2cc3811b5f9506226e735a953a9c6"
     "760ce657e710a77bcf6df51d97e51aae2ee7db1fba21bbad07aab0fa0f42f834"
     "34ed3e2fa4a1cb2ce7400c7f1a6c8f12931d8021435bad841fdc1192bd1cc7da"
     "b3bcf1b12ef2a7606c7697d71b934ca0bdd495d52f901e73ce008c4c9825a3aa"
     "83db918b06f0b1df1153f21c0d47250556c7ffb5b5e6906d21749f41737babb7"
     "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a"
     "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d"
     "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58"
     "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e"
     "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016"
     "28ec8ccf6190f6a73812df9bc91df54ce1d6132f18b4c8fcc85d45298569eb53"
     "8ec2e01474ad56ee33bc0534bdbe7842eea74dccfb576e09f99ef89a705f5501"
     "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e"
     "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223"
     "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa"
     "8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26"
     "f3d6a49e3f4491373028eda655231ec371d79d6d2a628f08d5aa38739340540b"
     "b571f92c9bfaf4a28cb64ae4b4cdbda95241cd62cf07d942be44dc8f46c491f4"
     "66132890ee1f884b4f8e901f0c61c5ed078809626a547dbefbb201f900d03fd8"
     "3632cf223c62cb7da121be0ed641a2243f7ec0130178722554e613c9ab3131de"
     "7e83d0aacca4c0e4e9441f920a66ee4de73decc1bb9dd7fcc2c1857948e604c8"
     "a444b2e10bedc64e4c7f312a737271f9a2f2542c67caa13b04d525196562bf38"
     "e8a9dfa28c7c3ae126152210e3ccc3707eedae55bdc4b6d3e1bb3a85dfb4e670"
     "de8fa309eed1effea412533ca5d68ed33770bdf570dcaa458ec21eab219821fd"
     "8abee8a14e028101f90a2d314f1b03bed1cde7fd3f1eb945ada6ffc15b1d7d65"
     "9cb6358979981949d1ae9da907a5d38fb6cde1776e8956a1db150925f2dad6c1"
     "5999e12c8070b9090a2a1bbcd02ec28906e150bb2cdce5ace4f965c76cf30476"
     "3a9249d4c34f75776e130efd7e02c4a0a7c90ad7723b50acc5806112394ec2dd"
     "fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6"
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
   '(0x0 ansible ansible-vault base16-theme company-ansible company-box company-terraform
         dockerfile-mode eldoc-box eslint-fix fish-mode flycheck flycheck-eglot format-all git
         git-gutter-fringe gruvbox-theme haskell-mode helm-flycheck helm-projectile helm-xref
         helpful kaolin-themes magit magit-popup markdown-preview-mode multiple-cursors nodejs-repl
         orgtbl-join phi-search po-mode projectile pyenv-mode realgud realgud-pdbpp rich-minority
         rust-mode shell-pop smart-mode-line vdiff virtualenvwrapper web-beautify web-mode which-key
         yaml-mode yasnippet zig-mode))
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

(setenv "LIBRARY_PATH" "/opt/homebrew//Cellar/gcc/14.2.0_1/lib/gcc/current/gcc/aarch64-apple-darwin24/14/")

(when (fboundp 'sml/setup)
  (sml/setup))

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

(eval-after-load 'flycheck
  '(define-key flycheck-mode-map (kbd "C-c ! l") 'helm-flycheck))


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

(add-hook 'rust-mode-hook 'eglot-ensure)

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

;;--[paths for external executables]-------------------------

(add-to-list 'exec-path "~/.local/bin")
(add-to-list 'exec-path "~/.cargo/bin")
(add-to-list 'exec-path "/opt/node/bin")
(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path (expand-file-name "~/.nvm/versions/node/v20.11.0/bin/"))
(add-to-list 'exec-path "/opt/homebrew/bin/")
(add-to-list 'exec-path (expand-file-name "~/.pyenv/shims"))
(setenv "PATH" (concat
                "/opt/node/bin:/usr/local/bin"
                ":"
                (expand-file-name "~/.nvm/versions/node/v20.11.0/bin/")
                ":"
                (expand-file-name "~/.pyenv/shims")
                ":"
                "/opt/homebrew/bin/"
                ":"
                (getenv "PATH")))

(if (equal (system-name) "Deepki-QL4P79YPQ4.local")
    (let ((netskope-ca (expand-file-name "~/.nskp-cert/netskope-cert-bundle.pem")))
      (load-library "gnutls")
      (setenv "CURL_CA_BUNDLE" netskope-ca)
      (cl-pushnew netskope-ca gnutls-trustfiles)))

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
