;;; acp-markdown.el --- Render markdown inline nodes from tree-sitter  -*- lexical-binding: t; -*-

(require 'treesit)
(require 'seq)

(defgroup acp-markdown nil
  "Render markdown inline nodes from tree-sitter."
  :group 'text)

(defface acp-markdown-emphasis-face
  '((t :slant italic))
  "Face for markdown emphasis (*italic*)."
  :group 'acp)

(defface acp-markdown-strong-face
  '((t :weight bold))
  "Face for markdown strong emphasis (**bold**)."
  :group 'acp)

(defface acp-markdown-strikethrough-face
  '((t :strike-through t))
  "Face for markdown strikethrough (~~strikethrough~~)."
  :group 'acp)

(defface acp-markdown-code-face
  '((t :inherit font-lock-builtin-face))
  "Face for markdown inline code (`code`)."
  :group 'acp)

(defface acp-markdown-code-block-face
  '((t :background "gray20" :extend t))
  "Face for markdown inline code (`code`)."
  :group 'acp)

(defface acp-markdown-heading-1-face
  '((t :inherit variable-pitch :weight bold :height 2.0))
  "Face for markdown heading level 1."
  :group 'acp)

(defface acp-markdown-heading-2-face
  '((t :inherit variable-pitch :weight bold :height 1.5))
  "Face for markdown heading level 2."
  :group 'acp)

(defface acp-markdown-heading-3-face
  '((t :inherit variable-pitch :weight bold :height 1.17))
  "Face for markdown heading level 3."
  :group 'acp)

(defface acp-markdown-heading-4-face
  '((t :inherit variable-pitch :weight bold :height 1.0))
  "Face for markdown heading level 4."
  :group 'acp)

(defface acp-markdown-block-quote-face
  '((t :inherit italic :background "grey50"))
  "Face for markdown block quotes."
  :group 'acp)

(defface acp-markdown-thematic-break-face
  '((t :foreground "grey50" :extend t :overline t :height 0.1))
  "Face for markdown thematic breaks."
  :group 'acp)

(defface acp-markdown-link-face
  '((t :underline t :foreground "light blue"))
  "Face for markdown links."
  :group 'acp)

(defun acp-markdown-buffer-create ()
  (let ((buf (generate-new-buffer " *acp-markdown*")))
    (with-current-buffer buf
      (treesit-parser-create 'markdown)
      (setq treesit-range-settings
            (treesit-range-rules
             :embed 'markdown-inline
             :host 'markdown
             :local t
             '(((inline) @capture)
               ((pipe_table_cell) @capture)))))
    buf))

(defun acp-markdown-render (buffer)
  (with-current-buffer buffer
    (treesit-update-ranges)
    (let ((root (treesit-parser-root-node (car (treesit-parser-list nil 'markdown)))))
      (acp-markdown--render-node root))))

(defun acp-markdown--render-node (node)
  (if (not (treesit-node-check node 'named))
      (treesit-node-text node)
    (pcase (treesit-node-type node)
      ("emphasis_delimiter" "")
      ("emphasis"
       (acp-markdown--add-face (acp-markdown--render-inline node) 'acp-markdown-emphasis-face))
      ("strong_emphasis"
       (acp-markdown--add-face (acp-markdown--render-inline node) 'acp-markdown-strong-face))
      ("strikethrough"
        (acp-markdown--add-face (acp-markdown--render-inline node) 'acp-markdown-strikethrough-face))
      ("backslash_escape"
       (substring (treesit-node-text node) 1))
      ((or "inline" "pipe_table_cell")
       (if (eq (treesit-node-language node) 'markdown)
           (let ((inline-node (treesit-node-on (treesit-node-start node)
                                               (treesit-node-end node)
                                               'markdown-inline)))
             (acp-markdown--render-inline inline-node))
         (acp-markdown--render-inline node)))
      ("atx_heading"
       (let* ((marker (car (treesit-node-children node)))
              (level (length (treesit-node-text marker)))
              (content (treesit-node-child-by-field-name node "heading_content")))
         (acp-markdown--add-face (concat (if content (acp-markdown--render-node content) "") "\n")
                                 (acp-markdown--heading-face level))))
      ("code_span"
       (acp-markdown--add-face (acp-markdown--render-inline node) 'acp-markdown-code-face))
      ("code_span_delimiter" "")
      ("inline_link"
       (let* ((text-node (treesit-search-subtree node "link_text"))
              (dest-node (treesit-search-subtree node "link_destination"))
              (text (if text-node (treesit-node-text text-node) ""))
              (url (if dest-node (treesit-node-text dest-node) "")))
         (propertize text
                     'face 'acp-markdown-link-face
                     'url url)))
      ("shortcut_link"
       (let* ((text-node (treesit-search-subtree node "link_text"))
              (text (if text-node (treesit-node-text text-node) "")))
         (if (string-match-p "\\`https?://\\|\\`www\\." text)
             (propertize text
                         'face 'acp-markdown-link-face
                         'url text)
           text)))
      ("uri_autolink"
       (let* ((raw (treesit-node-text node))
              (url (substring raw 1 -1)))
         (propertize url
                     'face 'acp-markdown-link-face
                     'url url)))
      ("link_text" "")
      ("link_destination" "")
      ("link_title" "")
      ("atx_h1_marker" "")
      ("atx_h2_marker" "")
      ("atx_h3_marker" "")
      ("atx_h4_marker" "")
      ("atx_h5_marker" "")
      ("atx_h6_marker" "")
      ("thematic_break"
       (propertize "\n" 'face 'acp-markdown-thematic-break-face))
      ("block_quote"
       (propertize (acp-markdown--render-inline node)
                   'line-prefix (concat (propertize " " 'face 'acp-markdown-block-quote-face) " ")))
      ("block_quote_marker" "")
      ("block_continuation" "")
      ("indented_code_block"
       (let* ((text (acp-markdown--extract-code-block node))
              (text (concat (replace-regexp-in-string "\\` *" "" text))))
         (if (string-suffix-p "\n\n" text)
             ;; move trailing \n out of the code block
             (concat
              (acp-markdown--add-face (substring text 0 (- (length text) 1)) 'acp-markdown-code-block-face)
              "\n")
           (acp-markdown--add-face text  'acp-markdown-code-block-face))))
      ("fenced_code_block"
       (let* ((content-node (treesit-search-subtree node "code_fence_content"))
              (text (if content-node (acp-markdown--extract-code-block content-node) "\n"))
              (lang-node (treesit-search-subtree node "language")))
         (when lang-node
           (setq text (acp-markdown--fontify (treesit-node-text lang-node) text)))
         (propertize (acp-markdown--add-face text 'acp-markdown-code-block-face))))
      ("fenced_code_block_delimiter" "")
      ("info_string" "")
      ("code_fence_content" "")
      ("list_item"
       (let* ((nodes (treesit-node-children node))
              (first (car nodes))
              (marker (if (and first
                                 (string-prefix-p "list_marker_" (treesit-node-type first)))
                           first))
              (children (if marker (cdr nodes) nodes))
              (content (acp-markdown--render-inline node (treesit-node-start (car children))))
              (marker-type (if marker (treesit-node-type marker)))
              (bullet (if (and marker
                               (or (string= marker-type "list_marker_dot")
                                   (string= marker-type "list_marker_parenthesis")))
                          (treesit-node-text marker)
                        "• "))
              (prefix (propertize
                       (if marker (treesit-node-text marker) "* ")
                       'line-prefix bullet
                       'display "")))
         (concat prefix (acp-markdown--indent content (make-string (length bullet) ?\s)))))
      ((pred (string-prefix-p "list_marker_")) "")
      ("pipe_table"
       (acp-markdown--format-table node))
      ("hard_line_break" "\n")
      ((or "document" "paragraph" "section" "list" "html_tag")
       (acp-markdown--render-inline node))
      (">" "")
      ("ERROR" (treesit-node-text node))
      (_ (error "unknown node %s" (treesit-node-type node))))))

(defun acp-markdown--render-inline (node &optional offset)
  (let* ((node-start (treesit-node-start node))
         (node-end (treesit-node-end node))
         (children (treesit-node-children node))
         (parts nil)
         (offset (or offset node-start)))
  (dolist (child children)
    (let ((child-start (treesit-node-start child))
          (child-end (treesit-node-end child)))
      (when (< offset child-start)
        (push (buffer-substring-no-properties offset child-start) parts))
      (push (acp-markdown--render-node child) parts)
      (setq offset child-end)))
  (when (< offset node-end)
    (push (buffer-substring-no-properties offset node-end) parts))
  (apply #'concat (nreverse parts))))


(defun acp-markdown--add-face (text face)
  (add-face-text-property 0 (length text) face t text)
  text)

(defun acp-markdown--heading-face (level)
  (intern (format "acp-markdown-heading-%d-face" (min 4 level))))

(defun acp-markdown--indent (string indent)
  (let* ((start 0)
         (current-prefix (get-text-property start 'line-prefix string)))
    (while-let ((end (next-single-property-change start 'line-prefix string)))
      (add-text-properties start end `(line-prefix ,(if current-prefix (concat indent current-prefix) indent)) string)
      (setq start end)
      (setq current-prefix (get-text-property start 'line-prefix string)))
    (when (< start (length string))
      (add-text-properties start (length string) `(line-prefix ,(if current-prefix (concat indent current-prefix) indent)) string)))
  string)


(defun acp-markdown--extract-code-block (node)
  (let ((content (treesit-node-text node))
        (node-start (treesit-node-start node))
        (block-continuations (seq-filter (lambda (child) (equal (treesit-node-type child) "block_continuation"))
                                         (treesit-node-children node)))
        (offset 0)
        (parts nil))
    (dolist (continuation block-continuations)
      (let ((start (treesit-node-start continuation))
            (end (treesit-node-end continuation)))
        (push (substring content offset (- start node-start)) parts)
        (setq offset (- end node-start))))
    (when (< offset (length content))
      (push (substring content offset) parts))
    (apply #'concat (nreverse parts))))

(defun acp-markdown--format-table (table-node)
  (pcase-let ((`(,header-node ,delim-node ,content-row-nodes)
               (acp-markdown--extract-header-delim-and-rows table-node)))
    (let* ((headers (acp-markdown--extract-and-render-cells header-node))
           (rows (mapcar #'acp-markdown--extract-and-render-cells content-row-nodes))
           (all-rows (cons headers rows))
           (all-rows-filled (acp-markdown--pad-rows all-rows))
           (columns (apply #'seq-mapn #'list all-rows-filled))
           (columns-size (mapcar (lambda (column)
                                   (apply #'max (mapcar #'string-width column))) columns))
           (alignments (acp-markdown--extract-alignments delim-node (length columns)))
           (padded-columns (seq-mapn #'acp-markdown--pad-column columns columns-size alignments))
           (padded-rows (apply #'seq-mapn #'list padded-columns)))
      (concat "┌" (mapconcat (lambda (size) (make-string (+ size 2) ?─)) columns-size "┬") "┐\n"
              (acp-markdown--build-table-row (car padded-rows))
              "├" (mapconcat (lambda (size) (make-string (+ size 2) ?─)) columns-size "┼") "┤\n"
              (mapconcat #'acp-markdown--build-table-row (cdr padded-rows) "")
              "└" (mapconcat (lambda (size) (make-string (+ size 2) ?─)) columns-size "┴") "┘\n"))))

(defun acp-markdown--extract-header-delim-and-rows (table-node)
  (let ((header-row nil)
        (delim-row nil)
        (content-rows nil))
    (dolist (child (treesit-node-children table-node t))
      (pcase (treesit-node-type child)
        ("pipe_table_header" (setq header-row child))
        ("pipe_table_delimiter_row" (setq delim-row child))
        ("pipe_table_row" (push child content-rows))))
    (list header-row delim-row (nreverse content-rows))))

(defun acp-markdown--extract-alignments (delim-row-node ncols)
  (let ((result nil))
    (dolist (delim (treesit-node-children delim-row-node t))
      (let ((alignment nil))
        (dolist (align-marker (treesit-node-children delim t))
          (pcase (treesit-node-type align-marker)
            ("pipe_table_align_left" (setq alignment :left))
            ((and "pipe_table_align_right" (guard (eq alignment :left))) (setq alignment :center))
            ("pipe_table_align_right" (setq alignment :right))))
        (push (or alignment :left) result)))
    (setq result (nreverse result))
    (if (< (length result) ncols)
        (append result (make-list (- ncols (length result)) :left))
      result)))

(defun acp-markdown--extract-and-render-cells (row-node)
  (mapcar (lambda (cell) (string-trim-right (acp-markdown--render-node cell)))
          (treesit-node-children row-node t)))

(defun acp-markdown--build-table-row (cells)
  (concat "│ " (mapconcat #'identity cells " │ ") " │\n"))

(defun acp-markdown--pad-column (column width alignment)
  (mapcar (lambda (cell) (acp-markdown--pad-cell cell width alignment)) column))

(defun acp-markdown--pad-cell (cell width alignment)
  "Pad CELL to WIDTH chars according to ALIGNMENT (:left :center :right)."
  (let* ((w (string-width cell))
         (pad (- width w)))
    (if (<= pad 0)
        cell
      (pcase alignment
        (:right  (concat (make-string pad ?\s) cell))
        (:center (let ((left  (/ pad 2))
                       (right (- pad (/ pad 2))))
                   (concat (make-string left ?\s) cell (make-string right ?\s))))
        (_       (concat cell (make-string pad ?\s)))))))

(defun acp-markdown--pad-rows (rows)
  "Pad each list in ROWS to the same length with empty strings."
  (let ((max-cols (apply #'max (mapcar #'length rows))))
    (mapcar (lambda (row)
              (let ((pad-len (- max-cols (length row))))
                (if (> pad-len 0)
                    (append row (make-list pad-len ""))
                  row)))
            rows)))

(defvar acp-markdown--language-modes
  '(("elisp" . emacs-lisp-mode)
    ("emacs-lisp" . emacs-lisp-mode)
    ("lisp" . lisp-mode)
    ("scheme" . scheme-mode)
    ("python" . python-mode)
    ("py" . python-mode)
    ("js" . javascript-mode)
    ("javascript" . javascript-mode)
    ("ts" . typescript-mode)
    ("typescript" . typescript-mode)
    ("c" . c-mode)
    ("cpp" . c++-mode)
    ("c++" . c++-mode)
    ("rust" . rust-mode)
    ("go" . go-mode)
    ("sh" . sh-mode)
    ("bash" . sh-mode)
    ("shell" . sh-mode)
    ("make" . makefile-mode)
    ("makefile" . makefile-mode)
    ("css" . css-mode)
    ("html" . html-mode)
    ("xml" . xml-mode)
    ("json" . javascript-mode)
    ("java" . java-mode)
    ("perl" . perl-mode)
    ("ruby" . ruby-mode)
    ("sql" . sql-mode)
    ("diff" . diff-mode)
    ("conf" . conf-mode)
    ("ini" . conf-mode)
    ("yaml" . yaml-mode)))

(defun acp-markdown--fontify (language code)
  (let ((mode (cdr (assoc language acp-markdown--language-modes))))
    (if (and mode (fboundp mode))
        (with-temp-buffer
          (delay-mode-hooks (funcall mode))
          (insert code)
          (font-lock-set-defaults)
          (let ((font-lock-mode t))
            (font-lock-default-fontify-region (point-min) (point-max) nil))
          (buffer-string))
      code)))


(provide 'acp-markdown)
;;; acp-markdown.el ends here
