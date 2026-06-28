;;; acp-test-utils.el --- Shared test helpers for ACP.el  -*- lexical-binding: t; -*-

(defmacro with-tmp (content var &rest body)
  "Create a temporary file, bind its path to VAR, and evaluate BODY.
The temporary file is guaranteed to be deleted when BODY finishes."
  (declare (indent 2))
  `(let ((,var (make-temp-file "emacs-tmp-")))
     (with-temp-file ,var
       (insert ,content))
     (unwind-protect
         (progn ,@body)
       (delete-file ,var))))

(defun intervals (str)
  (let ((intervals (object-intervals str)))
    (if (null intervals)
        `((,str))
      (mapcar (lambda (interval)
                (let ((start (nth 0 interval))
                      (end (nth 1 interval))
                      (plist (nth 2 interval)))
                  (cons (substring-no-properties str start end) plist)))
              (object-intervals str)))))

(provide 'acp-test-utils)
;;; acp-test-utils.el ends here
