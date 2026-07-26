;;; acp-markdown-table-test.el --- Tests for acp-markdown-table  -*- lexical-binding: t; -*-
(require 'ert)
(require 'acp-markdown-test)  ;; for with-test-buffer, find-node, intervals
(require 'acp-markdown-table)

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



(ert-deftest  acp-markdown-table-distribute-column-widths-ok ()
  (let ((result (acp-markdown-table--distribute-column-widths '(3 4) 7)))
    (should (equal result '(3 4)))))


(ert-deftest  acp-markdown-table-distribute-column-widths-one-of ()
  (let ((result (acp-markdown-table--distribute-column-widths '(3 4) 6)))
    (should (equal result '(3 3)))))

(ert-deftest  acp-markdown-table-distribute-column-widths-one-of-with-small-columns ()
  (let ((result (acp-markdown-table--distribute-column-widths '(1 1 1 4) 6)))
    (should (equal result '(1 1 1 3)))))

(ert-deftest  acp-markdown-table-distribute-column-widths-one-column ()
  (let ((result (acp-markdown-table--distribute-column-widths '(53) 6)))
    (should (equal result '(6)))))

(ert-deftest  acp-markdown-table-distribute-column-widths-half-columns ()
  (let ((result (acp-markdown-table--distribute-column-widths '(10 12 18) 20)))
    (should (equal result '(5 6 9)))))


(ert-deftest acp-markdown-table-wrap ()
  (with-test-buffer "| C1 | C2 |
| -- | -- |
| x  | this text wraps |
"
    (let* ((table (find-node "pipe_table"))
           (rendered (acp-markdown-table-format table 20)))
      (should (string= rendered
                       "\
┌────┬─────────────┐
│ C1 │ C2          │
├────┼─────────────┤
│ x  │ this text   │
│    │ wraps       │
└────┴─────────────┘
")))))


(provide 'acp-markdown-table-test)
;;; acp-markdown-table-test.el ends here
