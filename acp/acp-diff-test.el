;;; acp-diff-test.el --- Tests for acp-diff  -*- lexical-binding: t; -*-
(require 'ert)

(require 'acp-diff)
(require 'acp-test-utils)

(ert-deftest acp-diff-create-existing-file-applies ()
  "Patch applies against an existing file — returns unified diff."
  (with-tmp "line1\nline2\nline3\n" temp-file 
    (let ((diff (acp-diff-create temp-file "line2" "LINE2")))
      (should (equal diff "\
@@ -1,3 +1,3 @@
 line1
-line2
+LINE2
 line3
")))))
      

(ert-deftest acp-diff-create-existing-file-patch-not-apply ()
  "old-text not found in existing file — signals error."
  (with-tmp "line1\nline2\nline3\n" temp-file
    (should-error (acp-diff-create temp-file "nonexistent" "replacement"))))

(ert-deftest acp-diff-create-non-existing-file ()
  "File does not exist — treated as empty; new content added."
  (let ((diff (acp-diff-create "./nonexisting-file" "" "new content\n")))
    (should (equal diff "\
@@ -0,0 +1 @@
+new content
"))))

(ert-deftest acp-diff-format-works ()
  "acp-diff-format propertizes diff lines with appropriate faces."
  (let ((diff "\
@@ -1,3 +1,3 @@
 line1
-line2
+LINE2
 line3
"))
    (should (equal (intervals (acp-diff-format diff))
                   `(("@@ -1,3 +1,3 @@\n" face acp-diff-hunk-heading-face)
                     (" line1\n" face acp-diff-context-face)
                     ("-line2\n" face acp-diff-removed-face)
                     ("+LINE2\n" face acp-diff-added-face)
                     (" line3\n" face acp-diff-context-face))))))

(ert-deftest acp-diff-create-and-format-works ()
  "acp-diff-create-and-format creates and formats a diff in one step."
  (with-tmp "line1\nline2\nline3\n" temp-file
    (should (equal (intervals (acp-diff-create-and-format temp-file "line2" "LINE2"))
                   `(("@@ -1,3 +1,3 @@\n" face acp-diff-hunk-heading-face)
                     (" line1\n" face acp-diff-context-face)
                     ("-line2\n" face acp-diff-removed-face)
                     ("+LINE2\n" face acp-diff-added-face)
                     (" line3\n" face acp-diff-context-face))))))

(ert-deftest acp-diff-parse-multi-file ()
  "acp-diff-parse splits a multi-file patch into per-file plists."
  (let* ((patch "\
diff --git a/foo.el b/foo.el
--- a/foo.el
+++ b/foo.el
@@ -1,1 +1,1 @@
-old
+new
diff --git a/bar.el b/bar.el
--- a/bar.el
+++ b/bar.el
@@ -5,3 +5,4 @@
 unchanged
-removed
+added
")
         (result (acp-diff-parse patch)))
    (should (equal result '((:filename "foo.el" :added 1 :removed 1 :diff "\
@@ -1,1 +1,1 @@
-old
+new
" )
                            (:filename "bar.el" :added 1 :removed 1 :diff "\
@@ -5,3 +5,4 @@
 unchanged
-removed
+added
"
))))))


(ert-deftest acp-diff-parse-empty ()
  "acp-diff-parse returns nil for empty input."
  (should (null (acp-diff-parse nil)))
  (should (null (acp-diff-parse ""))))

(provide 'acp-diff-test)
;;; acp-diff-test.el ends here
