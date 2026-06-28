# ACP.el — OpenCode Agent Communication Protocol REPL for Emacs

Pure Emacs Lisp REPL that spawns `opencode acp` as a subprocess and renders agent responses with tree-sitter markdown faces and inline tool-call widgets.

## Commands

- `M-x acp` — start REPL in `*acp*` buffer (auto-launches agent)
- `C-c r` — reload all `.el` files and restart REPL (use after editing any source)
- `C-c l` — view agent log buffer (` *acp-agent-log:...*`)
- `C-c k` — cancel the running prompt turn (sends `session/cancel` and dismisses pending permission requests)
- `y` / `!` / `n` on a permission widget — Allow once / Always allow / Reject
- `RET` in prompt — submit; `S-<return>` — literal newline
- `C-<return>` in `acp-markdown-test.el` — save, eval, run all ERT tests

## Running tests

There is an ERT testsuite, launch it with

```powershell
& "C:\Program Files\Emacs\emacs-30.1\bin\emacs.exe" --batch -L . -l ert -l acp-markdown-test.el -l acp-tool-call-widget-test.el -l acp-permission-widget-test.el -l acp-plan-widget-test.el -l acp-changes-summary-widget-test.el -l acp-diff-test.el -f ert-run-tests-batch-and-exit
```

## Architecture

- `acp.el` — entry point, major mode, widget glue
- `acp-agent.el` — JSON-RPC client (newline-delimited JSON over stdin/stdout)
- `acp-markdown.el` — tree-sitter markdown → propertized text renderer
- `acp-tool-call-widget.el` — inline widget for displaying tool call status
- `acp-prompt-widget.el` — editable prompt field widget
- `acp-icon.el` — SVG icon cache for tool call types
- `acp-permission-widget.el` — alert panel widget for agent permission requests with y/!/n shortcuts
- `acp-plan-widget.el` — todo-list plan rendering from todowrite tool calls
- `acp-changes-summary-widget.el` — diff summary widget showing files changed during a prompt turn
- `acp-diff.el` — unified diff generation and formatting utilities
- `acp-git.el` — git worktree snapshot helper for before/after diffs
- `acp-frame.el` — bordered frame overlays for panel widgets

## Quirks

- Load via `acp-reload` (`C-c r`) to pick up changes across all files. Alternatively, `eval-buffer` individual files.
- Requires Emacs with tree-sitter support and a `markdown` tree-sitter grammar installed (`treesit-install-language-grammar markdown`).
- Agent protocol is JSON-RPC over stdin/stdout (no HTTP). See the [ACP spec](https://agentclientprotocol.com/). 
- Default agent command: `("opencode" "acp")`. Override via `acp-agent-command` custom variable.
- No package.el headers. No Makefile. No CI.
- `.gitignore` covers Emacs backup (`*~`, `#*#`, `.#*`) and bytecode (`*.elc`).
