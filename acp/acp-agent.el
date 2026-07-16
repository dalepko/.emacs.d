;;; acp-agent.el --- ACP protocol client -*- lexical-binding: t; -*-
(require 'json)
(require 'cl-lib)

;; ── Logging ──────────────────────────────────────────────────────────────────

(defun acp-agent--log (agent direction plist)
  "Log DIRECTION (\"-->\" or \"<--\") and PLIST to AGENT's log buffer."
  (let ((buf (get-buffer-create (acp-agent-log-buffer-name agent))))
    (with-current-buffer buf
      (let ((inhibit-read-only t)
            (ts (format-time-string "%Y-%m-%d %H:%M:%S.%3N")))
        (goto-char (point-max))
        (insert (format "%s %s\n" direction ts)
                (pp-to-string plist)
                "\n\n")))))

;; ── Structs ──────────────────────────────────────────────────────────────────

(cl-defstruct (acp-agent (:constructor acp-agent--create)
                         (:copier nil))
  "An ACP agent connection."
  process
  (session-id nil)
  (config-options nil)
  (request-id 0)
  (pending nil)
  (line-buf nil)
  (callbacks nil)
  (buffer nil)
  (available-commands nil)
  (log-buffer-name nil :read-only t))

(cl-defstruct (acp-tool-call (:constructor acp-tool-call--create)
                             (:copier nil))
  "A tool call announced or updated by the agent.
Used for both `tool_call` (initial announcement — all fields present)
and `tool_call_update` (delta — nil means unchanged).
Also used for permission requests, where `raw-input` holds the
user's original intent (:command, :description, etc.)."
  (id nil :read-only t :type string)
  (title nil :read-only t :type string)
  (kind nil :read-only t :type string)
  (status nil :read-only t :type string)
  (content nil :read-only t :type list)
  (locations nil :read-only t :type list)
  (raw-input nil :read-only t :type (or null list)))

(cl-defstruct (acp-tool-call-content (:constructor acp-tool-call-content--create)
				     (:copier nil))
  "A content block (text, image, audio, or resource) in a tool call update.
Corresponds to `type: \"content\"' items in a tool call's content list."
  (type nil :read-only t :type string)
  (text nil :read-only t :type (or null string))
  (mime-type nil :read-only t :type (or null string))
  (data nil :read-only t :type (or null string))
  (uri nil :read-only t :type (or null string))
  (resource nil :read-only t :type (or null list)))

(cl-defstruct (acp-tool-call-diff (:constructor acp-tool-call-diff--create)
				  (:copier nil))
  "A file diff in a tool call update.
Corresponds to `type: \"diff\"' items in a tool call's content list."
  (path nil :read-only t :type string)
  (oldText nil :read-only t :type (or null string))
  (newText nil :read-only t :type string))

(cl-defstruct (acp-tool-call-terminal (:constructor acp-tool-call-terminal--create)
				      (:copier nil))
  "A terminal reference in a tool call update.
Corresponds to `type: \"terminal\"' items in a tool call's content list."
  (terminalId nil :read-only t :type string))

(cl-defstruct (acp-plan-entry (:constructor acp-plan-entry--create)
                              (:copier nil))
  "A single plan entry from a session/update plan notification.
Corresponds to a PlanEntry in the ACP spec."
  (content nil :read-only t :type string)
  (priority nil :read-only t :type string)
  (status nil :read-only t :type string))

(cl-defstruct (acp-permission-request (:constructor acp-permission-request--create)
                                      (:copier nil))
  "A permission request from the agent, parsed from session/request_permission.
Used by `acp-permission-widget' to display the alert panel."
  (session-id nil :read-only t :type string)
  (request-id nil :read-only t :type integer)
  (tool-call nil :read-only t :type acp-tool-call)
  (options nil :read-only t :type list))

;; ── Public API ──────────────────────────────────────────────────────────────

(cl-defun acp-agent-start (command &key on-ready on-stop
                                   on-message-chunk on-tool-call
                                   on-tool-call-update on-plan on-usage
                                   on-prompt-done on-permission-request
                                   on-error)
  "Start an ACP agent subprocess and initialize the protocol.

COMMAND is a list (BINARY &rest ARGS) for the agent subprocess.
BUFFER is the buffer to associate with this agent (defaults to current buffer).

Keyword callbacks:
  :on-ready (agent session-id config-options)
                                  Called when init+session/new complete.
  :on-stop (agent)                Called when the agent process exits.
  :on-message-chunk (agent text message-id)
                                  Streaming text from the agent.
  :on-tool-call (agent tool-call) Tool call started (acp-tool-call struct).
  :on-tool-call-update (agent tool-call)
                                  Tool call delta update (acp-tool-call struct).
  :on-plan (agent entries)        Plan update (list of acp-plan-entry structs).
  :on-usage (agent used size cost-plist)
                                  Token usage update. COST-PLIST is nil or
                                  (:amount NUMBER :currency STRING).
  :on-prompt-done (agent stop-reason)
                                  Called when session/prompt completes.
  :on-permission-request (agent pr)
                                  Called with an `acp-permission-request' struct
                                  when the agent requests a permission decision.
  :on-error (agent message)       Protocol or transport error.

Returns the acp-agent struct."
  (let* ((buffer (current-buffer))
         (log-buffer (generate-new-buffer (format " acp session log (%s)"
                                                  (abbreviate-file-name default-directory))))
         (agent (acp-agent--create
                 :callbacks `(:on-ready ,on-ready
                                        :on-stop ,on-stop
                                        :on-message-chunk ,on-message-chunk
                                        :on-tool-call ,on-tool-call
                                        :on-tool-call-update ,on-tool-call-update
                                        :on-plan ,on-plan
                                        :on-usage ,on-usage
                                        :on-prompt-done ,on-prompt-done
                                        :on-permission-request ,on-permission-request
                                        :on-error ,on-error)
                 :buffer buffer
                 :log-buffer-name (buffer-name log-buffer))))
    (condition-case err
        (let ((proc (make-process
                     :name "acp-agent"
                     :buffer nil
                     :command command
                     :connection-type 'pipe
                     :coding 'utf-8
                     :noquery t
                     :filter (lambda (_ s) (acp-agent--process-filter agent s))
                     :sentinel (lambda (_ e) (acp-agent--process-sentinel agent e)))))
          (setf (acp-agent-process agent) proc)
          (acp-agent--send-initialize agent)
          agent)
      (error
       (acp-agent--fire agent :on-error (error-message-string err))
       nil))))

