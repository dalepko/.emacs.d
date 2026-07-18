;;; acp-test.el --- Tests for acp.el  -*- lexical-binding: t; -*-
(require 'ert)

(require 'acp)
(require 'python)

(ert-deftest acp-capture-context-python-function ()
  "Capture context in a Python buffer visiting a file."
  (with-temp-buffer
    (insert "
def hello_world():
    print('Hello')

def goodbye():
    print('Goodbye')
")
    (python-mode)
    (goto-char (point-min))
    (search-forward "hello_world")
    (let* ((default-directory "/project/")
           (buffer-file-name "/project/tests/test_hello.py")
           (result (acp--capture-context)))
      (should (equal result "[Context: editing tests/test_hello.py, in function `hello_world']\n\n")))))

(ert-deftest acp-capture-context-selection ()
  "Capture context with an active region includes the selected text."
  (with-temp-buffer
    (insert "# before
def hello_world():
    print(\"Hello\")
# after
")
    (goto-char (point-min))
    (forward-line 1)
    (set-mark (point))
    (forward-line 2)
    (activate-mark)
    (let* ((default-directory "/project/")
           (buffer-file-name "/project/tests/test.py")
           (result (acp--capture-context)))
      (should (equal result "[Context: editing tests/test.py, selected text: \"def hello_world():\\n    print(\\\"Hello\\\")\\n\"]\n\n")))))

(ert-deftest acp-capture-context-no-file ()
  "Returns nil when the buffer is not visiting a file."
  (with-temp-buffer
    (insert "no file here")
    (let ((result (acp--capture-context)))
      (should (eq result nil)))))

(provide 'acp-test)
;;; acp-test.el ends here
