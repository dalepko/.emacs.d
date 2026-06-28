;;; acp-markdown-test.el --- Tests for acp-markdown  -*- lexical-binding: t; -*-

(require 'ert)

(require 'acp-markdown)
(require 'acp-test-utils)


(defmacro with-test-buffer (initial-text &rest body)
  "Create temp buffer with INITIAL-TEXT, run BODY, ensure buffer is killed."
  (declare (indent 1) (debug t))
  (let ((buf-var (make-symbol "buf")))
    `(let ((,buf-var (acp-markdown-buffer-create)))
       (with-current-buffer ,buf-var
         (insert ,initial-text)
         (treesit-update-ranges)
         (unwind-protect 
             (progn ,@body)
           (kill-buffer ,buf-var))))))


(defun find-node (node-type)
  (treesit-search-subtree (treesit-parser-root-node (car (treesit-parser-list))) node-type))

(defun inspect-ts-node (node &optional indent)
  "Recursively inspect the structure of Tree-sitter NODE and return a string."
  (unless (treesit-node-p node)
    (error "Object is not a tree-sitter node: %S" node))
  (let* ((type (treesit-node-type node))
         (field (treesit-node-field-name node))
         (node (if (or (string= type "inline") (string= type "pipe_table_cell"))
                   (treesit-node-on (treesit-node-start node) (treesit-node-end node) 'markdown-inline)
                 node))
         (indent (or indent 0))
         (prefix (make-string indent ?\s))
         (text (treesit-node-text node))
         (parts nil))
    (push (format "%s%s%s -> %S"
                  prefix
                  (if field (format "[%s] " field) "")
                  type
                  (let ((text-line (string-replace "\n" "\\n" text)))
                    (if (> (length text-line) 100)
                        (concat (substring text-line 0 27) "...")
                      text-line)))
          parts)
    (dolist (i (treesit-node-children node))
      (push (inspect-ts-node i (+ indent 4)) parts))
    (mapconcat #'identity (nreverse parts) "\n")))

(defun inspect-string (string)
  (let ((rendered (with-test-buffer string
                    (inspect-ts-node (treesit-parser-root-node (car (treesit-parser-list))))))
        (output-buffer (get-buffer-create "tree")))
    (with-current-buffer output-buffer
      (delete-region (point-min) (point-max))
      (insert rendered))
    (pop-to-buffer output-buffer)))

(defun render (string &optional node-type)
  (let ((rendered (with-test-buffer string
                    (acp-markdown--render-node (find-node (or node-type "document")))))
        (output-buffer (get-buffer-create "render")))
    (with-current-buffer output-buffer
      (delete-region (point-min) (point-max))
      (insert rendered))
    (pop-to-buffer output-buffer)))


(ert-deftest acp-markdown-emphasis ()
  (with-test-buffer "# this is *italic*"
    (let* ((inline-element (find-node "inline"))
           (rendered (acp-markdown--render-node inline-element)))
      (should (equal (intervals rendered)
                     '(("this is ")
                       ("italic" face acp-markdown-emphasis-face)))))))

(ert-deftest acp-markdown-emphasis-with-underscore ()
  (with-test-buffer "# this is _italic_"
    (let* ((inline-element (find-node "inline"))
           (rendered (acp-markdown--render-node inline-element)))
      (should (equal (intervals rendered)
                     '(("this is ")
                       ("italic" face acp-markdown-emphasis-face)))))))

(ert-deftest acp-markdown-bold ()
  (with-test-buffer "this is **bold**"
    (let* ((inline-element (find-node "inline"))
           (rendered (acp-markdown--render-node inline-element)))
      (should (equal (intervals rendered)
                     '(("this is ")
                       ("bold" face acp-markdown-strong-face)))))))

(ert-deftest acp-markdown-bold-with-underscore ()
  (with-test-buffer "this is __bold__"
    (let* ((inline-element (find-node "inline"))
           (rendered (acp-markdown--render-node inline-element)))
      (should (equal (intervals rendered)
                     '(("this is ")
                       ("bold" face acp-markdown-strong-face)))))))


(ert-deftest acp-markdown-bold-and-italic ()
  (with-test-buffer "this is ***italic and bold***"
    (let* ((inline-element (find-node "inline"))
           (rendered (acp-markdown--render-node inline-element)))
      (should (equal (intervals rendered)
                     '(("this is ")
                       ("italic and bold" face (acp-markdown-strong-face
                                                acp-markdown-emphasis-face))))))))

(ert-deftest acp-markdown-bold-and-italic-error ()
  (with-test-buffer "this is ***italic and bold**"
    (let* ((inline-element (find-node "inline"))
           (rendered (acp-markdown--render-node inline-element)))
      (should (equal (intervals rendered)
                     '(("this is *")
                       ("italic and bold" face acp-markdown-strong-face)))))))


(ert-deftest acp-markdown-heading ()
  (with-test-buffer "# This a header"
    (let* ((heading (find-node "atx_heading"))
           (rendered (acp-markdown--render-node heading)))
      (should (equal (intervals rendered)
                     '(("This a header\n" face acp-markdown-heading-1-face)))))))

(ert-deftest acp-markdown-heading-level-2 ()
  (with-test-buffer "##  header"
    (let* ((heading (find-node "atx_heading"))
           (rendered (acp-markdown--render-node heading)))
      (should (equal (intervals rendered)
                     '(("header\n" face acp-markdown-heading-2-face)))))))

(ert-deftest acp-markdown-heading-with-formatting ()
  (with-test-buffer "# *italic* and **bold**"
    (let* ((heading (find-node "atx_heading"))
           (rendered (acp-markdown--render-node heading)))
      (should (equal (intervals rendered)
                     '(("italic" face (acp-markdown-emphasis-face
                                       acp-markdown-heading-1-face))
                       (" and " face acp-markdown-heading-1-face)
                       ("bold" face (acp-markdown-strong-face
                                     acp-markdown-heading-1-face))
                       ("\n" face acp-markdown-heading-1-face)))))))


(ert-deftest acp-markdown-code-span ()
  (with-test-buffer "this is `inline code` here"
    (let* ((inline-element (find-node "inline"))
           (rendered (acp-markdown--render-node inline-element)))
      (should (equal (intervals rendered)
                     '(("this is ")
                       ("inline code" face acp-markdown-code-face)
                       (" here")))))))


(ert-deftest acp-markdown-block-quote ()
  (with-test-buffer "> A simple quote"
    (let* ((bq (find-node "block_quote"))
           (rendered (acp-markdown--render-node bq)))
      (should (equal (intervals rendered)
                     '(("A simple quote" line-prefix "  ")))))))

(ert-deftest acp-markdown-block-quote-multiline ()
  (with-test-buffer "> Line 1\nLine 2"
    (let* ((bq (find-node "block_quote"))
           (rendered (acp-markdown--render-node bq)))
      (should (equal (intervals rendered)
                     '(("Line 1\nLine 2" line-prefix "  ")))))))

(ert-deftest acp-markdown-block-quote-with-formatting ()
  (with-test-buffer "> *italic* and **bold**"
    (let* ((bq (find-node "block_quote"))
           (rendered (acp-markdown--render-node bq)))
      (should (equal (intervals rendered)
                     '(("italic" line-prefix "  " face acp-markdown-emphasis-face)
                       (" and " line-prefix "  ")
                       ("bold" line-prefix "  " face acp-markdown-strong-face)))))))

(ert-deftest acp-markdown-hyphen-in-text ()
  (with-test-buffer "well-known"
    (let* ((inline (find-node "inline"))
           (rendered (acp-markdown--render-node inline)))
      (should (equal rendered "well-known")))))

(ert-deftest acp-markdown-thematic-break ()
  (with-test-buffer "***\n"
    (let* ((bq (find-node "thematic_break"))
           (rendered (acp-markdown--render-node bq)))
      (should (equal (intervals rendered)
                     '(("\n" face acp-markdown-thematic-break-face)))))))

(ert-deftest acp-markdown-backslash-escape-asterisk ()
  (with-test-buffer "\\*not italic\\*"
    (let* ((inline (find-node "inline"))
           (rendered (acp-markdown--render-node inline)))
      (should (equal rendered "*not italic*")))))

(ert-deftest acp-markdown-backslash-escape-backslash ()
  (with-test-buffer "a\\\\b"
    (let* ((inline (find-node "inline"))
           (rendered (acp-markdown--render-node inline)))
      (should (equal rendered "a\\b")))))

(ert-deftest acp-markdown-indented-code-block ()
  (with-test-buffer "text

    code

after"
    (let* ((icb (find-node "indented_code_block"))
           (rendered (acp-markdown--render-node icb)))
      (should (equal (intervals rendered)
                     '(("code\n" face acp-markdown-code-block-face)
                       ("\n")))))))

(ert-deftest acp-markdown-indented-code-block-in-list ()
  (with-test-buffer "* text

      code

  after
"
    (let* ((icb (find-node "list_item"))
           (rendered (acp-markdown--render-node icb)))
      (should (equal (intervals rendered)
                     '(("* " display "" line-prefix "• ")
                       ("text\n\n" line-prefix "  ")
                       ("code\n" face acp-markdown-code-block-face line-prefix "  ")
                       ("\nafter\n" line-prefix "  ")))))))

(ert-deftest acp-markdown-indented-code-block-multiline ()
  (with-test-buffer "text

    line 1
    line 2

after"
    (let* ((icb (find-node "indented_code_block"))
           (rendered (acp-markdown--render-node icb)))
      (should (equal (intervals rendered)
                     '(("line 1\nline 2\n" face acp-markdown-code-block-face)
                       ("\n")))))))

(ert-deftest acp-markdown-fenced-code-block ()
  (with-test-buffer "```elisp
(setq a 1)
```
"
    (let* ((fcb (find-node "fenced_code_block"))
           (rendered (acp-markdown--render-node fcb)))
      (should (equal (intervals rendered)
                     '(("(" face acp-markdown-code-block-face)
                       ("setq" face (font-lock-keyword-face acp-markdown-code-block-face))
                       (" a 1)\n" face acp-markdown-code-block-face)))))))

(ert-deftest acp-markdown-fenced-code-block-in-list ()
  (with-test-buffer "* text\n
  ```elisp
  (setq a 1)
  ```
"
    (let* ((fcb (find-node "fenced_code_block"))
           (rendered (acp-markdown--render-node fcb)))
      (should (equal (intervals rendered)
                     '(("(" face acp-markdown-code-block-face)
                       ("setq" face (font-lock-keyword-face acp-markdown-code-block-face))
                       (" a 1)\n" face acp-markdown-code-block-face)))))))


(ert-deftest acp-markdown-list-flat-minus ()
  (with-test-buffer "- Item 1\n- Item 2"
    (let* ((list (find-node "list"))
           (rendered (acp-markdown--render-node list)))
      (should (equal (intervals rendered)
                     '(("- " line-prefix "• " display "")
                       ("Item 1\n" line-prefix "  ")
                       ("- " line-prefix "• " display "")
                       ("Item 2" line-prefix "  ")))))))

(ert-deftest acp-markdown-list-flat-star ()
  (with-test-buffer "* Item 1\n* Item 2"
    (let* ((list (find-node "list"))
           (rendered (acp-markdown--render-node list)))
      (should (equal (intervals rendered)
                     '(("* " line-prefix "• " display "")
                       ("Item 1\n" line-prefix "  ")
                       ("* " line-prefix "• " display "")
                       ("Item 2" line-prefix "  ")))))))

(ert-deftest acp-markdown-list-flat-dot ()
  (with-test-buffer "1. Item 1\n2. Item 2"
    (let* ((list (find-node "list"))
           (rendered (acp-markdown--render-node list)))
      (should (equal (intervals rendered)
                     '(("1. " line-prefix "1. " display "")
                       ("Item 1\n" line-prefix "   ")
                       ("2. " line-prefix "2. " display "")
                       ("Item 2" line-prefix "   ")))))))

(ert-deftest acp-markdown-list-flat-paren ()
  (with-test-buffer "1) Item 1\n2) Item 2"
    (let* ((list (find-node "list"))
           (rendered (acp-markdown--render-node list)))
      (should (equal (intervals rendered)
                     '(("1) " line-prefix "1) " display "")
                       ("Item 1\n" line-prefix "   ")
                       ("2) " line-prefix "2) " display "")
                       ("Item 2" line-prefix "   ")))))))

(ert-deftest acp-markdown-list-ordered-multidigit ()
  (with-test-buffer "9. Item 9\n10. Item 10"
    (let* ((list (find-node "list"))
           (rendered (acp-markdown--render-node list)))
      (should (equal (intervals rendered)
                     '(("9. " line-prefix "9. " display "")
                       ("Item 9\n" line-prefix "   ")
                       ("10. " line-prefix "10. " display "")
                       ("Item 10" line-prefix "    ")))))))

(ert-deftest acp-markdown-list-with-block-quote ()
  (with-test-buffer "- Item 1\n  > Nested quote"
    (let* ((list (find-node "list"))
           (rendered (acp-markdown--render-node list)))
      (should (equal (intervals rendered)
                     '(("- " line-prefix "• " display "")
                       ("Item 1\n" line-prefix "  ")
                       ("Nested quote"
                        line-prefix
                        #("    " 2 3 (face acp-markdown-block-quote-face)))))))))

(ert-deftest acp-markdown-list-nested ()
  (with-test-buffer "- Item 1\n  - Sub-item"
    (let* ((list (find-node "list"))
           (rendered (acp-markdown--render-node list)))
      (should (equal (intervals rendered)
                     '(("- " line-prefix "• " display "")
                       ("Item 1\n" line-prefix "  ")
                       ("- " display "" line-prefix "  • ")
                       ("Sub-item" line-prefix "    ")))))))


(ert-deftest acp-markdown-shortcut-link ()
  (with-test-buffer "Link: [http://test.com]"
    (let* ((link (find-node "inline"))
           (rendered (acp-markdown--render-node link)))
      (should (equal (intervals rendered)
                     '(("Link: ")
                       ("http://test.com" url "http://test.com" face acp-markdown-link-face)))))))


(ert-deftest acp-markdown-inline-link ()
  (with-test-buffer "This is a [link](http://test.com)"
    (let* ((link (find-node "inline"))
           (rendered (acp-markdown--render-node link)))
      (should (equal (intervals rendered)
                     '(("This is a ")
                       ("link" url "http://test.com" face acp-markdown-link-face)))))))

(ert-deftest acp-markdown-error ()
  (with-test-buffer "xxx\n```"
    (let* ((link (find-node "document"))
           (rendered (acp-markdown--render-node link)))
      (should (equal (intervals rendered)
                     '(("xxx\n```")))))))

(ert-deftest acp-markdown-table-simple ()
  (with-test-buffer "\
| A | B |
| - | - |
| 1 | 2 |
"
    (let* ((table (find-node "pipe_table"))
           (rendered (acp-markdown--render-node table)))
      (should (string= rendered
                       "\
┌───┬───┐
│ A │ B │
├───┼───┤
│ 1 │ 2 │
└───┴───┘
")))))

(ert-deftest acp-markdown-table-alignments ()
  (with-test-buffer "| Left | Center | Right |
| :--- | :----: | ----: |
| a    | b      | c     |
"
    (let* ((table (find-node "pipe_table"))
           (rendered (acp-markdown--render-node table)))
      (should (string= rendered
                       "\
┌──────┬────────┬───────┐
│ Left │ Center │ Right │
├──────┼────────┼───────┤
│ a    │   b    │     c │
└──────┴────────┴───────┘
")))))

(ert-deftest acp-markdown-table-multiline ()
  (with-test-buffer "| Col | Value |
| --- | ----- |
| x   | 42    |
| y   | 7     |
"
    (let* ((table (find-node "pipe_table"))
           (rendered (acp-markdown--render-node table)))
      (should (string= rendered
                       "\
┌─────┬───────┐
│ Col │ Value │
├─────┼───────┤
│ x   │ 42    │
│ y   │ 7     │
└─────┴───────┘
")))))

(ert-deftest acp-markdown-table-formatting-in-cell ()
  (with-test-buffer "| A | B |
| - | - |
| **bold** | *italic* |
"
    (let* ((table (find-node "pipe_table"))
           (rendered (acp-markdown--render-node table)))
      (should (string= rendered
                       "\
┌──────┬────────┐
│ A    │ B      │
├──────┼────────┤
│ bold │ italic │
└──────┴────────┘
"))
      (let ((bold-start (string-match "bold" rendered))
            (italic-start (string-match "italic" rendered)))
        (should (equal (get-text-property bold-start 'face rendered)
                       'acp-markdown-strong-face))
        (should (equal (get-text-property italic-start 'face rendered)
                       'acp-markdown-emphasis-face))))))

(ert-deftest acp-markdown-table-ragged ()
  (with-test-buffer "| A | B |
| - | - |
| 1 |
| 2 | 3 |
"
    (let* ((table (find-node "pipe_table"))
           (rendered (acp-markdown--render-node table)))
      (should (string= rendered
                       "\
┌───┬───┐
│ A │ B │
├───┼───┤
│ 1 │   │
│ 2 │ 3 │
└───┴───┘
")))))

(ert-deftest acp-markdown-table-single-column ()
  (with-test-buffer "| Only |
| ---- |
| one  |
| two  |
"
    (let* ((table (find-node "pipe_table"))
           (rendered (acp-markdown--render-node table)))
      (should (string= rendered
                       "\
┌──────┐
│ Only │
├──────┤
│ one  │
│ two  │
└──────┘
")))))

(ert-deftest acp-markdown-table-empty-body ()
  (with-test-buffer "| A | B |
| - | - |
"
    (let* ((table (find-node "pipe_table"))
           (rendered (acp-markdown--render-node table)))
      (should (string= rendered
                       "\
┌───┬───┐
│ A │ B │
├───┼───┤
└───┴───┘
")))))


(defun save-and-run-ert ()
  "Save the current buffer, evaluate it, and run all ERT tests."
  (interactive)
  (save-buffer)
  (eval-buffer)
  (ert t))

;; Bind it to a convenient key inside emacs-lisp-mode, like F5
(define-key emacs-lisp-mode-map (kbd "C-<return>") #'save-and-run-ert)

(provide 'acp-markdown-test)