(defun acp-agent-stop (agent)
  "Stop AGENT subprocess and clean up."
  (when (acp-agent-live-p agent)
    (delete-process (acp-agent-process agent)))
  (setf (acp-agent-process agent) nil
        (acp-agent-session-id agent) nil
        (acp-agent-pending agent) nil
        (acp-agent-line-buf agent) nil
        (acp-agent-available-commands agent) nil)
  (when-let ((log-buffer (get-buffer (acp-agent-log-buffer-name agent))))
    (when (buffer-live-p log-buffer)
      (kill-buffer log-buffer))))

(defun acp-agent-send-prompt (agent text)
  "Send a user prompt TEXT to AGENT.
Returns non-nil if accepted.  Call only after :on-ready fires."
  (when (and (acp-agent-live-p agent) (acp-agent-session-id agent))
    (acp-agent--send-request
     agent
     "session/prompt"
     `((sessionId . ,(acp-agent-session-id agent))
       (prompt . [((type . "text") (text . ,text))])))
    t))

(defun acp-agent-live-p (agent)
  "Return non-nil if AGENT process is still running."
  (and (acp-agent-process agent)
       (process-live-p (acp-agent-process agent))))

;; ── Internal: fire callbacks ────────────────────────────────────────────────

(defun acp-agent--fire (agent event &rest args)
  "Fire the EVENT callback on AGENT with ARGS, in the agent's buffer."
  (when-let ((fn (plist-get (acp-agent-callbacks agent) event)))
    (let ((buf (acp-agent-buffer agent)))
      (if (buffer-live-p buf)
          (with-current-buffer buf
            (apply fn agent args))
        (apply fn agent args)))))

;; ── Internal: JSON-RPC I/O ──────────────────────────────────────────────────

(defun acp-agent--next-id (agent)
  "Return the next JSON-RPC request ID for AGENT."
  (cl-incf (acp-agent-request-id agent)))

(defun acp-agent--write-msg (agent msg)
  "Encode MSG (plist) as JSON and write to AGENT's stdin."
  (let ((proc (acp-agent-process agent)))
    (when (process-live-p proc)
      (acp-agent--log agent "-->" msg)
      (process-send-string
       proc (concat (json-serialize msg :null-object nil
                                    :false-object :json-false) "\n")))))

(defun acp-agent--send-request (agent method params)
  "Send a JSON-RPC request; response is dispatched by METHOD."
  (let ((id (acp-agent--next-id agent)))
    (push (cons id method) (acp-agent-pending agent))
    (acp-agent--write-msg
     agent
     `((jsonrpc . "2.0") (id . ,id) (method . ,method) (params . ,params)))))

