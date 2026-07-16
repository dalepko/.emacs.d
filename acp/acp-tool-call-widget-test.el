;;; acp-tool-call-widget-test.el --- Tests for acp-tool-call-widget  -*- lexical-binding: t; -*-
(require 'ert)

(require 'acp-agent)
(require 'acp-tool-call-widget)
(require 'acp-test-utils)

;; ── Helpers ─────────────────────────────────────────────────────────────────

(defun tcw--render (tool-call)
  (let ((text (with-temp-buffer
               (cl-letf (((symbol-function 'acp-icon-get)
                          (lambda (_kind &rest _)
                            (list 'image :type 'xbm :width 8 :height 8 :data [0]))))
                 (widget-create 'acp-tool-call-widget :value tool-call)
                 (buffer-substring (point-min) (point-max))))))
    (remove-list-of-text-properties
     0 (length text)
     '(display keymap rear-nonsticky inhibit-isearch mouse-face context-menu-functions)
     text)
    (intervals text)))

;; ── Label tests (one per kind) ──────────────────────────────────────────────

(ert-deftest acp-tool-call-widget--label-think ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "think" "pending" :title "Explore the codebase"))
                 "Explore the codebase")))

(ert-deftest acp-tool-call-widget--label-read ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "read" "pending" :title "Read acp.el"
                             :locations '((:path "acp.el"))))
                 "Reading acp.el")))

(ert-deftest acp-tool-call-widget--label-edit ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "edit" "pending" :title "Refactor function"
                             :locations '((:path "src/main.go"))))
                 "Editing main.go")))

(ert-deftest acp-tool-call-widget--label-delete ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "delete" "pending" :title "Delete temp file"
                             :locations '((:path "tmp/old.txt"))))
                 "Deleting old.txt")))

(ert-deftest acp-tool-call-widget--label-move ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "move" "pending" :title "Move file"
                             :locations '((:path "src/a.go"))))
                 "Moving a.go")))

(ert-deftest acp-tool-call-widget--label-search ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "search" "pending" :title "Search function defs"))
                 "Search function defs")))

(ert-deftest acp-tool-call-widget--label-execute ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "execute" "pending" :title "npm test"))
                 "npm test")))

(ert-deftest acp-tool-call-widget--label-execute-claude-code ()
  "Claude-code format: label uses description from raw-input"
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "execute" "pending"
                                    :title "emacs --batch -L acp -l acp-test -f ert-run-tests-batch 2>&1"
                                    :raw-input '(:command "emacs --batch -L acp -l acp-test -f ert-run-tests-batch 2>&1"
                                                          :description "Run permission widget tests")
                                    :content (list (acp-tool-call-content--create
                                                    :type "text"
                                                    :text "LONG output"))))
                 "Run permission widget tests")))

(ert-deftest acp-tool-call-widget--label-fetch ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "fetch" "pending" :title "Fetch weather API"))
                 "Fetch weather API")))

(ert-deftest acp-tool-call-widget--label-empty-title ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "read" "pending" :title ""
                             :locations '((:path "acp.el"))))
                 "Reading acp.el")))

(ert-deftest acp-tool-call-widget--label-empty-title-no-locations ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "other" "pending" :title ""))
                 "unknown")))

(ert-deftest acp-tool-call-widget--label-raw-input-pattern ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "read" "pending" :title "" :raw-input '(:pattern "*.el")))
                 "Reading *.el")))

(ert-deftest acp-tool-call-widget--label-locations-over-pattern ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "read" "pending" :title "Read acp.el"
                             :locations '((:path "acp.el"))
                             :raw-input '(:pattern "*.el")))
                 "Reading acp.el")))

(ert-deftest acp-tool-call-widget--label-other ()
  (should (equal (acp-tool-call-widget--label
                  (create-tool-call "other" "pending"))
                 "Test other")))

;; ── Status-label tests (one per status) ─────────────────────────────────────

(ert-deftest acp-tool-call-widget--status-label-pending ()
  (should (equal (acp-tool-call-widget--status-label "pending") " waiting ")))

