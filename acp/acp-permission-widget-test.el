;;; acp-permission-widget-test.el --- Tests for acp-permission-widget  -*- lexical-binding: t; -*-
(require 'ert)

(require 'acp-agent)
(require 'acp-permission-widget)
(require 'acp-diff)
(require 'acp-test-utils)

(defvar acp-permission-widget-test-dir
  (file-name-directory (or load-file-name
                           (macroexp-file-name)
                           default-directory))
  "Directory containing this test file.")


;; ── Tests ───────────────────────────────────────────────────────────────────

(defvar sample-kind-other-with-command
  (acp-permission-request--create
   :session-id "ses_120e484b3ffeNGhdr35ZYNVjmu"
   :request-id 0
   :tool-call
   (create-tool-call "other" "pending"
                     :title "external_directory"
                     :raw-input
                     (list :command
                           "Set-Content -Path \"$env:TEMP\\check-magit.el\" -Value ..."
                           :description
                           "Write temp elisp file"
                           :directories
                           '("C:\\Users\\david\\AppData\\Local\\Temp")
                           :patterns
                           '("C:\\Users\\david\\AppData\\Local\\Temp\\*"))
                     :locations '((:path "C:\\Users\\david\\AppData\\Local\\Temp")))
   :options
   '((:optionId "once" :kind "allow_once" :name "Allow once")
     (:optionId "always" :kind "allow_always" :name "Always allow")
     (:optionId "reject" :kind "reject_once" :name "Reject"))))


(ert-deftest acp-permission-widget-kind-other-with-command ()
  "When rawInput has :filepath instead of :description, show filepath."
  (with-temp-buffer
    (let ((w (widget-create 'acp-permission-widget :value sample-kind-other-with-command)))
      (should (equal (buffer-substring-no-properties (point-min) (point-max))
                     "

Permission request: external_directory

Write temp elisp file

Set-Content -Path \"$env:TEMP\\check-magit.el\" -Value ...

[ Allow once (y) ]  [ Always allow (!) ]  [ Reject (n) ]
"
                     )))))

;; ── Filepath-style rawInput ────────────────────────────────────────────────

(defvar sample-kind-other-with-filepath
  (acp-permission-request--create
   :session-id "ses_11ae4d0c8ffes826f1dLMwPJTY"
   :request-id 0
   :tool-call
   (create-tool-call "other" "pending"
                     :title "external_directory"
                     :raw-input
                     (list :filepath "C:\\Windows\\acp-test-file.txt"
                           :parentDir "C:\\Windows")
                     :locations '((:path "C:\\Windows\\acp-test-file.txt")
                                  (:path "C:\\Windows")))
   :options
   '((:optionId "once" :kind "allow_once" :name "Allow once")
     (:optionId "always" :kind "allow_always" :name "Always allow")
     (:optionId "reject" :kind "reject_once" :name "Reject"))))


(ert-deftest acp-permission-widget-kind-other-with-filepath ()
  "When rawInput has :filepath instead of :description, show filepath."
  (with-temp-buffer
    (let ((w (widget-create 'acp-permission-widget :value sample-kind-other-with-filepath)))
      (should (equal (buffer-substring-no-properties (point-min) (point-max))
                     "

Permission request: external_directory

Write file: C:\\Windows\\acp-test-file.txt

[ Allow once (y) ]  [ Always allow (!) ]  [ Reject (n) ]
")))))

;; ── Edit-kind permission ─────────────────────────────────────────────────────

(ert-deftest acp-permission-widget-kind-edit-with-diff ()
  "When kind is edit, show generated description and the diff."
  (with-tmp "some content\n" tmp-file
    (let ((edit-request
           (acp-permission-request--create
            :session-id "ses_test_edit_kind"
            :request-id 2
            :tool-call
            (create-tool-call "edit" "pending"
                              :title "edit_file"
                              :content
                              (list (acp-tool-call-diff--create
                                     :path tmp-file
                                     :oldText "some content"
                                     :newText "modified content")))
            :options
            '((:optionId "once" :kind "allow_once" :name "Allow once")
              (:optionId "always" :kind "allow_always" :name "Always allow")
              (:optionId "reject" :kind "reject_once" :name "Reject")))))
      (with-temp-buffer
        (let ((w (widget-create 'acp-permission-widget :value edit-request)))
          (should (equal (buffer-substring-no-properties (point-min) (point-max)) (format "

Permission request: edit_file

Edit file: %s

@@ -1 +1 @@
-some content
+modified content

[ Allow once (y) ]  [ Always allow (!) ]  [ Reject (n) ]
" tmp-file))))))))

;; ── Edit-kind with raw-input diff ────────────────────────────────────────────

(ert-deftest acp-permission-widget-kind-edit-with-raw-input ()
  "When kind is edit with raw-input :filepath and :diff, show cleaned diff."
  (let* ((sample-diff "\
Index: test-file.el
===================================================================
--- a/test-file.el
+++ b/test-file.el
@@ -1 +1 @@
-old content
+new content
")
         (edit-request
          (acp-permission-request--create
           :session-id "ses_test_raw_edit"
           :request-id 3
           :tool-call
           (create-tool-call "edit" "pending"
                             :title "edit_file"
                             :raw-input
                             (list :filepath "test-file.el"
                                   :diff sample-diff))
           :options
           '((:optionId "once" :kind "allow_once" :name "Allow once")
             (:optionId "always" :kind "allow_always" :name "Always allow")
             (:optionId "reject" :kind "reject_once" :name "Reject")))))
    (with-temp-buffer
      (let ((w (widget-create 'acp-permission-widget :value edit-request)))
        (should (equal (buffer-substring-no-properties (point-min) (point-max)) "

Permission request: edit_file

Edit file: test-file.el

@@ -1 +1 @@
-old content
+new content

[ Allow once (y) ]  [ Always allow (!) ]  [ Reject (n) ]
"))))))

;; ── Execute-kind permission ──────────────────────────────────────────────────

;; opencode format: title is short, no content
(defvar sample-kind-execute
  (acp-permission-request--create
   :session-id "ses_test_execute"
   :request-id 5
   :tool-call
   (create-tool-call "execute" "pending"
                     :title "execute"
                     :raw-input
                     (list :command "emacs --batch -L acp -l acp-permission-widget-test -f ert-run-tests-batch 2>&1"
                           :timeout 30000
                           :description "Run permission widget tests"))
   :options
   '((:optionId "allow" :kind "allow_once" :name "Allow")
     (:optionId "allow_always" :kind "allow_always" :name "Always Allow")
     (:optionId "reject" :kind "reject_once" :name "Reject"))))

(ert-deftest acp-permission-widget-kind-execute ()
  "When kind is execute, show command with Execute command: label."
  (with-temp-buffer
    (let ((w (widget-create 'acp-permission-widget :value sample-kind-execute)))
      (should (equal (buffer-substring-no-properties (point-min) (point-max)) "

Permission request: execute

Execute command:

emacs --batch -L acp -l acp-permission-widget-test -f ert-run-tests-batch 2>&1

[ Allow (y) ]  [ Always Allow (!) ]  [ Reject (n) ]
")))))

;; claude-code format: title is full command, content has description
(defvar sample-kind-execute-claude-code
  (acp-permission-request--create
   :session-id "321c03af-1e53-4c18-a999-d15b061438ff"
   :request-id 8
   :tool-call
   (create-tool-call "execute" "pending"
                     :title "emacs --batch -L acp -l acp-permission-widget-test -f ert-run-tests-batch 2>&1"
                     :content
                     (list (acp-tool-call-content--create
                            :type "text"
                            :text "Run permission widget tests"))
                     :raw-input
                     (list :command "emacs --batch -L acp -l acp-permission-widget-test -f ert-run-tests-batch 2>&1"
                           :description "Run permission widget tests"))
   :options
   '((:optionId "allow_always" :kind "allow_always" :name "Always Allow")
     (:optionId "allow" :kind "allow_once" :name "Allow")
     (:optionId "reject" :kind "reject_once" :name "Reject"))))

(ert-deftest acp-permission-widget-kind-execute-claude-code ()
  "Claude-code format: title uses content description, not the full command."
  (with-temp-buffer
    (let ((w (widget-create 'acp-permission-widget :value sample-kind-execute-claude-code)))
      (should (equal (buffer-substring-no-properties (point-min) (point-max)) "

Permission request: Run permission widget tests

Execute command:

emacs --batch -L acp -l acp-permission-widget-test -f ert-run-tests-batch 2>&1

[ Always Allow (!) ]  [ Allow (y) ]  [ Reject (n) ]
")))))

;; ── Edit-kind with nil oldText (new file creation) ──────────────────────────

(ert-deftest acp-permission-widget-kind-edit-nil-oldtext ()
  "When kind is edit with nil oldText, show diff for new file creation."
  (let ((edit-request
         (acp-permission-request--create
          :session-id "ses_test_new_file"
          :request-id 4
          :tool-call
          (create-tool-call "edit" "pending"
                            :title "create_file"
                            :content
                            (list (acp-tool-call-diff--create
                                   :path "/tmp/new-file.txt"
                                   :oldText nil
                                   :newText "new file content\n")))
          :options
          '((:optionId "once" :kind "allow_once" :name "Allow once")
            (:optionId "always" :kind "allow_always" :name "Always allow")
            (:optionId "reject" :kind "reject_once" :name "Reject")))))
    (with-temp-buffer
      (let ((w (widget-create 'acp-permission-widget :value edit-request)))
        (should (equal (buffer-substring-no-properties (point-min) (point-max)) "

Permission request: create_file

Edit file: /tmp/new-file.txt

@@ -0,0 +1 @@
+new file content

[ Allow once (y) ]  [ Always allow (!) ]  [ Reject (n) ]
"))))))

;; ── Interactive test utility ─────────────────────────────────────────────────

(defun acp-permission-widget-test ()
  "Open a test buffer with sample permission request widgets."
  (interactive)
  (let* ((inhibit-read-only t)
         (diff-file (expand-file-name "acp-diff.el" acp-permission-widget-test-dir)))
    (switch-to-buffer (get-buffer-create "*acp-permission-widget-test*"))
    (erase-buffer)
    (widget-create 'acp-permission-widget :value sample-kind-other-with-command)
    (widget-insert "\n")
    (widget-create 'acp-permission-widget :value sample-kind-other-with-filepath)
    (widget-insert "\n")
    (widget-create 'acp-permission-widget :value
                   (acp-permission-request--create
                    :session-id "ses_12testdiff123"
                    :request-id 1
                    :tool-call
                    (create-tool-call "edit" "pending"
                                      :title "edit_file"
                                      :content
                                      (list (acp-tool-call-diff--create
                                             :path diff-file
                                             :oldText "acp-diff-create-and-format"
                                             :newText "acp-diff-create-and-format-xxx")))
                    :options
                    '((:optionId "once" :kind "allow_once" :name "Allow once")
                      (:optionId "always" :kind "allow_always" :name "Always allow")
                      (:optionId "reject" :kind "reject_once" :name "Reject"))))
    (widget-insert "\n")
    (widget-insert (propertize "Click a button above to test.\n\n"
                               'face 'font-lock-comment-face))
    (widget-setup)
    (use-local-map widget-keymap)
    (goto-char (point-min))))

(provide 'acp-permission-widget-test)
;;; acp-permission-widget-test.el ends here