;; ── Internal: process I/O ───────────────────────────────────────────────────

(defun acp-agent--process-filter (agent string)
  "Accumulate AGENT stdout, parse newline-delimited JSON lines."
  (setf (acp-agent-line-buf agent)
        (concat (acp-agent-line-buf agent) string))
  (while (string-match "\n" (acp-agent-line-buf agent))
    (let* ((buf (acp-agent-line-buf agent))
           (line (substring buf 0 (match-beginning 0))))
      (setf (acp-agent-line-buf agent) (substring buf (match-end 0)))
      (unless (string-empty-p line)
        (let ((msg (json-parse-string line :object-type 'plist :array-type 'list)))
          (acp-agent--log agent "<--" msg)
          (acp-agent--dispatch agent msg))))))

(defun acp-agent--process-sentinel (agent _event)
  "Handle AGENT subprocess status change."
  (when (memq (process-status (acp-agent-process agent))
              '(exit signal))
    (acp-agent--fire agent :on-stop)))

;; ── Internal: JSON-RPC dispatch ─────────────────────────────────────────────

(defun acp-agent--dispatch (agent msg)
  "Route an incoming JSON-RPC message from AGENT."
  (let ((id (plist-get msg :id))
        (method (plist-get msg :method))
        (result (plist-get msg :result))
        (error-message (plist-get msg :error))
        (params (plist-get msg :params)))
    (cond
     ;; Response to our request — dispatch by method
     ((and id (or (plist-member msg :result) (plist-member msg :error)))
      (let ((entry (assq id (acp-agent-pending agent))))
        (when entry
          (setf (acp-agent-pending agent)
                (assq-delete-all id (acp-agent-pending agent)))
          (acp-agent--on-response agent (cdr entry) result error-message))))
     ;; Notification from agent
     ((and method (not id))
      (acp-agent--on-notification agent method params))
     ;; Request from agent
     ((and id method)
      (pcase method
        ("session/request_permission"
         (let* ((tool-call (acp-agent--parse-tool-call (plist-get params :toolCall)))
                (pr (acp-permission-request--create
                     :session-id (plist-get params :sessionId)
                     :request-id id
                     :tool-call tool-call
                     :options (plist-get params :options))))
           (acp-agent--fire agent :on-permission-request pr)))
        (_
         (acp-agent--fire agent :on-error
                          (format "Unhandled agent request: %s" method))))))))

(defun acp-agent--on-response (agent method result error)
  "Handle a response for the given METHOD."
  (pcase method
    ("initialize"
     (if error
         (acp-agent--fire agent :on-error
                          (format "initialize: %s"
                                  (or (plist-get error :message) "failed")))
       (acp-agent--send-new-session agent)))
    ("session/new"
     (if error
         (acp-agent--fire agent :on-error
                          (format "session/new: %s"
                                  (or (plist-get error :message) "failed")))
       (setf (acp-agent-session-id agent) (plist-get result :sessionId))
       (setf (acp-agent-config-options agent) (plist-get result :configOptions))
       (acp-agent--fire agent :on-ready
                        (acp-agent-session-id agent)
                        (acp-agent-config-options agent))))
    ("session/prompt"
     (if error
         (acp-agent--fire agent :on-error
                          (or (plist-get error :message) "prompt error"))
       (acp-agent--fire agent :on-prompt-done
                        (plist-get result :stopReason))))))

;; ── Internal: notification handlers ─────────────────────────────────────────

(defun acp-agent--on-notification (agent method params)
  "Dispatch AGENT notification METHOD with PARAMS."
  (pcase method
    ("session/update"
     (acp-agent--on-session-update agent (plist-get params :update)))
    (_
     (acp-agent--fire agent :on-error
                      (format "Unhandled notification: %s" method)))))

(defun acp-agent--on-session-update (agent update)
  "Handle a session/update notification."
  (let ((kind (plist-get update :sessionUpdate)))
    (pcase kind
      ("agent_message_chunk"
       (let ((msg-id (plist-get update :messageId))
             (content (plist-get update :content)))
         (when (and content (equal (plist-get content :type) "text"))
           (when-let ((text (plist-get content :text)))
             (acp-agent--fire agent :on-message-chunk text msg-id)))))
      ("user_message_chunk"
       ;; Replayed history on session/load — ignore for now.
       nil)
      ("tool_call"
       (acp-agent--fire agent :on-tool-call
                        (acp-agent--parse-tool-call update)))
      ("tool_call_update"
       (acp-agent--fire agent :on-tool-call-update
                        (acp-agent--parse-tool-call update)))
      ("plan"
       (when-let ((entries (plist-get update :entries)))
         (acp-agent--fire agent :on-plan
                          (mapcar (lambda (e)
                                    (acp-plan-entry--create
                                     :content (plist-get e :content)
                                     :priority (plist-get e :priority)
                                     :status (plist-get e :status)))
                                  entries))))
      ("usage_update"
       (let ((used (plist-get update :used))
             (size (plist-get update :size))
             (cost (plist-get update :cost)))
         (acp-agent--fire agent :on-usage used size
                          (when cost
                            `(:amount ,(plist-get cost :amount)
                                      :currency ,(plist-get cost :currency))))))
      ("available_commands_update"
       (setf (acp-agent-available-commands agent)
             (plist-get update :availableCommands))))))

(defun acp-agent--parse-tool-call (plist)
  "Parse a tool call from PLIST (an update sub-plist or toolCall sub-plist).
Returns an `acp-tool-call' struct."
  (acp-tool-call--create
   :id (plist-get plist :toolCallId)
   :title (plist-get plist :title)
   :kind (plist-get plist :kind)
   :status (plist-get plist :status)
   :content (mapcar #'acp-agent--parse-tool-call-content
                    (plist-get plist :content))
   :locations (plist-get plist :locations)
   :raw-input (plist-get plist :rawInput)))

(defun acp-agent--parse-tool-call-content (item)
  "Parse a tool call content ITEM (plist) into the appropriate struct.
ITEM's `:type' discriminates: \"content\", \"diff\", or \"terminal\"."
  (pcase (plist-get item :type)
    ("content"
     (let ((c (plist-get item :content)))
       (acp-tool-call-content--create
        :type (plist-get c :type)
        :text (plist-get c :text)
        :mime-type (plist-get c :mimeType)
        :data (plist-get c :data)
        :uri (plist-get c :uri)
        :resource (plist-get c :resource))))
    ("diff"
     (acp-tool-call-diff--create
      :path (plist-get item :path)
      :oldText (plist-get item :oldText)
      :newText (plist-get item :newText)))
    ("terminal"
     (acp-tool-call-terminal--create
      :terminalId (plist-get item :terminalId)))
    (_ (error "unknown tool call content: %s" (plist-get item :type)))))


;; ── Internal: protocol steps ────────────────────────────────────────────────

(defun acp-agent--send-initialize (agent)
  "Send the initialize request to AGENT."
  (acp-agent--send-request
   agent
   "initialize"
   `((protocolVersion . 1)
     (clientCapabilities . ((terminal . t)))
     (clientInfo . ((name . "acp.el") (version . "0.1.0"))))))

(defun acp-agent--send-new-session (agent)
  "Send the session/new request to AGENT."
  (acp-agent--send-request
   agent
   "session/new"
   `((cwd . ,(expand-file-name default-directory))
     (mcpServers . []))))

;; ── Prompt cancellation ──────────────────────────────────────────────────────

(defun acp-agent-cancel-prompt-turn (agent)
  "Cancel the ongoing prompt turn for AGENT.
Sends a session/cancel notification (no response expected)."
  (let ((session-id (acp-agent-session-id agent)))
    (when session-id
      (acp-agent--write-msg
       agent
       `((jsonrpc . "2.0") (method . "session/cancel") (params . ((sessionId . ,session-id))))))))

;; ── Permission response ──────────────────────────────────────────────────────

(defun acp-agent-respond-permission (agent request-id &optional option-id)
  "Respond to a session/request_permission request from the agent.
REQUEST-ID is the JSON-RPC request id from the original request.
OPTION-ID is the selected option's :optionId value (string, e.g. \"allow-once\").
When OPTION-ID is nil, respond with \"cancelled\" outcome."
  (let ((outcome (if option-id
                     `((outcome . "selected") (optionId . ,option-id))
                   `((outcome . "cancelled")))))
    (acp-agent--write-msg
     agent
     `((jsonrpc . "2.0") (id . ,request-id) (result . ((outcome . ,outcome)))))))

(provide 'acp-agent)
;;; acp-agent.el ends here
