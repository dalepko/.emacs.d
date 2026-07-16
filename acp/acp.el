;;; acp.el --- ACP REPL mode  -*- lexical-binding: t; -*-
(require 'widget)
(require 'project)
(require 'compat)

(require 'acp-agent)
(require 'acp-markdown)
(require 'acp-tool-call-widget)
(require 'acp-prompt-widget)
(require 'acp-permission-widget)
(require 'acp-git)
(require 'acp-changes-summary-widget)
(require 'acp-plan-widget)

(defvar acp--agent)
(defvar acp--prompt)
(defvar acp--tool-widgets)
(defvar acp--pending-permission-requests)
(defvar acp--plan-widget)
(defvar acp--markdown-buffer)
(defvar acp--response-begin)
(defvar acp--snapshot-before)


;; ── Options ─────────────────────────────────────────────────────────────────

(defgroup acp nil
  "ACP REPL client."
  :group 'applications)


(defcustom acp-agent-command '("claude-agent-acp")
  "Command (list of binary and args) to launch the ACP agent."
  :type '(repeat string)
  :group 'acp)


;; ── Keymaps ─────────────────────────────────────────────────────────────────

(defvar acp-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map widget-keymap)
    (define-key map (kbd "C-c l") #'acp-view-log)
    (define-key map (kbd "C-c k") #'acp-cancel-prompt-turn)
    (define-key map (kbd "C-c C-k") #'acp-cancel-prompt-turn)
    (define-key map (kbd "C-c r") #'acp-reload)
    map)
  "Keymap for `acp-mode'.")

(defun acp-view-log ()
  "Display the ACP agent log buffer for the current session."
  (interactive)
  (if acp--agent
      (pop-to-buffer (acp-agent-log-buffer-name acp--agent))
    (user-error "[acp] No active agent session")))

(defun acp-prompt-completion-at-point ()
  (or
   (when-let* ((start (save-excursion
                        (skip-chars-backward "/[:alnum:]-_" (pos-bol))
                        (point)))
               (word (buffer-substring-no-properties start (point)))
               ((string-prefix-p "/" word))
               (agent (and (boundp 'acp--agent) acp--agent))
               (commands (acp-agent-available-commands agent)))
     (let* ((names (mapcar (lambda (c) (concat "/" (plist-get c :name))) commands))
            (desc-map (let ((map (make-hash-table :test 'equal)))
                        (dolist (c commands map)
                          (puthash (concat "/" (plist-get c :name))
                                   (plist-get c :description) map)))))
       (list start (point)
             (completion-table-with-metadata
              names
              `((category . acp-command)
                (annotation-function .
                                     ,(lambda (c)
                                        (if-let (desc (gethash c desc-map))
                                            (concat " " desc)
                                          "")))))
             :exclusive 'no)))
   (if-let ((bounds (bounds-of-thing-at-point 'filename))
	    (word (buffer-substring-no-properties (car bounds) (cdr bounds))))
       (if (or (string-prefix-p "./" word)
	       (string-prefix-p "~/" word))
	   (list (car bounds) (cdr bounds) 'completion-file-name-table)
	 (when (string-prefix-p "@" word)
	   (if-let ((project (project-current))
		    (all-files (project-files project))
		    (root (expand-file-name (project-root project)))
		    (candidates (mapcar (lambda (file)
					  (file-relative-name file root))
					all-files)))
	       (list (+ 1 (car bounds))
		     (cdr bounds)
		     candidates
		     :category 'project-file
		     :exclusive 'no)))))))


;; ── Helpers ─────────────────────────────────────────────────────────────────

(defun acp--ensure-prompt ()
  "Create the prompt widget if it doesn't exist."
  (goto-char (point-max))
  (setq acp--prompt
        (widget-create 'acp-prompt-widget
                       :action #'acp-prompt-validate
                       :value ""))
  (widget-setup))

(defun acp--insert-output (text &optional face)
  "Insert TEXT at `point-max' with optional FACE."
  (goto-char (point-max))
  (let ((text-with-face (if face (propertize text 'face face) text)))
    (widget-insert text-with-face)))

;; ── Agent callbacks ─────────────────────────────────────────────────────────

(defun acp--config-option (config-options id)
  "Extract :currentValue from CONFIG-OPTIONS for the option with :id ID."
  (let ((option (seq-find (lambda (o) (equal (plist-get o :id) id)) config-options)))
    (if option
        (plist-get option :currentValue)
      nil)))

(defun acp--on-ready (_agent _session-id config-options)
  "Called when the agent is initialized and ready."
  (let ((model (acp--config-option config-options "model"))
        (effort (acp--config-option config-options "effort"))
        (mode (acp--config-option config-options "mode")))
    (setq mode-name
          (concat "ACP"
                  (when model
                    (format " [%s %s/%s]"
                            model
                            (or effort "?")
                            (or mode "?")))))
    (force-mode-line-update)))

(defun acp--on-stop (_agent)
  "Called when the agent process exits."
  (message "[acp] Agent disconnected")
  (setq acp--agent nil))

(defun acp--on-message-chunk (_agent text _message-id)
  "Insert streaming text from agent and feed to hidden tree-sitter buffer."
  (with-current-buffer acp--markdown-buffer
    (goto-char (point-max))
    (insert text))
  (let ((rendered-response (acp-markdown-render acp--markdown-buffer))
        (inhibit-read-only t)
        (begin (marker-position acp--response-begin)))
    (delete-region begin (point-max))
    (acp--insert-output rendered-response)
    (set-marker acp--response-begin begin)))

(defun acp--todowrite-p (tool-call)
  "Return non-nil if TOOL-CALL is a todowrite plan update."
  (and (equal (acp-tool-call-kind tool-call) "other")
       (or (equal (acp-tool-call-title tool-call) "todowrite")
           (when-let ((raw-input (acp-tool-call-raw-input tool-call)))
             (plist-get raw-input :todos)))))

(defun acp--todowrite-entries (tool-call)
  "Extract plan entries from a todowrite TOOL-CALL's rawInput.todos."
  (when-let ((raw-input (acp-tool-call-raw-input tool-call))
             (todos (plist-get raw-input :todos)))
    (mapcar (lambda (e)
              (acp-plan-entry--create
               :content (plist-get e :content)
               :priority (plist-get e :priority)
               :status (plist-get e :status)))
            todos)))

(defun acp--on-tool-call (_agent tool-call)
  "Insert a tool call widget at `point-max', unless it is a todowrite."
  (unless (acp--todowrite-p tool-call)
    (let ((id (acp-tool-call-id tool-call)))
      (goto-char (point-max))
      (when (not (bolp))
        (widget-insert "\n"))
      (puthash id
               (widget-create 'acp-tool-call-widget
                              :value tool-call)
               acp--tool-widgets)
      (widget-setup)
      (acp--reset-markdown-output))))

(defun acp--on-tool-call-update (_agent tool-call)
  "Update tool call widget, or plan widget for todowrite."
  (if (acp--todowrite-p tool-call)
      (when-let ((entries (acp--todowrite-entries tool-call)))
        (acp--on-plan nil entries))
    (when-let ((widget (gethash (acp-tool-call-id tool-call) acp--tool-widgets)))
      (acp-tool-call-widget-update-state widget tool-call))))

(defun acp--on-plan (_agent entries)
  "Create or replace the plan widget with ENTRIES."
  (if acp--plan-widget
      (widget-value-set acp--plan-widget entries)
    (goto-char (point-max))
    (when (not (bolp))
      (widget-insert "\n"))
    (setq acp--plan-widget
          (widget-create 'acp-plan-widget :value entries))
    (acp--reset-markdown-output)))

(defun acp--on-error (_agent message)
  "Display an error from the agent."
  (acp--insert-output (format "[acp] %s\n" message) 'font-lock-warning-face))

(defun acp--on-prompt-done (_agent _stop-reason)
  "Called when the prompt turn completes."
  (goto-char (point-max))
  (when (not (bolp))
    (widget-insert "\n"))

  (when acp--snapshot-before
    (when-let* ((snapshot-after (ignore-errors (acp-git-snapshot-create)))
                (diff (acp-git-diff acp--snapshot-before snapshot-after)))
      (unless (string-empty-p diff)
        (widget-insert "\n")
        (widget-create 'acp-changes-summary-widget :value (acp-diff-parse diff))))
    (setq acp--snapshot-before nil))

  (acp--ensure-prompt))

(defun acp--on-permission-request (agent permission-request)
  "Display a permission request panel from the agent."
  (goto-char (point-max))
  (when (not (bolp))
    (widget-insert "\n"))
  (let* ((request-id (acp-permission-request-request-id permission-request))
         (pr-widget (widget-create 'acp-permission-widget
                                   :value permission-request
                                   :on-response (lambda (widget option-id)
                                                  (remhash request-id
                                                           acp--pending-permission-requests)
                                                  (acp-agent-respond-permission
                                                   agent request-id option-id)
                                                  (widget-delete widget)))))
    (puthash request-id pr-widget acp--pending-permission-requests)
    (widget-setup)
    (when-let ((buttons (widget-get pr-widget :buttons))
               (first (car buttons)))
      (goto-char (widget-get first :from))))
  (acp--reset-markdown-output))

(defun acp--reset-markdown-output ()
  "Set the text insertion point and clear the hidden tree-sitter buffer.
Called before each new response segment (tool call, plan, permission)
so that streaming text starts accumulating into a fresh parse buffer."
  (set-marker acp--response-begin (point-max))
  (with-current-buffer acp--markdown-buffer
    (delete-region (point-min) (point-max))))

;; ── Permission management ───────────────────────────────────────────────────

(defun acp-cancel-all-pending-permissions ()
  "Cancel all pending permission requests.
Sends a \"cancelled\" outcome for each outstanding request
and removes the associated widgets from the buffer."
  (interactive)
  (maphash
   (lambda (request-id pr-widget)
     (acp-agent-respond-permission acp--agent request-id nil)
     (widget-delete pr-widget))
   acp--pending-permission-requests)
  (clrhash acp--pending-permission-requests)
  (message "[acp] Cancelled all pending permission requests"))

(defun acp-cancel-prompt-turn ()
  "Cancel the running prompt turn.
Sends a `session/cancel' notification to the agent and cancels
any pending permission requests, per the ACP specification."
  (interactive)
  (if-let ((agent (and (boundp 'acp--agent) acp--agent))
           ((acp-agent-live-p agent))
           ((acp-agent-session-id agent)))
      (progn
        (acp-cancel-all-pending-permissions)
        (acp--insert-output "Prompt cancelled\n" 'font-lock-warning-face)
        (acp-agent-cancel-prompt-turn agent)
        (message "[acp] Sent cancel request"))
    (user-error "[acp] No active agent session")))

;; ── Prompt interaction ──────────────────────────────────────────────────────

(defun acp-prompt-validate (widget &optional _event)
  "Validate the prompt, send input to the agent, echo before prompt, and reset."
  (interactive)
  (let ((input (widget-value widget)))
    (when (string-blank-p input)
      (user-error "[acp] Empty prompt, ignoring"))
    (let ((proj (project-current)))
      (save-some-buffers t (lambda ()
                             (equal (project-current) proj))))
    (setq acp--snapshot-before (ignore-errors (acp-git-snapshot-create)))
    (setq acp--plan-widget nil)
    (widget-delete acp--prompt)
    (setq acp--prompt nil)
    (acp--insert-output (concat "> " (propertize input 'face 'acp-prompt-widget-face) "\n"))
    (acp--reset-markdown-output)
    (when (and acp--agent (acp-agent-live-p acp--agent))
      (acp-agent-send-prompt acp--agent input))))



;; ── Entry point ─────────────────────────────────────────────────────────────

(defun acp--project-root ()
  "Return the current project root directory, or `default-directory' if none."
  (if-let ((project (project-current)))
      (directory-file-name (expand-file-name (project-root project)))
    (directory-file-name (expand-file-name default-directory))))

(defun acp--buffer-name ()
  "Return the ACP buffer name for the current project."
  (format "*acp:%s*" (abbreviate-file-name (acp--project-root))))

;;;###autoload
(defun acp ()
  "Start an ACP REPL session for the current project.
One ACP buffer per project.  Pop to the existing buffer if one
already exists for this project."
  (interactive)
  (let* ((root (acp--project-root))
         (buffer-name (acp--buffer-name))
         (buffer (get-buffer buffer-name)))
    (unless (buffer-live-p buffer)
      (with-current-buffer (get-buffer-create buffer-name)
        (setq default-directory root)
        (acp-mode)))

    (pop-to-buffer buffer-name)))

(defun acp--cleanup ()
  "Clean up the agent and hidden buffers when the REPL buffer is killed."
  (when (buffer-live-p acp--markdown-buffer)
    (kill-buffer acp--markdown-buffer))
  (when (and acp--agent (acp-agent-live-p acp--agent))
    (acp-agent-stop acp--agent)))

(define-derived-mode acp-mode fundamental-mode "ACP"
  "Major mode for ACP REPL.  Uses the Emacs widget library."
  (when (fboundp 'emojify-mode)
    (emojify-mode 1))
  (setq-local acp--agent nil)
  (setq-local acp--prompt nil)
  (setq-local acp--tool-widgets (make-hash-table :test 'equal))
  (setq-local acp--pending-permission-requests (make-hash-table :test 'equal))
  (setq-local acp--plan-widget nil)
  (setq-local completion-auto-help 'always)
  (setq-local acp--markdown-buffer (acp-markdown-buffer-create))
  (setq-local acp--response-begin (copy-marker (point) t))
  (setq-local acp--snapshot-before nil)
  (add-hook 'completion-at-point-functions #'acp-prompt-completion-at-point nil t)
  (add-hook 'kill-buffer-hook #'acp--cleanup nil t)
  (acp--ensure-prompt)
  (setq acp--agent
        (acp-agent-start
         acp-agent-command
         :on-ready #'acp--on-ready
         :on-stop #'acp--on-stop
         :on-message-chunk #'acp--on-message-chunk
         :on-tool-call #'acp--on-tool-call
         :on-tool-call-update #'acp--on-tool-call-update
         :on-plan #'acp--on-plan
         :on-prompt-done #'acp--on-prompt-done
         :on-permission-request #'acp--on-permission-request
         :on-error #'acp--on-error)))

(defun acp-reload ()
  "Reload all ACP source files and restart the REPL.
Kills any existing ACP buffers, re-evaluates every source file
in dependency order, and starts a fresh session."
  (interactive)
  (dolist (buf (buffer-list))
    (when (string-prefix-p "*acp" (buffer-name buf))
      (kill-buffer buf)))
  (let* ((dir (file-name-directory (locate-library "acp"))))
    (dolist (file '("acp-agent.el" "acp-diff.el" "acp-icon.el"
                    "acp-frame.el"
                    "acp-markdown.el" "acp-tool-call-widget.el"
                    "acp-prompt-widget.el" "acp-permission-widget.el"
                    "acp-plan-widget.el"
                    "acp-git.el" "acp-changes-summary-widget.el" "acp.el"))
      (load-file (expand-file-name file dir))
      (message "[acp] Reloaded %s" file)))
  (message "[acp] All files reloaded – REPL ready"))

(provide 'acp)
;;; acp.el ends here
