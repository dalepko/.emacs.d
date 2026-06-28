;;; acp-changes-summary-widget-test.el --- Tests for acp-changes-summary-widget  -*- lexical-binding: t; -*-
(require 'ert)
(require 'cl-lib)

(require 'acp-changes-summary-widget)
(require 'acp-test-utils)

(defun acp-changes-summary--intervals-without (props str)
  "Return intervals of STR without the given PROPS."
  (cl-loop for (s . plist) in (intervals str)
           collect (cons s (cl-loop for (k v) on plist by #'cddr
                                    unless (memq k props)
                                    append (list k v)))))

(ert-deftest acp-changes-summary-widget-renders ()
  "acp-changes-summary-widget displays filename and added/removed counts."
  (with-temp-buffer
    (widget-create 'acp-changes-summary-widget
                   :value '((:filename "a.el" :added 3 :removed 0 :diff "")
                            (:filename "b.el" :added 1 :removed 2 :diff "")))
    (widget-setup)
    (let ((content (buffer-string)))
      (should (equal (acp-changes-summary--intervals-without
                      '(keymap acp-changes-summary-entry) content)
                     `(("\n" face (:underline t :extend t))
                       ("modified  " face (:weight bold))
                       ("a.el" face (:weight bold))
                       (" " display (space :align-to (- right 11)))
                       ("+3" face acp-changes-summary-added-face)
                       (" ")
                       ("\n")
                       ("modified  " face (:weight bold))
                       ("b.el" face (:weight bold))
                       (" " display (space :align-to (- right 11)))
                       ("+1" face acp-changes-summary-added-face)
                       (" ")
                       ("-2" face acp-changes-summary-removed-face)
                       ("\n")))))))

(ert-deftest acp-changes-summary-row-has-keymap-property ()
  "Each row has the keymap and entry text properties."
  (with-temp-buffer
    (widget-create 'acp-changes-summary-widget
                   :value '((:filename "a.el" :added 3 :removed 0 :diff "")
                            (:filename "b.el" :added 1 :removed 2 :diff "")))
    (widget-setup)
    (should (eq (get-char-property 2 'keymap) acp-changes-summary-keymap))
    (let ((e (get-char-property 2 'acp-changes-summary-entry)))
      (should (equal (plist-get e :filename) "a.el")))))

(ert-deftest acp-changes-summary-toggle-expand ()
  "TAB on a row expands the diff below it."
  (with-temp-buffer
    (widget-create 'acp-changes-summary-widget
                   :value '((:filename "a.el" :added 1 :removed 0 :diff
                                       "@@ -1,1 +1,1 @@\n-old\n+new\n")))
    (widget-setup)
    (goto-char 2)
    (call-interactively 'acp-changes-summary-toggle-diff)
    (let ((content (buffer-string)))
      (should (string-match "\\`\nmodified  a\\.el.*\n@@ -1,1 \\+1,1 @@" content))
      (should (string-match "old\n" content))
      (should (string-match "new\n" content)))))

(ert-deftest acp-changes-summary-toggle-collapse ()
  "TAB on an expanded row collapses the diff."
  (with-temp-buffer
    (widget-create 'acp-changes-summary-widget
                   :value '((:filename "a.el" :added 1 :removed 0 :diff
                                       "@@ -1,1 +1,1 @@\n-old\n+new\n")))
    (widget-setup)
    (goto-char 2)
    (call-interactively 'acp-changes-summary-toggle-diff)
    (goto-char 2)
    (call-interactively 'acp-changes-summary-toggle-diff)
    (let ((content (buffer-string)))
      (should (string-match "a\\.el" content))
      (should-not (string-match "old\n" content))
      (should-not (string-match "new\n" content)))))
  
(ert-deftest acp-changes-summary--resolve-on-file-header ()
  (with-temp-buffer
    (widget-create 'acp-changes-summary-widget
                   :value '((:filename "a.el" :added 1 :removed 0 :diff
                                       "@@ -1,1 +1,1 @@\n-old\n+new\n")))
    (goto-char 2)
    (should (equal (acp-changes-summary--resolve-diff-position)
                   '("a.el" nil)))))


(ert-deftest acp-changes-summary--resolve-on-hunk-header ()
  (with-temp-buffer
    (widget-create 'acp-changes-summary-widget
                   :value '((:filename "a.el" :added 1 :removed 0 :diff
                                       "@@ -1,1 +14,1 @@\n-old\n+new\n")))
    (goto-char 2)
    (call-interactively 'acp-changes-summary-toggle-diff)
    (forward-line 1)
    (should (equal (acp-changes-summary--resolve-diff-position)
                   '("a.el" 14)))))

(ert-deftest acp-changes-summary--resolve-on-deleted-line ()
  (with-temp-buffer
    (widget-create 'acp-changes-summary-widget
                   :value '((:filename "a.el" :added 1 :removed 0 :diff
                                       "@@ -1,5 +5,4 @@
 context1
 context2
-removed
 context3
 context3
")))
    (goto-char 2)
    (call-interactively 'acp-changes-summary-toggle-diff)
    (forward-line 4)
    (should (equal (acp-changes-summary--resolve-diff-position)
                   '("a.el" 6)))))


(ert-deftest acp-changes-summary--resolve-on-added-line ()
  (with-temp-buffer
    (widget-create 'acp-changes-summary-widget
                   :value '((:filename "a.el" :added 1 :removed 0 :diff
                                       "@@ -1,5 +5,5 @@
 context1
 context2
-removed
+added
 context3
 context3
")))
    (goto-char 2)
    (call-interactively 'acp-changes-summary-toggle-diff)
    (forward-line 5)
    (should (equal (acp-changes-summary--resolve-diff-position)
                   '("a.el" 7)))))

  
(defun acp-changes-summary-test ()
  "Open temp buffer displaying changes summary widgets for visual inspection."
  (interactive)
  (let ((buf (get-buffer-create "*acp-changes-summary-test*"))
        (sample (acp-diff-parse "\
diff --git a/foo.el b/foo.el
--- a/foo.el
+++ b/foo.el
@@ -1,3 +1,4 @@
  unchanged
+added
+added2
-removed
diff --git a/bar.el b/bar.el
--- a/bar.el
+++ b/bar.el
@@ -5,3 +5,2 @@
  ctx
-removed1
-removed2
")))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert "\
- acp.el: Added defvar declarations
- acp-prompt-widget.el: Moved defvar acp-prompt-widget-keymap before functions that reference it
- acp-permission-widget.el: Prefixed unused button/event args with _
- acp-markdown-test.el, acp-changes-summary-widget-test.el: Shortened overlong docstrings
")
        (widget-create 'acp-changes-summary-widget :value sample)
        (insert "> ")
        (widget-setup)))
    (pop-to-buffer buf)))

(provide 'acp-changes-summary-widget-test)
;;; acp-changes-summary-widget-test.el ends here
