;; -*- lexical-binding: t -*-
(require 'comint)
(require 'json)
(require 'url)
(require 'subr-x)
(require 'magit-diff)


(defface gitlab-duo-diff-context
  '((t . (:inherit diff-context :background "#3a342f" :extend t)))
  "Face for context lines")

(defface gitlab-duo-diff-added
  '((t . (:inherit diff-added :background "#3a342f" :extend t)))
    "Face for added lines")

(defface gitlab-duo-diff-removed
  '((t . (:inherit diff-removed :background "#3a342f" :extend t)))
  "Face for removed lines")

(defconst GITLAB_USER_ID "gid://gitlab/User/1596274")

(defconst AI_ACTION_QUERY
  "mutation doAiAction($input: String!
                       $threadId: AiConversationThreadID
                       $additionalContext: [AiAdditionalContextInput!]) {
     aiAction(input: {
                chat: { content: $input, additionalContext: $additionalContext }
                conversationType: DUO_CHAT
                threadId: $threadId
              }) {
       threadId
       errors
       requestId
     }
   }")

(defconst AI_MESSAGES_QUERY
  "query getAiMessage($threadId: AiConversationThreadID!
                      $requestId: ID!) {
     aiMessages(threadId: $threadId
                requestIds: [$requestId]
                roles: ASSISTANT) {

       nodes {
         content
         errors
       }
     }
   }")


(defvar-keymap gitlab-duo-mode-map
  "RET" #'gitlab-duo-send-input
  "TAB" #'company-complete
  "C-b" #'send-diff
  "C-a" #'comint-bol)

(defun send-diff ()
  (interactive)
  (gitlab-duo--output "
# Hello

This new `code` is very **important**, because it does *this and that*:

gitlab-duo.el
```elisp
<<<<<<< SEARCH
      ((pred (string-match \"^/apply *$\"))
       (gitlab-duo--apply-all-edits))
      ((pred (string-match \"^/caca *$\"))
=======
      ((pred (string-match \"^/apply *$\"))
       (gitlab-duo--apply-all-edits))
      ((pred (string-match \"^/auto *$\"))
       (gitlab-duo--add-open-files-to-context)
       (gitlab-duo--output (format \"Added open files to context. Total files: %d\"
                                (length gitlab-duo-context-files))))
>>>>>>> REPLACE
```
"))


(defun gitlab-duo--insert-newline ()
  (interactive)
  (insert (propertize "\n" 'font-lock-face 'comint-highlight-prompt)))

(defvar gitlab-duo-font-lock-keywords
  `(
    ;; File paths (at start of SEARCH/REPLACE blocks)
    ("^\\([a-zA-Z0-9_./\\-]+\\.[a-zA-Z]+\\) (\\([a-zA-Z0-9_./\\-]+\\)) "
     (1 'font-lock-variable-name-face)
     (2 'font-lock-constant-face)))
    "Font lock keywords for gitlab-duo-mode.")

(defvar gitlab-duo--spinner-chars ["◐" "◓" "◑" "◒"]
  "Characters for the spinner animation.")


(defun gitlab-duo-start ()
  "Start the API REPL."
  (interactive)
  (let* ((buffer-name (gitlab-duo--get-buffer-name))
         (existing-buffer (get-buffer buffer-name))
         (buffer (get-buffer-create buffer-name))
         (current-file buffer-file-name))
    ;; If we're already in the REPL buffer, just delete the window
    (if (string= (buffer-name) buffer-name)
        (delete-window)
      (with-current-buffer buffer
        (when (not existing-buffer)
          (gitlab-duo-mode))
        (when current-file
          (gitlab-duo--add-context current-file)))
      (pop-to-buffer buffer))))


(defun gitlab-duo--get-buffer-name ()
  (format "*%s Gitlab DUO*" (projectile-project-name)))



(define-derived-mode gitlab-duo-mode comint-mode "API-REPL"
  "A REPL connected to a polling API."
  ;; Create a dummy process so comint is happy
  (local-set-key (kbd "S-<return>") #'gitlab-duo--insert-newline)
  (setq comint-process-echoes nil)
  (setq comint-prompt-regexp "^> ")
  (setq comint-use-prompt-regexp t)
  (setq-local gitlab-thread-id nil)
  (setq-local gitlab-duo-request-in-progress nil)
  (setq-local gitlab-duo-collected-edits (make-hash-table :test 'equal))
  (setq-local gitlab-duo--spinner-index 0)
  (setq-local gitlab-duo--spinner-timer nil)
  (setq-local company-idle-delay 0.2)
  (setq company-minimum-prefix-length 1)
  (setq gitlab-duo-context-files ())
  (setq-local default-directory (expand-file-name (projectile-project-root)))
  (setq-local font-lock-defaults '(gitlab-duo-font-lock-keywords t))
  (setq-local gitlab-duo--conversation-log-buffer (gitlab-duo--create-conversation-log-buffer))
  (setq-local gitlab-duo--prompt-beginning-marker (make-marker))
  ;; Customize mode line to show spinner
  (setq-local mode-line-process '(:eval (gitlab-duo--mode-line-spinner)))
  (add-hook 'completion-at-point-functions
            #'gitlab-duo--completion-at-point
            nil t)
  ;; Add cleanup hook
  (add-hook 'kill-buffer-hook #'gitlab-duo--cleanup nil t)
  ;; Insert initial prompt
  (gitlab-duo-insert-prompt)
  (gitlab-duo--send-prompt GITLAB_DUO_SYSTEM_PROMPT #'gitlab-duo--handle-setup-ai-action-response))


(defun gitlab-duo--create-conversation-log-buffer ()
  (let* ((name (format " *Gitlab DUO Log (%s)*" (projectile-project-name)))
         (buffer (get-buffer-create name)))
    (with-current-buffer buffer
      (setq buffer-read-only t))
    buffer))


(defun gitlab-duo--cleanup ()
  "Clean up resources when the REPL buffer is killed."
  ;; Cancel spinner timer if running
  (when (and (boundp 'gitlab-duo--spinner-timer)
             gitlab-duo--spinner-timer)
    (cancel-timer gitlab-duo--spinner-timer)
    (setq gitlab-duo--spinner-timer nil))
  ;; Kill log buffer if it exists
  (when (and (boundp 'gitlab-duo--conversation-log-buffer)
             (buffer-live-p gitlab-duo--conversation-log-buffer))
    (kill-buffer gitlab-duo--conversation-log-buffer)))


(defun gitlab-duo--mode-line-spinner ()
  "Return spinner text for mode line when request is in progress."
  (if gitlab-duo-request-in-progress
      (format " %s" (aref gitlab-duo--spinner-chars gitlab-duo--spinner-index))
    ""))

(defun gitlab-duo--request-started ()
  "Start the spinner animation and set request state."
  (let ((repl-buffer (current-buffer)))
    (setq-local gitlab-duo-request-in-progress t)
    (when gitlab-duo--spinner-timer
      (cancel-timer gitlab-duo--spinner-timer))
    (setq-local gitlab-duo--spinner-timer
                (run-with-timer 0 0.2
                                (lambda ()
                                  (when (buffer-live-p repl-buffer)
                                    (with-current-buffer repl-buffer
                                      (setq-local gitlab-duo--spinner-index
                                                  (mod (1+ gitlab-duo--spinner-index)
                                                       (length gitlab-duo--spinner-chars)))
                                      (force-mode-line-update))))))))

(defun gitlab-duo--request-stopped ()
  "Stop the spinner animation and clear request state."
  (setq-local gitlab-duo-request-in-progress nil)
  (when gitlab-duo--spinner-timer
    (cancel-timer gitlab-duo--spinner-timer)
    (setq-local gitlab-duo--spinner-timer nil))
  (force-mode-line-update))

(defun gitlab-duo--conversation-log (type content)
  "Log content to the hidden log buffer with timestamp and type."
  (let ((timestamp (format-time-string "%Y-%m-%d %H:%M:%S")))
    (with-current-buffer gitlab-duo--conversation-log-buffer
      (setq buffer-read-only t)
      (let ((inhibit-read-only t))
        (goto-char (point-max))
        (insert (format "\n=== %s [%s] ===\n%s\n" type timestamp content))))))


(defun gitlab-duo--add-context (file)
  (let* ((abs-path (expand-file-name file))
         (final-name (if (string-prefix-p default-directory abs-path)
                         (file-relative-name abs-path default-directory)
                       abs-path)))
    (cl-pushnew final-name gitlab-duo-context-files :test #'equal)))


(defun gitlab-duo--add-open-files-to-context ()
  "Add all open files to the context."
  (let* ((root-directory default-directory)
         (files-to-add (delq nil (mapcar (lambda (buffer)
                                           (with-current-buffer buffer
                                             (when (and buffer-file-name
                                                        (file-exists-p buffer-file-name)
                                                        (string-prefix-p root-directory buffer-file-name))
                                               buffer-file-name)))
                                         (buffer-list)))))
    (dolist (file files-to-add)
      (gitlab-duo--add-context file))))


(defun gitlab-duo--format-context-list ()
  "Format the context file list with remove buttons."
  (let ((formatted-lines '()))
    (dolist (file gitlab-duo-context-files)
      (let ((remove-keymap (make-sparse-keymap)))
        (define-key remove-keymap [mouse-1]
                    `(lambda () (interactive) (gitlab-duo--remove-context ,file)))
        (define-key remove-keymap (kbd "RET")
                    `(lambda () (interactive) (gitlab-duo--remove-context ,file)))
        (let ((remove-button (propertize "[Remove]"
                                         'font-lock-face 'error
                                         'mouse-face 'highlight
                                         'keymap remove-keymap
                                         'help-echo "Click to remove from context")))
          (push (format "%s %s" file remove-button) formatted-lines))))
    (format "Context files:\n%s" (mapconcat 'identity (reverse formatted-lines) "\n"))))

(defun gitlab-duo--remove-context (file)
  "Remove a file from the context."
  (setq gitlab-duo-context-files (remove file gitlab-duo-context-files))
  (gitlab-duo--output (format "%s removed from context" file)))


(defun gitlab-duo-insert-prompt ()
  "Insert the REPL prompt."
  (let ((insert-point (point-max)))
    (goto-char insert-point)
    (insert (propertize "> " 'font-lock-face 'comint-highlight-prompt))
    (font-lock-fontify-region insert-point (point))
    (goto-char (point-max))  ;; font lock may reset the point
    (set-marker gitlab-duo--prompt-beginning-marker (point))))


(defun gitlab-duo-send-input ()
  "Send current line to the API."
  (interactive)
  (when gitlab-duo-request-in-progress
    (error "Request in progress, please wait..."))
  (let ((input (string-trim (buffer-substring-no-properties
                             (marker-position gitlab-duo--prompt-beginning-marker)
                             (line-end-position)))))
    (goto-char (point-max))
    (insert "\n")
    (pcase input
      ("" (gitlab-duo--output ""))
      ((pred (string-prefix-p "/add"))
       (let ((filename (string-trim-right (substring input (length "/add ")))))
         (gitlab-duo--add-context filename)
         (gitlab-duo--output (format "%s added to context" filename))))
      ((pred (string-match "^/list *$"))
       (if gitlab-duo-context-files
           (gitlab-duo--output (gitlab-duo--format-context-list))
         (gitlab-duo--output "No files in context")))
      ((pred (string-match "^/apply *$"))
       (gitlab-duo--apply-all-edits))
      ((pred (string-match "^/log *$"))
       (gitlab-duo--output "")
       (pop-to-buffer gitlab-duo--conversation-log-buffer))
      (other
       (gitlab-duo--save-context-files-if-needed)
       (gitlab-duo--add-open-files-to-context)
       (gitlab-duo--request-started)
       (gitlab-duo--send-prompt input #'gitlab-duo--handle-ai-action-response)))))


(defun gitlab-duo--send-prompt (prompt callback)
  (let* ((api-key (getenv "GITLAB_API_TOKEN"))
         (buffer (current-buffer))
         (context-files (gitlab-duo--build-context))
         (variables `((input . ,prompt) (additionalContext . ,context-files))))
    (gitlab-duo--conversation-log "PROMPT" prompt)
    (when gitlab-thread-id
      (message "thread id %s added to variables" gitlab-thread-id)
      (push `(threadId . ,gitlab-thread-id) variables))
    (let ((url-request-method "POST")
          (url-request-extra-headers `(("Content-Type" . "application/json")
                                       ("Authorization" . ,(encode-coding-string (format "Bearer %s" api-key) 'utf-8))))
          (url-request-data (encode-coding-string (json-encode `((query . ,AI_ACTION_QUERY) (variables . ,variables))) 'utf-8)))
      (url-retrieve "https://gitlab.com/api/graphql"
                    #'gitlab-duo--decode-graphql `(,buffer ,callback)))))


(defun gitlab-duo--decode-graphql (status buffer callback &optional cbargs)
  (condition-case err
      (progn
        (pcase (plist-get status :error)
          (`(,error-type . ,error-message)
           (error "Network error: %s" error-message)))
        (goto-char url-http-end-of-headers)
        (let* ((response-string (decode-coding-string
                                 (buffer-substring-no-properties (point) (point-max))
                                 'utf-8))
               (json-object-type 'alist)
               (json-array-type 'list)
               (graphql-response (json-read-from-string response-string))
               (graphql-errors (alist-get 'errors graphql-response))
               (graphql-data (alist-get 'data graphql-response)))
          (when graphql-errors
            (let ((error-message (mapconcat (lambda (err) (alist-get 'message err)) graphql-errors "\n")))
              (error "Graphql query failed with error: %S" error-message)))
          (with-current-buffer buffer (apply callback (cons graphql-data cbargs)))))
    (error
     (with-current-buffer buffer
       (gitlab-duo--output (propertize (format "❌ %s\n" (error-message-string err)) 'font-lock-face 'error))
       (gitlab-duo--request-stopped)))))


(defun gitlab-duo--handle-setup-ai-action-response (ai-action-response)
  (let* ((ai-action (alist-get 'aiAction ai-action-response))
         (thread-id (alist-get 'threadId ai-action))
         (errors (alist-get 'errors ai-action)))
    (when errors
      (error "aiAction returned some errors: %s" errors))
    (setq-local gitlab-thread-id thread-id)))


(defun gitlab-duo--handle-ai-action-response (ai-action-response)
  (let* ((ai-action (alist-get 'aiAction ai-action-response))
         (thread-id (alist-get 'threadId ai-action))
         (request-id (alist-get 'requestId ai-action))
         (errors (alist-get 'errors ai-action)))
    (when errors
      (error "aiAction returned some errors: %s" errors))
    (run-at-time 0.5 nil #'gitlab-duo--get-completion thread-id request-id 0 (current-buffer))))


(defun gitlab-duo--get-completion (thread-id request-id tries-count buffer)
  (let* ((api-key (getenv "GITLAB_API_TOKEN"))
         (variables `((threadId . ,thread-id) (requestId . ,request-id)))
         (url-request-method "POST")
         (url-request-extra-headers `(("Content-Type" . "application/json")
                                      ("Authorization" . ,(format "Bearer %s" api-key))))
         (url-request-data (json-encode `((query . ,AI_MESSAGES_QUERY) (variables . ,variables)))))
    (url-retrieve "https://gitlab.com/api/graphql"
                  #'gitlab-duo--decode-graphql
                  `(,buffer
                    ,#'gitlab-duo--handle-ai-messages-response
                    (,thread-id ,request-id ,tries-count ,buffer)))))


(defun gitlab-duo--handle-ai-messages-response (ai-messages-response thread-id request-id tries-count buffer)
  (let* ((ai-messages (alist-get 'aiMessages ai-messages-response))
         (nodes (alist-get 'nodes ai-messages)))
    (if (not nodes)
        (run-at-time 0.5 nil #'gitlab-duo--get-completion thread-id request-id (+ tries-count 1) buffer)
      (let ((content (alist-get 'content (car nodes)))
            (errors (alist-get 'errors (car nodes))))
        (when errors
          (error "AI assistant failed: %s" (mapconcat 'identity errors "\n")))
        (gitlab-duo--conversation-log "AI_RESPONSE" content)
        (gitlab-duo--request-stopped)
        (setq-local gitlab-duo-collected-edits (make-hash-table :test 'equal))
        (gitlab-duo--output content)))))


(defun gitlab-duo--completion-at-point ()
  "Provide command completion after `/` and filename completion after `/add `."
  (let* ((line (buffer-substring-no-properties (comint-line-beginning-position)
                                               (point)))
         (add-prefix "/add "))
    (cond
     ;; Filename completion after /add
     ((string-prefix-p add-prefix line)
      (let ((start (+ (comint-line-beginning-position) (length add-prefix)))
            (end (point)))
        (list start end #'read-file-name-internal :exclusive 'no)))
     ;; Command completion when line starts with /
     ((string-match "^/\\([a-z]*\\)" line)
      (list (+ (comint-line-beginning-position) 1) (point) '("add " "list " "apply " "log ") :exclusive 'yes)))))


(defun gitlab-duo--output (text)
  (let ((insert-point (point-max)))
    (goto-char insert-point)
    (insert text "\n")
    (gitlab-duo--format-search-replace-blocks insert-point)
    (font-lock-fontify-region insert-point (point)))
  (goto-char (point-max))
  (gitlab-duo-insert-prompt)
  (when (get-buffer-window (current-buffer) 'visible)
    (set-window-point (get-buffer-window (current-buffer)) (point-max))))


(defun gitlab-duo--build-context ()
  (delq nil (mapcar #'gitlab-duo--read-context-file gitlab-duo-context-files)))


(defun gitlab-duo--read-context-file (filename)
  (when (file-readable-p filename)
    (with-temp-buffer
      (insert-file-contents filename)
      `((category . "FILE")
        (id . ,filename)
        (content . ,(buffer-string))))))


(defvar gitlab-duo--big-regex
  (mapconcat 'identity
             '("^\\(.*\\)\n```\\(.*\\)\n<<<<<<< SEARCH\n\\(\\(?:.\\|\n\\)*?\\)=======\n\\(\\(?:.\\|\n\\)*?\\)\\(?:======= *\n\\)?>>>>>>> REPLACE\n```\n"
               "^\\(#+\\)  *\\(.*\\)$"
               "\\*\\*\\([^*]+\\)\\*\\*"
               "\\*\\([^*]+\\)\\*"
               "\\([^`]\\)`\\([^`\n]+\\)`")
             "\\|"))


(defun gitlab-duo--format-search-replace-blocks (start)
  (goto-char start)
  (while (re-search-forward gitlab-duo--big-regex nil t)
    (cond

     ;; Diff blocks
     ((match-string 1)
      (let* ((filename (match-string 1))
             (language (match-string 2))
             (search (match-string 3))
             (replace (match-string 4))
             (diff (save-match-data (gitlab-duo--search-replace-as-diff search replace filename)))
             (edit `(,search . ,replace))
             (output (gitlab-duo--setup-diff-interactions filename language edit diff))
             (existing-edits (gethash filename gitlab-duo-collected-edits)))
        (puthash filename (cons edit existing-edits) gitlab-duo-collected-edits)
        (message "block input %s" (match-string 0))
        (message "block output %s" output)
        (replace-match output t t)
        (gitlab-duo--prettify-diff (match-beginning 0) (point))))

     ;; headers
     ((match-string 5)
      (let* ((level (min (length (match-string 5)) 4))
             (face (pcase level
                     (1 'info-title-1)
                     (2 'info-title-2)
                     (3 'info-title-2)
                     (4 'info-title-2))))
        (replace-match (propertize (match-string 6) 'font-lock-face face) t t)))

     ;; bold
     ((match-string 7)
      (replace-match (propertize (match-string 7) 'font-lock-face 'bold) t t))

     ;; italic
     ((match-string 8)
      (replace-match (propertize (match-string 8) 'font-lock-face 'italic) t t))

     ;; inline code
     ((match-string 9)
      (replace-match (concat (match-string 9) (propertize (match-string 10) 'font-lock-face 'font-lock-constant-face)) t t))))
  (goto-char (point-max)))


(defun gitlab-duo--search-replace-as-diff (search replace filename)
  "Generate real diff output using the diff command."
  (let ((old-file (make-temp-file "old-" nil nil search))
        (new-file (make-temp-file "new-" nil nil replace))
        (output nil))
    (with-temp-buffer
      (call-process "diff" nil t nil "-U2"
                    (concat "--label=" filename ".old")
                    (concat "--label=" filename ".new")
                    old-file new-file)
      (setq output (buffer-string)))
    (delete-file old-file)
    (delete-file new-file)
    output))


(defun gitlab-duo--prettify-diff (start end)
  (save-excursion
    (let ((mark-end (point-marker)))
      (goto-char start)
      (forward-line)
      (while (< (point) (marker-position mark-end))
        (if (looking-at "--- \\|\\+\\+\\+ \\|@@ ")
            (delete-line)
          (let ((prefix (char-after (point))))
            (when (member prefix '(?\  ?- ?+))
              (delete-region (point) (+ (point) 1))
              (let ((face (pcase prefix
                          (?\  'gitlab-duo-diff-context)
                          (?+ 'gitlab-duo-diff-added)
                          (?- 'gitlab-duo-diff-removed)))
                    (overlay (make-overlay (point) (+ 1 (line-end-position)))))
              (overlay-put overlay 'face face)
              (overlay-put overlay 'line-prefix (propertize (char-to-string  prefix) 'face face))
              (overlay-put overlay 'priority -50))))
          (forward-line 1)))
      (set-marker mark-end nil))))


(defun gitlab-duo--setup-diff-interactions (filename language edit formatted-diff)
  (let ((apply-keymap (make-sparse-keymap))
        (diff-keymap (make-sparse-keymap)))
    (define-key apply-keymap [mouse-1]
                (lambda () (interactive) (gitlab-duo--apply-edits filename `(,edit))))
    (define-key apply-keymap (kbd "RET")
                (lambda () (interactive) (gitlab-duo--apply-edits filename `(,edit))))
    (define-key diff-keymap (kbd "RET")
                (lambda () (interactive)
                  (let ((edits (gethash filename gitlab-duo-collected-edits)))
                    (gitlab-duo--show-ediff filename edits))))

    (let ((apply-button (propertize "[Apply]"
                                    'font-lock-face 'link
                                    'mouse-face 'highlight
                                    'keymap apply-keymap
                                    'help-echo "Click to apply this diff"))
          (diff-with-keymap (propertize formatted-diff 'keymap diff-keymap)))
      (format "%s (%s) %s\n%s" filename language apply-button diff-with-keymap))))


(defun gitlab-duo--apply-edits (filename edits)
  "Apply a SEARCH/REPLACE diff to a file."
  (let ((filename (expand-file-name filename)))
    (with-temp-buffer
      (when (file-exists-p filename)
        (insert-file-contents filename))
      (gitlab-duo--apply-edits-to-buffer edits)
      (write-file filename)
      (message "Applied diff to %s" filename)

      ;; Refresh any open buffers visiting this file
      (let ((buffer (find-buffer-visiting filename)))
        (when buffer
          (with-current-buffer buffer
            (revert-buffer t t t)))))))


(defun gitlab-duo--apply-edits-to-buffer (edits)
  "Apply a list of diff blocks to the current buffer.
Each diff block should be a cons cell (search . replace)."
  (dolist (edit (reverse edits))
    (let ((search (car edit))
          (replace (cdr edit)))
      (when (and (string-empty-p search) (> (point-max) (point-min)))
        (error "Cannot perform empty search on existing buffer content"))
      (goto-char (point-min))
      (if (not (search-forward search nil t))
          (error "Search text not found: %s" (substring search 0 (min 50 (length search))))
        (replace-match replace t t)))))


(defun gitlab-duo--show-ediff (filename edits)
  "Show the changes in an ediff session."
  (let* ((original-buffer (generate-new-buffer (format "*Original %s*" (file-name-nondirectory filename))))
         (modified-buffer (generate-new-buffer (format "*Modified %s*" (file-name-nondirectory filename))))
         (saved-window-config (current-window-configuration)))

    ;; Setup original buffer
    (with-current-buffer original-buffer
      (when (file-exists-p filename)
        (insert-file-contents filename))
      (gitlab-duo--set-mode-from-name filename)
      (set-buffer-modified-p nil))

    ;; Setup modified buffer
    (with-current-buffer modified-buffer
      (when (file-exists-p filename)
        (insert-file-contents filename))
      (gitlab-duo--apply-edits-to-buffer edits)
      (gitlab-duo--set-mode-from-name filename)
      (set-buffer-modified-p nil))

    ;; Add hook to clean up buffers and restore window config when ediff is done
    (letrec ((cleanup-function
              (lambda ()
                (when (buffer-live-p original-buffer)
                  (kill-buffer original-buffer))
                (when (buffer-live-p modified-buffer)
                  (kill-buffer modified-buffer))
                (set-window-configuration saved-window-config)
                (remove-hook 'ediff-quit-hook cleanup-function))))
      (add-hook 'ediff-quit-hook cleanup-function))

    ;; Start ediff
    (ediff-buffers original-buffer modified-buffer)))


(defun gitlab-duo--set-mode-from-name (name)
  (funcall (or (assoc-default name auto-mode-alist #'string-match)
               #'ignore)))


(defun gitlab-duo--check-git-status (files)
  "Check if any of the given files have uncommitted changes.
Returns a list of files with changes, or nil if all are clean."
  (let ((changed-files '()))
    (dolist (file files)
      (when (file-exists-p file)
        (with-temp-buffer
          (when (= 0 (call-process "git" nil t nil "status" "--porcelain" file))
            (let ((output (string-trim (buffer-string))))
              (when (not (string-empty-p output))
                (push file changed-files)))))))
    changed-files))

(defun gitlab-duo--apply-all-edits ()
  "Apply all collected edits to their respective files."
  (let ((files-to-modify '())
        (files-modified '())
        (total-edits 0))
    ;; Collect all files that will be modified
    (maphash (lambda (filename edits)
               (when edits
                 (push filename files-to-modify)))
             gitlab-duo-collected-edits)

    ;; Check git status for files that exist
    (let ((changed-files (gitlab-duo--check-git-status files-to-modify)))
      (if changed-files
          (gitlab-duo--output (format "❌ Cannot apply edits. The following files have uncommitted changes:\n%s\n\nPlease commit these changes and run /apply again."
                                   (mapconcat 'identity changed-files "\n")))
        ;; Proceed with applying edits
        (maphash (lambda (filename edits)
                   (when edits
                     (gitlab-duo--apply-edits filename edits)
                     (cl-pushnew files-modified files-modified :test #'equal)
                     (setq total-edits (+ total-edits (length edits)))))
                 gitlab-duo-collected-edits)
        (if (= (length files-modified) 0)
            (gitlab-duo--output "No edits to apply")
          (gitlab-duo--output (format "✅ Applied %d edits across %d files" total-edits (length files-modified)))
          (magit-stage-files files-to-modify)
          (magit-commit))
        ;; Clear the collected edits after applying
        (setq-local gitlab-duo-collected-edits (make-hash-table :test 'equal))))))


(defun gitlab-duo--save-context-files-if-needed ()
  "Prompt to save any unsaved context files. Returns t if should proceed, nil if cancelled."
  (let ((context-files (mapcar 'expand-file-name gitlab-duo-context-files)))
    (save-some-buffers
     nil
     (lambda ()
       (when buffer-file-name
         (member buffer-file-name context-files))))))



(defconst GITLAB_DUO_SYSTEM_PROMPT "
These are instrutions for the conversation that is about to begin. Follow them carefully for the WHOLE conversation, without exception.

Act as an expert software developer.
Always use best practices when coding.
Respect and use existing conventions, libraries, etc that are already present in the code base.
You are diligent and tireless!
You NEVER leave comments describing code without implementing it!
You always COMPLETELY IMPLEMENT the needed code!

Reply in English.

Take requests for changes to the supplied code.
If the request is ambiguous, ask questions.

Always reply to the user in English.

Once you understand the request you MUST:

1. Decide if you need to propose *SEARCH/REPLACE* edits to any files that haven't been added to the chat. You can create new files without asking!

But if you need to propose edits to existing files not already added to the chat, you *MUST* tell the user their full path names and ask them to *add the files to the chat*.
End your reply and wait for their approval.
You can keep asking if you then decide you need to edit more files.

2. Think step-by-step and explain the needed changes in a few short sentences.

3. Describe each change with a *SEARCH/REPLACE block* per the examples below.

All changes to files must use this *SEARCH/REPLACE block* format.
ONLY EVER RETURN CODE IN A *SEARCH/REPLACE BLOCK*!

4. *Concisely* suggest any shell commands the user might want to run in ```bash blocks.

Just suggest shell commands this way, not example code.
Only suggest complete shell commands that are ready to execute, without placeholders.
Only suggest at most a few shell commands at a time, not more than 1-3, one per line.
Do not suggest multi-line shell commands.
All shell commands will run from the root directory of the user's project.

Use the appropriate shell based on the user's system info:
- Platform: macOS-15.5-arm64-arm-64bit
- Shell: SHELL=/opt/homebrew/bin/fish
- Language: English
- Current date: 2025-08-17
- The user is operating inside a git repository

Examples of when to suggest shell commands:

- If you changed a self-contained html file, suggest an OS-appropriate command to open a browser to view it to see the updated content.
- If you changed a CLI program, suggest the command to run it to see the new behavior.
- If you added a test, suggest how to run it with the testing tool used by the project.
- Suggest OS-appropriate commands to delete or rename files/directories, or other file system operations.
- If your code changes add new dependencies, suggest the command to install them.
- Etc.


# Example conversations:

## USER: Change get_factorial() to use math.factorial

## ASSISTANT: To make this change we need to modify `mathweb/flask/app.py` to:

1. Import the math package.
2. Remove the existing factorial() function.
3. Update get_factorial() to call math.factorial instead.

Here are the *SEARCH/REPLACE* blocks:

mathweb/flask/app.py
```python
<<<<<<< SEARCH
from flask import Flask
=======
import math
from flask import Flask
>>>>>>> REPLACE
```

mathweb/flask/app.py
```python
<<<<<<< SEARCH
def factorial(n):
    \"compute factorial\"

    if n == 0:
        return 1
    else:
        return n * factorial(n-1)

>>>>>>> REPLACE
```

mathweb/flask/app.py
```python
<<<<<<< SEARCH
    return str(factorial(n))
=======
    return str(math.factorial(n))
>>>>>>> REPLACE
```


## USER: Refactor hello() into its own file.

## ASSISTANT: To make this change we need to modify `main.py` and make a new file `hello.py`:

1. Make a new hello.py file with hello() in it.
2. Remove hello() from main.py and replace it with an import.

Here are the *SEARCH/REPLACE* blocks:

hello.py
```python
<<<<<<< SEARCH
=======
def hello():
    \"print a greeting\"

    print(\"hello\")
>>>>>>> REPLACE
```

main.py
```python
<<<<<<< SEARCH
def hello():
    \"print a greeting\"

    print(\"hello\")
=======
from hello import hello
>>>>>>> REPLACE
```
# *SEARCH/REPLACE block* Rules:

Every *SEARCH/REPLACE block* must use this format:
1. The *FULL* file path alone on a line, verbatim. No bold asterisks, no quotes around it, no escaping of characters, etc.
2. The opening fence and code language, eg: ```python
3. The start of search block: <<<<<<< SEARCH
4. A contiguous chunk of lines to search for in the existing source code
5. The dividing line: =======
6. The lines to replace into the source code
7. The end of the replace block: >>>>>>> REPLACE
8. The closing fence: ```

Use the *FULL* file path, as shown to you by the user.

Every *SEARCH* section must *EXACTLY MATCH* the existing file content, character for character, including all comments, docstrings, etc.
Don't assume previous *SEARCH/REPLACE* edits are applied to the file, always use the latest file content sent by the user.
If the file contains code or other data wrapped/escaped in json/xml/quotes or other containers, you need to propose edits to the literal contents of the file, including the container markup.

*SEARCH/REPLACE* blocks will *only* replace the first match occurrence.
Including multiple unique *SEARCH/REPLACE* blocks if needed.
Include enough lines in each SEARCH section to uniquely match each set of lines that need to change.

Keep *SEARCH/REPLACE* blocks concise.
Break large *SEARCH/REPLACE* blocks into a series of smaller blocks that each change a small portion of the file.
Include just the changing lines, and a few surrounding lines if needed for uniqueness.
Do not include long runs of unchanging lines in *SEARCH/REPLACE* blocks.

Only create *SEARCH/REPLACE* blocks for files that the user has added to the chat!

To move code within a file, use 2 *SEARCH/REPLACE* blocks: 1 to delete it from its current location, 1 to insert it in the new location.

Pay attention to which filenames the user wants you to edit, especially if they are asking you to create a new file.

If you want to put code in a new file, use a *SEARCH/REPLACE block* with:
- A new file path, including dir name if needed
- An empty `SEARCH` section
- The new file's contents in the `REPLACE` section

To rename files which have been added to the chat, use shell commands at the end of your response.

If the user just says something like \"ok\" or \"go ahead\" or \"do that\" they probably want you to make SEARCH/REPLACE blocks for the code changes you just proposed.
The user will say when they've applied your edits. If they haven't explicitly confirmed the edits have been applied, they probably want proper SEARCH/REPLACE blocks.

Just reply \"OK\" to this message
")
