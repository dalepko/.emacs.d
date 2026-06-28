;;; acp-icon.el --- Create SVG icons  -*- lexical-binding: t; -*-
(defvar acp-icon--cache (make-hash-table :test #'equal))

(defvar acp-icon--icons
  '(
    (read    . "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='CURRENT_COLOR' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z'/><path d='M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z'/></svg>")
    (edit    . "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='CURRENT_COLOR' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7'/><path d='M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z'/></svg>")
    (delete  . "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='CURRENT_COLOR' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M3 6h18'/><path d='M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2'/></svg>")
    (move    . "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='CURRENT_COLOR' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><polyline points='5 9 2 12 5 15'/><polyline points='9 5 12 2 15 5'/><polyline points='19 9 22 12 19 15'/><polyline points='9 19 12 22 15 19'/><line x1='2' y1='12' x2='22' y2='12'/><line x1='12' y1='2' x2='12' y2='22'/></svg>")
    (search  . "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='CURRENT_COLOR' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><circle cx='11' cy='11' r='8'/><line x1='21' y1='21' x2='16.65' y2='16.65'/></svg>")
    (execute . "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='CURRENT_COLOR' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><polyline points='4 17 10 11 4 5'/><line x1='12' y1='19' x2='20' y2='19'/></svg>")
    (think   . "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='CURRENT_COLOR' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M9 18h6'/><path d='M10 22h4'/><path d='M15.09 14c.18-.98.65-1.74 1.41-2.5A4.65 4.65 0 0 0 18 8 6 6 0 0 0 6 8c0 1 .23 2.23 1.5 3.5A4.61 4.61 0 0 1 8.91 14'/></svg>")
    (fetch   . "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='CURRENT_COLOR' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4'/><polyline points='7 10 12 15 17 10'/><line x1='12' y1='15' x2='12' y2='3'/></svg>")
    (other   . "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='CURRENT_COLOR' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><circle cx='12' cy='12' r='1'/><circle cx='19' cy='12' r='1'/><circle cx='5' cy='12' r='1'/></svg>")
    (plan-pending    . "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='CURRENT_COLOR' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><rect x='3' y='3' width='18' height='18' rx='2' ry='2'/></svg>")
    (plan-completed  . "<svg width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='CURRENT_COLOR' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><rect x='3' y='3' width='18' height='18' rx='2' ry='2'/><polyline points='9 12 11 14 15 10'/></svg>")

    )
  "Alist mapping tool types to raw SVG XML strings.")

(defun acp-icon-get (kind face)
  "Generate a native Emacs image object for the given KIND and STATUS.
The icon color is dynamically extracted from the status face."
  (if-let ((cached-icon (gethash (cons kind face) acp-icon--cache)))
      cached-icon
    (if-let ((svg-template (cdr (assoc kind acp-icon--icons))))
        (let* ((fg-color (face-foreground face nil t))
               (fv (and fg-color (color-values fg-color)))
               (hex-color (if fv
                              (apply 'format "#%02x%02x%02x"
                                     (mapcar (lambda (c) (ash c -8)) fv))
                            "#ffffff"))
               (final-svg-string (replace-regexp-in-string "CURRENT_COLOR" hex-color svg-template)))
          (puthash (cons kind face)
                   (create-image final-svg-string 'svg t
                                 :ascent 'center
                                 :margin '(0 . 0)
                                 :background nil)
                   acp-icon--cache))
      (error "can't create image %s for face %s" kind face))))

(provide 'acp-icon)
;;; acp-icon.el ends here

