;;; acp-modeline.el --- ACP mode-line display  -*- lexical-binding: t; -*-
(require 'seq)
(require 'subr)

(require 'acp-agent)

(defvar-local acp-modeline--usage nil)
(defvar-local acp-modeline--config-options nil)
(defvar-local acp-modeline--model-menu nil)
(defvar-local acp-modeline--effort-menu nil)
(defvar-local acp-modeline--mode-menu nil)

(defvar acp-modeline--model-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mode-line down-mouse-1] #'acp-modeline--model-popup)
    map))

(defvar acp-modeline--effort-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mode-line down-mouse-1] #'acp-modeline--effort-popup)
    map))

(defvar acp-modeline--mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mode-line down-mouse-1] #'acp-modeline--mode-popup)
    map))

;; ── config options ────────────────────────────────────────────────────────

(defun acp-modeline-config-options-setup (agent)
  (acp-agent-add-hook agent :on-ready #'acp-modeline--on-ready)
  (acp-agent-add-hook agent :on-config-update #'acp-modeline--on-config-update)
  (add-to-list 'mode-line-misc-info
               `(acp-modeline--config-options (" [" (:eval (acp-modeline--show-config-options)) "]"))))

(defun acp-modeline--show-config-options ()
  (let ((model (acp-modeline--get-config-option acp-modeline--config-options "model"))
        (effort (acp-modeline--get-config-option acp-modeline--config-options "effort"))
        (mode (acp-modeline--get-config-option acp-modeline--config-options "mode")))
    (when model
      (concat (propertize (file-name-nondirectory model)
                          'keymap acp-modeline--model-map
                          'mouse-face 'mode-line-highlight
                          'help-echo "mouse-1: Select model")
              (when effort
                (concat " " (propertize effort
                                        'keymap acp-modeline--effort-map
                                        'mouse-face 'mode-line-highlight
                                        'help-echo "mouse-1: Select effort")))
              (when mode
                (concat " " (propertize mode
                                        'keymap acp-modeline--mode-map
                                        'mouse-face 'mode-line-highlight
                                        'help-echo "mouse-1: Select mode")))))))

(defun acp-modeline--on-ready (agent _session-id config-options)
  "Called when the agent is initialized and ready."
  (acp-modeline--on-config-update agent config-options))

(defun acp-modeline--on-config-update (agent config-options)
  "Called when config options change (from agent or client)."
  (setq-local acp-modeline--config-options config-options)
  (setq-local acp-modeline--model-menu
              (acp-modeline--build-config-keymap agent "Select model" "model"))
  (setq-local acp-modeline--effort-menu
              (acp-modeline--build-config-keymap agent "Select effort" "effort"))
  (setq-local acp-modeline--mode-menu
              (acp-modeline--build-config-keymap agent "Select mode" "mode"))
  (force-mode-line-update))

(defun acp-modeline--get-config-option (config-options id)
  "Extract :currentValue from CONFIG-OPTIONS for the option with :id ID."
  (let ((option (seq-find (lambda (o) (equal (plist-get o :id) id)) config-options)))
    (if option
        (plist-get option :currentValue)
      nil)))

;; ── popup config menu ─────────────────────────────────────────────────────

(defun acp-modeline--model-popup (_event)
  "Show a popup menu to change the model."
  (interactive "e")
  (popup-menu acp-modeline--model-menu))

(defun acp-modeline--effort-popup (_event)
  "Show a popup menu to change the effort."
  (interactive "e")
  (popup-menu acp-modeline--effort-menu))

(defun acp-modeline--mode-popup (_event)
  "Show a popup menu to change the mode."
  (interactive "e")
  (popup-menu acp-modeline--mode-menu))

(defun acp-modeline--build-config-keymap (agent menu-name option-id)
  "Build a keymap-based popup menu from `acp-modeline--config-options'."
  (when-let ((config-option (seq-find (lambda (o) (equal (plist-get o :id) option-id))
                                      acp-modeline--config-options))
             (options (plist-get config-option :options))
             (current-value (plist-get config-option :currentValue))
             (map (make-sparse-keymap menu-name)))
    (dolist (option options)
      (let ((name (plist-get option :name))
            (value (plist-get option :value))
            (description (plist-get option :description)))
        (define-key map `[,(intern value)]
                    `(menu-item ,(if description (concat name " (" description ")") name)
                                ,(acp-modeline--make-set-config-cmd agent option-id value)
                                :button (:radio . ,(string= current-value value))))))
    map))

(defun acp-modeline--make-set-config-cmd (agent config-id value)
  "Return a command that sets CONFIG-ID to VALUE on the active agent."
  (lambda ()
    (interactive)
    (when (acp-agent-live-p agent)
      (acp-agent-set-config-option agent config-id value))))

;; ── usage ────────────────────────────────────────────────────────

(defun acp-modeline-usage-setup (agent)
  (acp-agent-add-hook agent :on-usage #'acp-modeline--on-usage)
  (add-to-list 'mode-line-misc-info
               `(acp-modeline--usage (" " (:eval (acp-modeline--show-usage))))))

(defun acp-modeline--show-usage ()
  (when-let ((tokens (plist-get acp-modeline--usage :used))
             (amt (plist-get acp-modeline--usage :amount))
             (cur (plist-get acp-modeline--usage :currency)))
    (format "tokens: %s (%s)"
            (propertize (acp-modeline--format-tokens tokens)
                        'face 'mode-line-emphasis)
            (propertize (acp-modeline--format-currency amt cur)
                        'face 'mode-line-emphasis))))

(defun acp-modeline--on-usage (_agent used _size cost-plist)
  "Called with token usage and cost info.  Updates the modeline."
  (setq acp-modeline--usage (list :used used
                                  :amount (plist-get cost-plist :amount)
                                  :currency (plist-get cost-plist :currency)))
  (force-mode-line-update))

(defun acp-modeline--format-tokens (used)
  "Format USED token count with human-readable suffix."
  (cond ((>= used 1000000) (format "%.1fM" (/ used 1000000.0)))
        ((>= used 1000) (format "%.1fk" (/ used 1000.0)))
        (t (number-to-string used))))

(defun acp-modeline--format-currency (amount currency)
  "Format AMOUNT with the symbol for the CURRENCY code."
  (let ((symbol (pcase (upcase currency)
                  ("USD" "$")
                  (_ (error "Unsupported currency: %s" currency)))))
    (format "%s%.4f" symbol amount)))

(provide 'acp-modeline)
;;; acp-modeline.el ends here
