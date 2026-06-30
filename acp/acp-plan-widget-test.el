;;; acp-plan-widget-test.el --- Tests for acp-plan-widget  -*- lexical-binding: t; -*-
(require 'ert)

(require 'acp-agent)
(require 'acp-plan-widget)

;; ── Sample data ──────────────────────────────────────────────────────────────

(defvar acp-plan-widget-test--sample-entries
  (list (acp-plan-entry--create
         :content "Analyze the existing codebase structure"
         :priority "high"
         :status "pending")
        (acp-plan-entry--create
         :content "Identify components that need refactoring"
         :priority "high"
         :status "in_progress")
        (acp-plan-entry--create
         :content "Create unit tests for critical functions"
         :priority "medium"
         :status "completed")
        (acp-plan-entry--create
         :content "Update documentation"
         :priority "low"
         :status "pending"))
  "Sample plan entries for testing.")

;; ── ERT tests ────────────────────────────────────────────────────────────────

(ert-deftest acp-plan-widget-renders-entries ()
  (with-temp-buffer
    (widget-create 'acp-plan-widget :value acp-plan-widget-test--sample-entries)
    (should (equal (buffer-substring-no-properties (point-min) (point-max))
                   "\
[ ] Analyze the existing codebase structure (high)
[ ] Identify components that need refactoring (high)
[X] Create unit tests for critical functions (medium)
[ ] Update documentation (low)
"))))

(ert-deftest acp-plan-widget-empty-entries ()
  (with-temp-buffer
    (widget-create 'acp-plan-widget :value nil)
    (should (equal (buffer-substring-no-properties (point-min) (point-max))
                   ""))))

;; ── Interactive test ─────────────────────────────────────────────────────────

(defun acp-plan-widget-test ()
  "Open a test buffer displaying a sample plan widget."
  (interactive)
  (let ((inhibit-read-only t))
    (switch-to-buffer (get-buffer-create "*acp-plan-widget-test*"))
    (erase-buffer)
    (widget-create 'acp-plan-widget :value acp-plan-widget-test--sample-entries)
    (widget-setup)
    (use-local-map widget-keymap)
    (goto-char (point-min))))

(provide 'acp-plan-widget-test)
;;; acp-plan-widget-test.el ends here
