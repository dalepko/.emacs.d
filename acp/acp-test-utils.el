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

(defun create-tool-call (kind status &rest plist)
  "Create an `acp-tool-call' for testing.
KIND and STATUS are required.  PLIST supplies remaining fields;
:title defaults to \"Test KIND\" if not given."
  (apply #'acp-tool-call--create
         :id "t1" :kind kind :status status
         (plist-put (copy-sequence plist) :title
                    (or (plist-get plist :title) (format "Test %s" kind)))))

(provide 'acp-test-utils)
;;; acp-test-utils.el ends here
