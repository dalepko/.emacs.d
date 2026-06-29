;;; acp-tool-call-widget.el --- Tool call widget for ACP REPL  -*- lexical-binding: t; -*-

(require 'acp-agent)
(require 'acp-icon)
(require 'wid-edit)

;; ── Faces ───────────────────────────────────────────────────────────────────

(defface acp-tool-call-widget-icon-face
  `((t :foreground "gold"))
  "Face for tool icon."
  :group 'acp)

(defface acp-tool-call-widget-status-pending-face
  '((t :background "grey30" :weight bold))
  "Face for pending tasks."
  :group 'acp)

(defface acp-tool-call-widget-status-in-progress-face
  '((t :background "#00415e" :weight bold))
  "Face for running tasks."
  :group 'acp)

(defface acp-tool-call-widget-status-completed-face
  '((t :background "green4" :weight bold))
  "Face for successful tasks."
  :group 'acp)

(defface acp-tool-call-widget-status-failed-face
  `((t :background ,(face-foreground 'warning) :weight bold))
  "Face for failed tasks."
  :group 'acp)


(defvar acp-tool-call-widget--kind-verbs
  (let ((table (make-hash-table :test 'equal)))
    (puthash "read"    "Reading"   table)
    (puthash "edit"    "Editing"   table)
    (puthash "delete"  "Deleting"  table)
    (puthash "move"    "Moving"    table)
    (puthash "search"  "Searching" table)
    (puthash "execute" "Running"   table)
    (puthash "think"   "Thinking"  table)
    (puthash "fetch"   "Fetching"  table)
    (puthash "other"   nil         table)
    table)
  "Hash table mapping tool call `kind' to a display verb.")

;; ── Widget type ─────────────────────────────────────────────────────────────

(define-widget 'acp-tool-call-widget 'item
  "A tool call displayed in the REPL buffer."
  :format "%v\n"
  :value-create 'acp-tool-call-widget--value-create
  :value-delete 'widget-children-value-delete)


(defun acp-tool-call-widget--value-create (widget)
  "Insert the tool call display with status icon, label, status, and view button."
  (let* ((tool-call (widget-get widget :value))
         (status (acp-tool-call-status tool-call))
         (kind (or (acp-tool-call-kind tool-call) "other"))
         (face (acp-tool-call-widget--face tool-call))
         (label (acp-tool-call-widget--label tool-call))
         (icon (acp-icon-get (intern kind) 'acp-tool-call-widget-icon-face)))
    (insert " ")
    (insert-image icon)
    (insert "  " (propertize label 'face '(:weight bold)))
    (insert (propertize " " 'display '(space :align-to 80)))
    (insert (propertize (acp-tool-call-widget--status-label status) 'face face))))

(defun acp-tool-call-widget--face (tool-call)
  "Return the appropriate face for TOOL-CALL based on its status."
  (pcase (acp-tool-call-status tool-call)
    ("pending"     'acp-tool-call-widget-status-pending-face)
    ("in_progress" 'acp-tool-call-widget-status-in-progress-face)
    ("completed"   'acp-tool-call-widget-status-completed-face)
    ("failed"      'acp-tool-call-widget-status-failed-face)
    (_             (error "unknown status %s" (acp-tool-call-status tool-call)))))


(defun acp-tool-call-widget--label (tool-call)
  "Return a display label for TOOL-CALL like \"Reading foo.el\"."
  (let* ((kind   (acp-tool-call-kind tool-call))
         (verb   (gethash kind acp-tool-call-widget--kind-verbs))
         (target (or (when-let* ((locs (acp-tool-call-locations tool-call))
                                  (loc  (car locs))
                                  (path (plist-get loc :path)))
                        (file-name-nondirectory path))
                      (when-let* ((raw (acp-tool-call-raw-input tool-call))
                                  (pat (plist-get raw :pattern)))
                        pat)))
         (title  (let ((s (acp-tool-call-title tool-call)))
                   (unless (string-empty-p s) s))))
    (cond
     ((and verb target) (format "%s %s" verb target))
     (title             title)
     (verb              (format "%s..." verb))
     (target            (format "Working on %s" target))
     (t                 "unknown"))))

(defun acp-tool-call-widget--status-label (status)
  (concat " "
          (pcase status
            ("pending"     "waiting")
            ("in_progress" "running")
            ("completed"   "completed")
            ("failed"      "failed")
            (_             status))
          " "))

;; ─────────────────────────────────────────────────────────────


;; ── Merge helper (used by acp.el callback) ──────────────────────────────────

(defun acp-tool-call-widget--merge-tool-calls (old new)
  "Merge OLD and NEW tool-call structs, preferring non-nil fields from NEW."
  (acp-tool-call--create
   :id (acp-tool-call-id new)
   :title (or (acp-tool-call-title new) (acp-tool-call-title old))
   :kind (or (acp-tool-call-kind new) (acp-tool-call-kind old))
   :status (or (acp-tool-call-status new) (acp-tool-call-status old))
   :content (or (acp-tool-call-content new) (acp-tool-call-content old))
   :locations (or (acp-tool-call-locations new) (acp-tool-call-locations old))
   :raw-input (or (acp-tool-call-raw-input new) (acp-tool-call-raw-input old))))

;; ── Interactive test utility ────────────────────────────────────────────────

(defun acp-tool-call-widget-update-state (widget tool-call)
  "Update WIDGET's value with a new TOOL-CALL and redisplay."
  (let ((merged (acp-tool-call-widget--merge-tool-calls (widget-get widget :value) tool-call)))
    (widget-value-set widget merged)))

(provide 'acp-tool-call-widget)
;;; acp-tool-call-widget.el ends here
