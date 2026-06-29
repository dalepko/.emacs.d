;;; acp-permission-widget.el --- Permission request widget for ACP REPL  -*- lexical-binding: t; -*-

(require 'wid-edit)
(require 'cl-lib)
(require 'acp-agent)
(require 'acp-diff)
(require 'acp-frame)

;; ── Faces ───────────────────────────────────────────────────────────────────

(defface acp-permission-widget-border-face
  '((t :inherit shadow))
  "Face for the border of the permission request panel."
  :group 'acp)

(defface acp-permission-widget-description-face
  '((t :weight bold :inherit font-lock-keyword-face))
  "Face for the description text in the permission panel."
  :group 'acp)

(defface acp-permission-widget-command-face
  '((t :inherit font-lock-comment-face))
  "Face for the command text in the permission panel."
  :group 'acp)

;; ── Shortcut keys ────────────────────────────────────────────────────────────

(defconst acp-permission-widget--shortcuts
  '((?y . ("allow" "once"))
    (?! . ("allow_always" "always"))
    (?n . ("reject")))
  "Alist mapping shortcut keys to candidate option-ids for permission request widgets.
Each key maps to a list of ids; the first one present in the server options is used.")

(defun acp-permission-widget--respond (candidates)
  "Respond to the permission widget at point.
CANDIDATES is a list of option-id strings; the first one matching
the server's available options is sent."
  (let* ((widget (or (get-char-property (point) 'acp-permission-request) (error "Not on a permission widget")))
         (pr (widget-get widget :value))
         (options (acp-permission-request-options pr))
         (option-ids (mapcar (lambda (o) (plist-get o :optionId)) options))
         (option-id (seq-find (lambda (c) (member c option-ids)) candidates)))
    (unless option-id
      (error "None of %s available for this request" candidates))
    (when-let ((on-response (widget-get widget :on-response)))
      (funcall on-response widget option-id))))

(defun acp-permission-widget--once ()
  (interactive)
  (acp-permission-widget--respond '("allow" "once")))

(defun acp-permission-widget--always ()
  (interactive)
  (acp-permission-widget--respond '("allow_always" "always")))

(defun acp-permission-widget--reject ()
  (interactive)
  (acp-permission-widget--respond '("reject")))

(defvar acp-permission-widget-keymap
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map widget-keymap)
    (define-key map (kbd "y") 'acp-permission-widget--once)
    (define-key map (kbd "!") 'acp-permission-widget--always)
    (define-key map (kbd "n") 'acp-permission-widget--reject)
    map)
  "Keymap for permission request widgets.
Provides single-key shortcuts for common permission options.")

;; ── Widget type ─────────────────────────────────────────────────────────────

(define-widget 'acp-permission-widget 'item
  "A permission request alert panel for the ACP REPL.

Value is an `acp-permission-request' struct (from `acp-agent.el').
The widget's `:on-response' property is a function called with
(widget OPTION-ID) when an option button is pressed."
  :format "%v"
  :value-create 'acp-permission-widget--value-create
  :value-delete 'acp-permission-widget--value-delete)

(defun acp-permission-widget--value-create (widget)
  "Insert the permission request alert panel."
  (let* ((pr (widget-get widget :value))
         (tool-call (acp-permission-request-tool-call pr))
         (options (acp-permission-request-options pr))
         (title (acp-tool-call-title tool-call))
         (label (format "Permission request: %s" title))
         (on-response (widget-get widget :on-response))
         (start (point)))

    (insert "\n")

    (pcase (acp-tool-call-kind tool-call)
      ("edit"    (acp-permission-widget--body-edit tool-call))
      ("execute" (acp-permission-widget--body-execute tool-call))
      ("other"   (acp-permission-widget--body-other tool-call)))

    (widget-put widget :buttons (acp-permission-widget--buttons widget options on-response))

    (insert "\n\n")

    (widget-put widget :frame-overlays (acp-frame-create label start (point)))

    (let ((ov (make-overlay start (point) nil nil nil)))
      (overlay-put ov 'keymap acp-permission-widget-keymap)
      (overlay-put ov 'acp-permission-request widget)
      (widget-put widget :keymap-overlay ov))))

(defun acp-permission-widget--body-edit (tool-call)
  (if-let* ((content (acp-tool-call-content tool-call))
            (diffs (cl-remove-if-not (lambda (c) (acp-tool-call-diff-p c)) content))
            (diff (car diffs))
            (path (acp-tool-call-diff-path diff))
            (new-text (acp-tool-call-diff-newText diff)))
      (progn
        (insert (propertize (format "Edit file: %s" path) 'face 'acp-permission-widget-description-face))
        (insert "\n\n")
        (condition-case err
            (insert (acp-diff-create-and-format path (acp-tool-call-diff-oldText diff) new-text) "\n")
          (error (insert (format "(diff unavailable: %s)\n" (error-message-string err))))))

    ;; Fallback: raw-input format with :filepath and :diff
    (when-let* ((raw (acp-tool-call-raw-input tool-call))
                (fp (plist-get raw :filepath))
                (diff (plist-get raw :diff)))
      (insert (propertize (format "Edit file: %s" fp) 'face 'acp-permission-widget-description-face))
      (insert "\n\n")
      (condition-case err
          (insert (acp-diff-format (acp-diff-cleanup-diff diff)) "\n")
        (error (insert (format "(diff unavailable: %s)\n" (error-message-string err)))))))
)

(defun acp-permission-widget--body-execute (tool-call)
  (let* ((raw-input (acp-tool-call-raw-input tool-call))
         (command (plist-get raw-input :command)))
    (insert (propertize "Execute command:" 'face 'acp-permission-widget-description-face))
    (insert "\n\n")
    (when command
      (insert (propertize command 'face 'acp-permission-widget-command-face))
      (insert "\n\n"))))

(defun acp-permission-widget--body-other (tool-call)
  (let* ((raw-input (acp-tool-call-raw-input tool-call))
         (description (plist-get raw-input :description))
         (command (plist-get raw-input :command)))
    (let ((desc (or description
                    (when-let ((fp (plist-get raw-input :filepath)))
                      (format "Write file: %s" fp)))))
      (insert (propertize (or desc "") 'face 'acp-permission-widget-description-face)))
    (insert "\n\n")
    (when command
      (insert (propertize command 'face 'acp-permission-widget-command-face))
      (insert "\n\n"))))

(defun acp-permission-widget--buttons (widget options on-response)
  (let ((buttons nil)
        (spacing ""))
    (dolist (opt options (nreverse buttons))
      (insert spacing)
      (let* ((opt-id (plist-get opt :optionId))
             (opt-name (plist-get opt :name))
             (key (car (cl-rassoc opt-id acp-permission-widget--shortcuts :test #'member)))
             (tag (if key
                      (format " %s (%c) " opt-name key)
                    (concat " " opt-name " ")))
             (button (widget-create-child-and-convert
                      widget 'push-button
                      :tag tag
                      :action (lambda (_button _event)
                                (when on-response
                                  (funcall on-response widget opt-id))))))
        (push button buttons)
        (setq spacing "  ")))))

(defun acp-permission-widget--value-delete (widget)
  (widget-children-value-delete widget)
  (acp-frame-delete (widget-get widget :frame-overlays))
  (when-let ((ov (widget-get widget :keymap-overlay)))
    (delete-overlay ov)))


(provide 'acp-permission-widget)
;;; acp-permission-widget.el ends here
