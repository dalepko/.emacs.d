;;; acp-prompt-widget.el --- Custom prompt widget for ACP REPL  -*- lexical-binding: t; -*-
(require 'widget)
(require 'wid-edit)
(require 'seq)

(defface acp-prompt-widget-face
  '((t :foreground "green"))
  "Face for the ACP prompt indicator."
  :group 'acp)

(defvar acp-prompt-widget-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "S-<return>") #'acp-prompt-widget--insert-newline)
    (define-key map (kbd "RET") #'acp-prompt-widget--maybe-submit)
    map)
  "Keymap for `acp-prompt-widget'.")

(defun acp-prompt-widget--insert-newline ()
  (interactive)
  (insert "\n"))

(defun acp-prompt-widget--maybe-submit ()
  (interactive)
  (if (bound-and-true-p completion-in-region-mode)
      (if-let ((binding (seq-some (lambda (map)
                                    (when (not (eq map acp-prompt-widget-keymap))
                                      (lookup-key map (kbd "RET"))))
                                  (current-active-maps))))
          (funcall binding)
        (widget-apply-action (widget-field-find (point))))
    (widget-apply-action (widget-field-find (point)))))


(define-widget 'acp-prompt-widget 'default
  "Custom prompt widget for the ACP REPL.
Displays a \"> \" prompt prefix and accepts multi-line input.
Uses `acp-prompt-widget-keymap' for keybindings and
`acp-prompt-widget-face' for the prompt face."
  :format "> %v"
  :size 1
  :action #'widget-field-action
  :keymap acp-prompt-widget-keymap
  :create #'acp-prompt-widget--create
  :value-create #'acp-prompt-widget--value-create
  :value-delete #'widget-field-value-delete
  :value-get #'widget-field-value-get)


(defun acp-prompt-widget--create (widget)
  (widget-default-create widget)
  (set-marker-insertion-type (widget-get widget :to) t))

(defun acp-prompt-widget--value-create (widget)
  (let ((value (widget-get widget :value))
        (start (point)))
    (insert value)
    (let ((overlay (make-overlay start (point) nil nil t)))
      (widget-put widget :field-overlay overlay)
      (overlay-put overlay 'field widget)
      (overlay-put overlay 'read-only nil)
      (overlay-put overlay 'face 'acp-prompt-widget-face)
      (overlay-put overlay 'keymap (widget-get widget :keymap))
      (widget-put widget :from (copy-marker (overlay-start overlay)))
      (widget-put widget :to (copy-marker (point)))
      (unless (memq widget widget-field-list)
        (setq widget-field-list (cons widget widget-field-list))))))

(provide 'acp-prompt-widget)
;;; acp-prompt-widget.el ends here
