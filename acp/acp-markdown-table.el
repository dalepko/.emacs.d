;;; acp-markdown-table.el --- Table formatting for acp-markdown  -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'seq)
(require 'treesit)

(declare-function acp-markdown--render-node "acp-markdown")


(defun acp-markdown-table-format (table-node max-width)
  (pcase-let ((`(,header-node ,delim-node ,content-row-nodes)
               (acp-markdown-table--extract-header-delim-and-rows table-node)))
    (let* ((headers (acp-markdown-table--extract-and-render-cells header-node))
           (rows (mapcar #'acp-markdown-table--extract-and-render-cells content-row-nodes))
           (all-rows (cons headers rows))
           (all-rows-filled (acp-markdown-table--pad-rows all-rows))
           (columns (apply #'seq-mapn #'list all-rows-filled))
           (natural-sizes (mapcar (lambda (col)
                                    (apply #'max (mapcar #'string-width col)))
                                  columns))
           (ncols (length natural-sizes))
           (alignments (acp-markdown-table--extract-alignments delim-node ncols))
           (sizes (if max-width
                      (acp-markdown-table--distribute-column-widths
                       natural-sizes (- max-width (+ (* 3 (length natural-sizes)) 1)))
                    natural-sizes))
           (wrapped-rows (mapcar (lambda (row)
                                   (acp-markdown-table--wrap-row row sizes alignments))
                                 all-rows-filled)))
      (acp-markdown-table--build-box wrapped-rows sizes))))


(defun acp-markdown-table--distribute-column-widths (natural-sizes available)
  "Distribute AVAILABLE-WIDTH across NCOLS proportionally to NATURAL-SIZES."
  (let* ((total (apply #'+ natural-sizes)))
    (if (<= total available)
        natural-sizes
      (let ((previous-boundary 0)
            (accumulated-size 0)
            (computed-sizes ()))
        (dolist (size natural-sizes)
          (cl-incf accumulated-size size)
          (let ((boundary (/ (+ (* accumulated-size available) (1- total)) total)))
            (when (< boundary (+ previous-boundary 1))
              (setq boundary (1+ previous-boundary)))
            (push (- boundary previous-boundary) computed-sizes)
            (setq previous-boundary boundary)))
        (nreverse computed-sizes)))))

;; --- parsing ----------------------------------------------------------

(defun acp-markdown-table--extract-header-delim-and-rows (table-node)
  (let ((header-row nil)
        (delim-row nil)
        (content-rows nil))
    (dolist (child (treesit-node-children table-node t))
      (pcase (treesit-node-type child)
        ("pipe_table_header" (setq header-row child))
        ("pipe_table_delimiter_row" (setq delim-row child))
        ("pipe_table_row" (push child content-rows))))
    (list header-row delim-row (nreverse content-rows))))

(defun acp-markdown-table--extract-and-render-cells (row-node)
  (mapcar (lambda (cell) (string-trim-right (acp-markdown--render-node cell)))
          (treesit-node-children row-node t)))

(defun acp-markdown-table--extract-alignments (delim-row-node ncols)
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

(defun acp-markdown-table--pad-lists (lists fill-value)
  "Pad each list in LISTS to the same length with FILL-VALUE."
  (let ((target-len (apply #'max 0 (mapcar #'length lists))))
    (mapcar (lambda (lst)
              (let ((pad-len (- target-len (length lst))))
                (if (> pad-len 0)
                    (append lst (make-list pad-len fill-value))
                  lst)))
            lists)))

(defun acp-markdown-table--pad-rows (rows)
  "Pad each list in ROWS to the same length with empty strings."
  (acp-markdown-table--pad-lists rows ""))

;; --- formatting ----------------------------------------------------------

(defun acp-markdown-table--build-box (wrapped-rows sizes)
  "Build a box-drawing table from WRAPPED-ROWS with column SIZES.
Each element of wrapped-rows is a list of cells (each cell a list of lines)."
  (let* ((border-dash (lambda (s) (make-string (+ s 2) ?─)))
         (top (concat "┌" (mapconcat border-dash sizes "┬") "┐\n"))
         (sep (concat "├" (mapconcat border-dash sizes "┼") "┤\n"))
         (bot (concat "└" (mapconcat border-dash sizes "┴") "┘\n"))
         (header (acp-markdown-table--build-rows (car wrapped-rows) sizes))
         (body (mapcan (lambda (row) (acp-markdown-table--build-rows row sizes))
                       (cdr wrapped-rows))))
    (concat top
            (mapconcat #'identity header "")
            sep
            (mapconcat #'identity body "")
            bot)))

(defun acp-markdown-table--build-rows (cells sizes)
  "Build potentially multi-line rows from CELLS with column SIZES.
Each cell is a list of lines; returns a list of row strings."
  (let* ((max-lines (apply #'max 0 (mapcar #'length cells)))
         (padded-cells
          (cl-mapcar (lambda (cell width)
                       (let* ((blanks (make-string width ?\s))
                              (pad-len (- max-lines (length cell))))
                         (if (> pad-len 0)
                             (append cell (make-list pad-len blanks))
                           cell)))
                     cells sizes))
         (rows nil))
    (dotimes (lineno max-lines)
      (push (concat "│ "
                    (mapconcat (lambda (cell) (nth lineno cell))
                               padded-cells " │ ")
                    " │\n")
            rows))
    (nreverse rows)))

(defun acp-markdown-table--wrap-cell (text width alignment)
  "Wrap TEXT to fit WIDTH chars, returning list of padded lines."
  (if (<= (string-width text) width)
      (list (acp-markdown-table--pad-cell text width alignment))
    (let ((lines nil)
          (rem text))
      (while (>= (string-width rem) width)
        (let ((candidate (substring rem 0 (min (length rem) (1+ width)))))
          (if-let ((space (cl-position ?\s candidate :from-end t :test #'eq)))
              (progn
                (push (acp-markdown-table--pad-cell (substring rem 0 space) width alignment) lines)
                (setq rem (substring rem (1+ space))))
            (push (acp-markdown-table--pad-cell (substring rem 0 (min (length rem) width)) width alignment) lines)
            (setq rem (substring rem (min (length rem) width))))))
      (unless (string-empty-p rem)
        (push (acp-markdown-table--pad-cell (string-trim-left rem) width alignment) lines))
      (nreverse lines))))

(defun acp-markdown-table--wrap-row (row sizes alignments)
  "Wrap each cell in ROW to its allocated SIZES with ALIGNMENTS.
Returns a list of cells, each cell being a list of lines."
  (cl-mapcar #'acp-markdown-table--wrap-cell row sizes alignments))

(defun acp-markdown-table--pad-cell (cell width alignment)
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


(provide 'acp-markdown-table)
;;; acp-markdown-table.el ends here
