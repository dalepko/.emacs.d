;;; acp-frame-test.el --- Tests for acp-frame  -*- lexical-binding: t; -*-
(require 'ert)
(require 'acp-frame)

;; ── ERT tests ───────────────────────────────────────────────────────────────

(ert-deftest acp-frame-create-basic ()
  "Overlays are created for newlines plus a start overlay."
  (with-temp-buffer
    (insert "line one\nline two\nline three\n")
    (let ((ovs (acp-frame-create "Test" (point-min) (point-max))))
      ;; 3 newline overlays + 1 start overlay = 4
      ;; (end overlay reuses last newline overlay via cl-pushnew)
      (should (= (length ovs) 4))
      ;; Every overlay has the acp-frame property
      (should (cl-every (lambda (ov) (overlay-get ov 'acp-frame)) ovs))
      ;; All overlays span exactly 1 char
      (should (cl-every (lambda (ov) (= 1 (- (overlay-end ov) (overlay-start ov)))) ovs))
      ;; Buffer text is unchanged (pure overlay approach)
      (should (equal (buffer-string) "line one\nline two\nline three\n"))
      (acp-frame-delete ovs)
      (should (cl-every (lambda (ov) (null (overlay-buffer ov))) ovs)))))

(ert-deftest acp-frame-create-single-line ()
  "Works with a single content line."
  (with-temp-buffer
    (insert "only line\n")
    (let ((ovs (acp-frame-create "Solo" (point-min) (point-max))))
      ;; 1 newline overlay + 1 start overlay = 2
      ;; (end overlay reuses the newline overlay)
      (should (= (length ovs) 2))
      (acp-frame-delete ovs))))

(ert-deftest acp-frame-create-empty-lines ()
  "Empty lines (bare \\n) get valid 1-char overlays."
  (with-temp-buffer
    (insert "alpha\n\nbeta\n")
    (let ((ovs (acp-frame-create "Gaps" (point-min) (point-max))))
      (should (cl-every (lambda (ov) (= 1 (- (overlay-end ov) (overlay-start ov)))) ovs))
      (acp-frame-delete ovs))))

(ert-deftest acp-frame-delete-cleans-up ()
  "After deletion no overlays remain and buffer is unchanged."
  (with-temp-buffer
    (let ((text "content\n"))
      (insert text)
      (let ((ovs (acp-frame-create "X" (point-min) (point-max))))
        ;; Buffer text unchanged (pure overlay approach)
        (should (equal (buffer-string) text))
        (acp-frame-delete ovs)
        (should (equal (buffer-string) text))
        (should (null (overlays-in (point-min) (point-max))))))))

;; ── Interactive test ────────────────────────────────────────────────────────

(defun acp-frame-test ()
  "Open a test buffer displaying sample frames."
  (interactive)
  (let ((buffer (get-buffer-create "*acp-frame-test*")))
    (pop-to-buffer buffer)
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)

        ;; Frame 1: multi-line with an empty line
        (insert "before\n")
        (let ((start (point)))
          (insert "First line of content\n\n"
                  "Second line with more text\n"
                  "Third line — the last one\n")
          (acp-frame-create "Multi-line frame" start (point)))
        (insert "after")

        ;; Frame 2: start with an empty line
        (insert "\n\nbefore\n")
        (let ((start (point)))
          (insert "\n"
                  "First line of content\n\n")
          (acp-frame-create "Multi-line frame" start (point)))
        (insert "after")

        ;; Frame 3: a single empty line
        (insert "\n\nbefore\n")
        (let ((start (point)))
          (insert "\n")
          (acp-frame-create "Multi-line frame" start (point)))
        (insert "after")

        ))

    ))

(provide 'acp-frame-test)
;;; acp-frame-test.el ends here
