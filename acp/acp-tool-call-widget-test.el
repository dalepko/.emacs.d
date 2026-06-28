;;; acp-tool-call-widget-test.el --- Tests for acp-tool-call-widget  -*- lexical-binding: t; -*-
(require 'ert)

(require 'acp-agent)
(require 'acp-tool-call-widget)
(require 'acp-test-utils)

;; ── Helpers ─────────────────────────────────────────────────────────────────

(defun tcw--make (kind status &rest plist)
  (apply #'acp-tool-call--create
         :id "t1" :kind kind :status status
         (plist-put (copy-sequence plist) :title
                    (or (plist-get plist :title) (format "Test %s" kind)))))

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
                  (tcw--make "think" "pending" :title "Explore the codebase"))
                 "Explore the codebase")))

(ert-deftest acp-tool-call-widget--label-read ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "read" "pending" :title "Read acp.el"
                             :locations '((:path "acp.el"))))
                 "Reading acp.el")))

(ert-deftest acp-tool-call-widget--label-edit ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "edit" "pending" :title "Refactor function"
                             :locations '((:path "src/main.go"))))
                 "Editing main.go")))

(ert-deftest acp-tool-call-widget--label-delete ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "delete" "pending" :title "Delete temp file"
                             :locations '((:path "tmp/old.txt"))))
                 "Deleting old.txt")))

(ert-deftest acp-tool-call-widget--label-move ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "move" "pending" :title "Move file"
                             :locations '((:path "src/a.go"))))
                 "Moving a.go")))

(ert-deftest acp-tool-call-widget--label-search ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "search" "pending" :title "Search function defs"))
                 "Search function defs")))

(ert-deftest acp-tool-call-widget--label-execute ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "execute" "pending" :title "npm test"))
                 "npm test")))

(ert-deftest acp-tool-call-widget--label-fetch ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "fetch" "pending" :title "Fetch weather API"))
                 "Fetch weather API")))

(ert-deftest acp-tool-call-widget--label-empty-title ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "read" "pending" :title ""
                             :locations '((:path "acp.el"))))
                 "Reading acp.el")))

(ert-deftest acp-tool-call-widget--label-empty-title-no-locations ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "other" "pending" :title ""))
                 "unknown")))

(ert-deftest acp-tool-call-widget--label-raw-input-pattern ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "read" "pending" :title "" :raw-input '(:pattern "*.el")))
                 "Reading *.el")))

(ert-deftest acp-tool-call-widget--label-locations-over-pattern ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "read" "pending" :title "Read acp.el"
                             :locations '((:path "acp.el"))
                             :raw-input '(:pattern "*.el")))
                 "Reading acp.el")))

(ert-deftest acp-tool-call-widget--label-other ()
  (should (equal (acp-tool-call-widget--label
                  (tcw--make "other" "pending"))
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
  (let* ((tc (tcw--make "read" "pending" :title "Read acp.el"
                          :locations '((:path "acp.el"))))
         (ivals (tcw--render tc)))
    (should (equal (nth (- (length ivals) 2) ivals)
                   '(" waiting " face acp-tool-call-widget-status-pending-face)))))

(ert-deftest acp-tool-call-widget-status-in-progress-face ()
  (let* ((tc (tcw--make "read" "in_progress" :title "Read acp.el"
                          :locations '((:path "acp.el"))))
         (ivals (tcw--render tc)))
    (should (equal (nth (- (length ivals) 2) ivals)
                   '(" running " face acp-tool-call-widget-status-in-progress-face)))))

(ert-deftest acp-tool-call-widget-status-completed-face ()
  (let* ((tc (tcw--make "read" "completed" :title "Read acp.el"
                          :locations '((:path "acp.el"))))
         (ivals (tcw--render tc)))
    (should (equal (nth (- (length ivals) 2) ivals)
                   '(" completed " face acp-tool-call-widget-status-completed-face)))))

(ert-deftest acp-tool-call-widget-status-failed-face ()
  (let* ((tc (tcw--make "read" "failed" :title "Read acp.el"
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
