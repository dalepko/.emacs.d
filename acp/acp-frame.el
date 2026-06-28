;;; acp-frame.el --- Bordered frame utility for ACP REPL  -*- lexical-binding: t; -*-

(defun acp-frame-create (title start end)
  "Draw a bordered frame around the content between START and END.
TITLE is displayed in the top-left corner.
Returns a list of overlays that can be passed to `acp-frame-delete'."
  (let* ((end-marker (copy-marker end t))
         (fill (propertize " "
                           'face '(:strike-through t :extend t)
                           'display '(space :align-to (- right 1))))
         (suffix (concat (propertize " "
                                     'cursor t
                                     'display '(space :align-to (- right 3)))
                         (propertize "  │" 'face `(:background ,(face-background 'default)
                                                               :foreground ,(face-foreground 'default)))))
         (overlays nil))
    (goto-char start)
    (while (< (point) end)
      (let* ((ov-start (point))
             (ov-end (line-end-position))
             (ov (make-overlay ov-start ov-end nil nil t))
             (current-line-prefix (get-text-property (point) 'line-prefix))
             (line-prefix (if current-line-prefix
                              (concat "│  " current-line-prefix)
                            "│  ")))
        (put-text-property ov-start (1+ ov-start) 'line-prefix line-prefix)
        (overlay-put ov 'after-string suffix)
        (overlay-put ov 'evaporate t)
        (push ov overlays))
      (forward-line 1))
    (goto-char start)
    (insert (format "┌── %s %s┐\n" title fill))
    (goto-char end-marker)
    (insert (format "└%s┘\n" fill))
    (set-marker end-marker nil)
    overlays))

(defun acp-frame-delete (overlays)
  "Delete every overlay in OVERLAYS, removing the frame."
  (dolist (ov overlays)
    (delete-overlay ov)))

(provide 'acp-frame)
;;; acp-frame.el ends here