(ert-deftest acp-tool-call-widget--status-label-in-progress ()
  (should (equal (acp-tool-call-widget--status-label "in_progress") " running ")))

(ert-deftest acp-tool-call-widget--status-label-completed ()
  (should (equal (acp-tool-call-widget--status-label "completed") " completed ")))

(ert-deftest acp-tool-call-widget--status-label-failed ()
  (should (equal (acp-tool-call-widget--status-label "failed") " failed ")))

;; ── Widget rendering tests (status faces via intervals) ─────────────────────

(ert-deftest acp-tool-call-widget-status-pending-face ()
  (let* ((tc (create-tool-call "read" "pending" :title "Read acp.el"
                          :locations '((:path "acp.el"))))
         (ivals (tcw--render tc)))
    (should (equal (nth (- (length ivals) 2) ivals)
                   '(" waiting " face acp-tool-call-widget-status-pending-face)))))

(ert-deftest acp-tool-call-widget-status-in-progress-face ()
  (let* ((tc (create-tool-call "read" "in_progress" :title "Read acp.el"
                          :locations '((:path "acp.el"))))
         (ivals (tcw--render tc)))
    (should (equal (nth (- (length ivals) 2) ivals)
                   '(" running " face acp-tool-call-widget-status-in-progress-face)))))

(ert-deftest acp-tool-call-widget-status-completed-face ()
  (let* ((tc (create-tool-call "read" "completed" :title "Read acp.el"
                          :locations '((:path "acp.el"))))
         (ivals (tcw--render tc)))
    (should (equal (nth (- (length ivals) 2) ivals)
                   '(" completed " face acp-tool-call-widget-status-completed-face)))))

(ert-deftest acp-tool-call-widget-status-failed-face ()
  (let* ((tc (create-tool-call "read" "failed" :title "Read acp.el"
                          :locations '((:path "acp.el"))))
         (ivals (tcw--render tc)))
    (should (equal (nth (- (length ivals) 2) ivals)
                   '(" failed " face acp-tool-call-widget-status-failed-face)))))

;; ── Interactive test utility (moved from acp-tool-call-widget.el) ───────────

(defun acp-tool-call-widget-test ()
  "Open a test buffer with sample tool call widgets and state buttons."
  (interactive)
  (switch-to-buffer (get-buffer-create "*acp-tool-call-widget-test*"))
  (let ((inhibit-read-only t))
    (erase-buffer)
    (setq-local acp--tool-widgets (make-hash-table :test 'equal))
    ;; ── Sample 1: think → completed ──
    (widget-insert "\nSample 1: think (pending  → running  → completed)\n")
    (let* ((id "call_think_1")
           (tc (acp-tool-call--create
                :id id :title "Explore the codebase" :kind "think"
                :status "pending"))
           (w (widget-create 'acp-tool-call-widget :value tc)))
      (puthash id w acp--tool-widgets)
      (widget-insert " ")
      (widget-create 'push-button
                     :notify (lambda (&rest _)
                               (acp-tool-call-widget-update-state
                                (gethash id acp--tool-widgets)
                                (acp-tool-call--create
                                 :id id :status "in_progress")))
                     "running")
      (widget-insert " ")
      (widget-create 'push-button
                     :notify (lambda (&rest _)
                               (acp-tool-call-widget-update-state
                                (gethash id acp--tool-widgets)
                                (acp-tool-call--create
                                 :id id :status "completed")))
                     "completed"))
    ;; ── Sample 2: read with location → completed → error ──
    (widget-insert "\n\nSample 2: read (pending → completed → error)\n")
    (let* ((id "call_read_1")
           (tc (acp-tool-call--create
                :id id :title "Read acp.el" :kind "read"
                :status "pending"
                :locations '((:path "acp.el"))))
           (w (widget-create 'acp-tool-call-widget :value tc)))
      (puthash id w acp--tool-widgets)
      (widget-insert " ")
      (widget-create 'push-button
                     :notify (lambda (&rest _)
                               (acp-tool-call-widget-update-state
                                (gethash id acp--tool-widgets)
                                (acp-tool-call--create
                                 :id id :status "completed"
                                 :title "Read acp.el" :kind "read")))
                     "completed")
      (widget-insert " ")
      (widget-create 'push-button
                     :notify (lambda (&rest _)
                               (acp-tool-call-widget-update-state
                                (gethash id acp--tool-widgets)
                                (acp-tool-call--create
                                  :id id :status "failed"
                                  :title "Read acp.el" :kind "read")))
                     "error"))
    ;; ── Sample 3: edit with location ──
    (widget-insert "\n\nSample 3: edit (pending → running → completed)\n")
    (let* ((id "call_edit_1")
           (tc (acp-tool-call--create
                :id id :title "Refactor function" :kind "edit"
                :status "pending"
                :locations '((:path "src/main.go"))))
           (w (widget-create 'acp-tool-call-widget :value tc)))
      (puthash id w acp--tool-widgets)
      (widget-insert " ")
      (widget-create 'push-button
                     :notify (lambda (&rest _)
                               (acp-tool-call-widget-update-state
                                (gethash id acp--tool-widgets)
                                (acp-tool-call--create
                                 :id id :status "in_progress" :kind "edit")))
                     "running")
      (widget-insert " ")
      (widget-create 'push-button
                     :notify (lambda (&rest _)
                               (acp-tool-call-widget-update-state
                                (gethash id acp--tool-widgets)
                                (acp-tool-call--create
                                 :id id :status "completed" :kind "edit"
                                 :title "Refactor function")))
                     "completed"))
    ;; ── Sample 4: execute with no location (generic verb) ──
    (widget-insert "\n\nSample 4: execute (pending → running → error)\n")
    (let* ((id "call_exec_1")
           (tc (acp-tool-call--create
                :id id :title "npm test" :kind "execute"
                :status "pending"))
           (w (widget-create 'acp-tool-call-widget :value tc)))
      (puthash id w acp--tool-widgets)
      (widget-insert " ")
      (widget-create 'push-button
                     :notify (lambda (&rest _)
                               (acp-tool-call-widget-update-state
                                (gethash id acp--tool-widgets)
                                (acp-tool-call--create
                                 :id id :status "in_progress" :kind "execute")))
                     "running")
      (widget-insert " ")
      (widget-create 'push-button
                     :notify (lambda (&rest _)
                               (acp-tool-call-widget-update-state
                                (gethash id acp--tool-widgets)
                                (acp-tool-call--create
                                  :id id :status "failed" :kind "execute")))
                     "error"))
    ;; ── Sample 5: execute with content (has [view] button) ──
    (widget-insert "\n\nSample 5: execute with content (has [view] button)\n")
    (let* ((id "call_view_1")
           (tc (acp-tool-call--create
                :id id :title "Analyze data" :kind "execute"
                :status "completed"
                :content (list
                          (acp-tool-call-content--create
                           :type "text"
                           :text "Analysis complete. Found 3 issues.")
                          (acp-tool-call-diff--create
                           :path "/tmp/test.txt"
                           :oldText "old content"
                           :newText "new content"))))
           (w (widget-create 'acp-tool-call-widget :value tc)))
      (puthash id w acp--tool-widgets))
    ;; ── Sample 6: no kind (unknown) ──
    (widget-insert "\n\nSample 6: unknown (pending → completed)\n")
    (let* ((id "call_unknown_1")
           (tc (acp-tool-call--create
                :id id :title "Custom task" :kind nil
                :status "pending"))
           (w (widget-create 'acp-tool-call-widget :value tc)))
      (puthash id w acp--tool-widgets)
      (widget-insert " ")
      (widget-create 'push-button
                     :notify (lambda (&rest _)
                               (acp-tool-call-widget-update-state
                                (gethash id acp--tool-widgets)
                                (acp-tool-call--create
                                 :id id :status "completed"
                                 :title "Custom task")))
                     "completed"))
    (widget-insert "\n")
    (widget-setup)
    (use-local-map widget-keymap)
    (goto-char (point-min))))

(provide 'acp-tool-call-widget-test)
;;; acp-tool-call-widget-test.el ends here
