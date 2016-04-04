;; -*- lexical-binding: t -*-

(require 'ansi-color)


(setq hspec-last-test-file nil)

(defun hspec-set-buffer (buffer arg)
  (let ((ansi-color-context nil))
    (with-current-buffer buffer
      (save-excursion
        (erase-buffer)
        (insert (ansi-color-apply arg))
        (set-buffer-modified-p nil)))))


(defun hspec-launch-test (init-buffer buffer process)
  (haskell-process-queue-command
   process
   (make-haskell-command
    :state t
    :go (lambda (state)
          (haskell-utils-async-watch-changes)
          (haskell-process-send-string process "hspec spec"))
    :live (lambda (state response)
            (hspec-set-buffer buffer (haskell-process-response process)))
    :complete (lambda (state response)
                (hspec-set-buffer buffer response)
                (haskell-utils-async-stop-watching-changes init-buffer)))))


(defun hspec-process-load-file (file &optional cont)
  "Load the current buffer file."
  (interactive)
  (save-buffer)
  (haskell-interactive-mode-reset-error (haskell-session))
  (hspec-process-file-loadish (format "load \"%s\"" (replace-regexp-in-string
                                                     "\""
                                                     "\\\\\""
                                                     file))
                              nil
                              (current-buffer)
                              cont))


(defun hspec-process-file-loadish (command reload-p module-buffer &optional cont)
  "Run a loading-ish COMMAND that wants to pick up type errors\
and things like that.  RELOAD-P indicates whether the notification
should say 'reloaded' or 'loaded'.  MODULE-BUFFER may be used
for various things, but is optional."
  (let ((session (haskell-session)))
    (haskell-session-current-dir session)
    (when haskell-process-check-cabal-config-on-load
      (haskell-process-look-config-changes session))
    (let ((process (haskell-process)))
      (haskell-process-queue-command
       process
       (make-haskell-command
        :state (list session process command reload-p module-buffer)
        :go (lambda (state)
              (haskell-process-send-string
               (cadr state) (format ":%s" (cl-caddr state))))
        :live (lambda (state buffer)
                (haskell-process-live-build
                 (cadr state) buffer nil))
        :complete (lambda (state response)
                    (haskell-process-load-complete
                     (car state)
                     (cadr state)
                     response
                     (cl-cadddr state)
                     (cl-cadddr (cdr state))
                     cont)))))))


(defun hspec-run-file (test-file)
  (interactive)
  (let ((init-buffer (current-buffer))
        (buffer (get-buffer-create (compilation-buffer-name "hspec" t nil)))
        (session (haskell-session))
        (process (haskell-interactive-process)))
    (with-current-buffer buffer
      (erase-buffer)
      (with-no-warnings (comint-mode))
      (compilation-shell-minor-mode)
      (set-buffer-modified-p nil))
    (display-buffer buffer '(nil (allow-no-window . t)))
    (hspec-process-load-file
     test-file
     (lambda (ok) (if ok
                      (hspec-launch-test init-buffer buffer process)
                    (hspec-set-buffer buffer
                                      (haskell-process-response process)))))))


(defun hspec-rerun ()
  (interactive)
  (if hspec-last-test-file
      (hspec-run-file hspec-last-test-file)
    (hspec-run)))


(defun hspec-run ()
  (interactive)
  (let ((file (buffer-file-name (current-buffer))))
    (setq hspec-last-test-file file)
    (hspec-run-file file)))
