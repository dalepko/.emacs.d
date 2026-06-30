;;; acp-frame.el --- Bordered frame utility for ACP REPL  -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'seq)

(defun acp-frame-create (title start end)
  "Draw a bordered frame around content between START and END.
Returns a list of overlays for `acp-frame-delete'."
  (let ((prefix (propertize "║ " 'face 'default))
        (suffix (concat
                 (propertize " " 'cursor t 'display '(space :align-to (- right 2)))
                 (propertize " ║" 'face 'default)))
        (first-suffix (concat
                 (propertize " " 'display '(space :align-to (- right 3)))
                 (propertize "══╗" 'face 'default)))
        (end-suffix (concat
                 (propertize " " 'display '(space :align-to (- right 3)))
                 (propertize "══╝" 'face 'default)))
        (overlays nil))
    (save-excursion
      (goto-char start)
      (while (search-forward "\n" end t)
        (let ((overlay (make-overlay (1- (point)) (point))))
          (overlay-put overlay 'acp-frame t)
          (overlay-put overlay 'evaporate t)
          (overlay-put overlay 'before-string suffix)
          (overlay-put overlay 'after-string prefix)
          (push overlay overlays))))
    (let* ((existing-overlay (acp-frame--get-overlay start))
           (start-overlay (or existing-overlay (make-overlay start (1+ start)))))
      (overlay-put start-overlay 'acp-frame t)
      (overlay-put start-overlay 'evaporate t)
      (overlay-put start-overlay 'before-string
                   (format "╔══ %s %s\n%s%s" title first-suffix prefix
                           (if existing-overlay suffix "")))
      (unless existing-overlay
        (push start-overlay overlays)))
    (let ((end-overlay (or (acp-frame--get-overlay (1- end)) (make-overlay (1- end) end))))
      (overlay-put end-overlay 'acp-frame t)
      (overlay-put end-overlay 'evaporate t)
      (overlay-put end-overlay 'after-string (format "╚══%s\n" end-suffix))
      (cl-pushnew end-overlay overlays))
    overlays))

(defun acp-frame--get-overlay (position)
  (seq-find (lambda (overlay) (overlay-get overlay 'acp-frame)) (overlays-at position)))

(defun acp-frame-delete (overlays)
  (dolist (ov overlays)
    (delete-overlay ov)))

(provide 'acp-frame)
;;; acp-frame.el ends here
