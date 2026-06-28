;;; acp-plan-widget.el --- Plan widget for ACP REPL  -*- lexical-binding: t; -*-

(require 'acp-agent)
(require 'acp-icon)
(require 'acp-frame)
(require 'wid-edit)

;; ── Faces ───────────────────────────────────────────────────────────────────

(defface acp-plan-widget-priority-face
  '((t :foreground "grey60" :slant italic))
  "Face for plan entry priority labels."
  :group 'acp)

;; ── Widget type ─────────────────────────────────────────────────────────────

(define-widget 'acp-plan-widget 'item
  "A plan display widget.
The value is a list of `acp-plan-entry' structs."
  :format "%v"
  :value-create 'acp-plan-widget--value-create
  :value-delete 'acp-plan-widget--value-delete)

(defun acp-plan-widget--value-create (widget)
  "Insert the plan entries display."
  (let ((entries (widget-get widget :value))
        (start (point)))
    (dolist (entry entries)
      (let* ((status (acp-plan-entry-status entry))
             (content (acp-plan-entry-content entry))
             (priority (acp-plan-entry-priority entry))
             (icon-kind (if (equal status "completed")
                            'plan-completed
                          'plan-pending))
             (checkbox (if (equal status "completed") "[X]" "[ ]"))
             (content-face (if (equal status "in_progress")
                               '(:weight bold :underline t)
                             'default))
             (icon (acp-icon-get icon-kind 'default)))
        (insert (propertize checkbox 'display icon)
                " "
                (propertize content 'face content-face)
                " "
                (propertize (concat "(" priority ")")
                            'face 'acp-plan-widget-priority-face))
        (insert "\n")))
    (widget-put widget :frame-overlays (acp-frame-create "Plan" start (point)))))

(defun acp-plan-widget--value-delete (widget)
  (widget-children-value-delete widget)
  (acp-frame-delete (widget-get widget :frame-overlays)))
  

(provide 'acp-plan-widget)
;;; acp-plan-widget.el ends here
