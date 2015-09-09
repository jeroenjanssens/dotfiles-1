;;; funcs.el --- fmdkdd Layer functions File
;;
;; Copyright (c) 2015 fmdkdd
;;
;; Author: fmdkdd
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defun fmdkdd//auto-fill-comments ()
  (setq-local comment-auto-fill-only-comments t)
  (turn-on-auto-fill))

(defun fmdkdd//add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\|TODO\\|FIXME\\|HACK\\|REFACTOR\\|DELETE\\|XXX\\):"
          1 font-lock-warning-face t))))

(defun fmdkdd//customize-java-mode ()
  (c-set-style "user-java"))

(defun fmdkdd/moz-reload ()
  "Reload the current tab of Firefox using moz-repl."
  (interactive)
  (comint-send-string
   (inferior-moz-process)
   "content.document.location.reload(true);"))

(defun org-babel-execute:nodejs (body params)
  "Execute a block of JavaScript (through nodejs) code with org-babel."
  (let ((org-babel-js-cmd "node"))
    (org-babel-execute:js body params)))

(defun fmdkdd//turn-off-truncate-lines ()
  (setq truncate-lines nil))

(defun fmdkdd//org-reftex-setup (fun)
  "Setup the Reftex environment from looking up the BIBLIOGRAPHY
keyword in an Org file, and call FUN."
  (let ((reftex-docstruct-symbol 'rds)
        rds bib)
    (save-excursion
      (save-restriction
        (widen)
        (let ((case-fold-search t)
              (re "^#\\+bibliography:[ \t]+\\([^ \t\n]+\\)"))
          (if (not (save-excursion
                     (or (re-search-forward re nil t)
                         (re-search-backward re nil t))))
              (error "No bibliography defined in file")
            (setq bib (concat (match-string 1) ".bib")
                  rds (list (list 'bib bib)))))))
    (funcall fun)))

(defun fmdkdd/org-reftex-citation ()
  "Use reftex-citation to insert a citation into the buffer.
This looks for a line like

#+BIBLIOGRAPHY: foo

and derives from it that foo.bib is the bibliography file relevant
for this document.  It then installs the necessary environment for RefTeX
to work in this buffer and calls `reftex-citation'  to insert a citation
into the buffer."
  (interactive)
  (fmdkdd//org-reftex-setup
   (lambda ()
     (let ((reftex-cite-format "[[cite:%l][%l]]"))
       (call-interactively 'reftex-citation)))))

(defun fmdkdd/org-reftex-view-citation (&optional key)
  "Follow an Org cite link using Reftex."
  (interactive)
  (let ((key (or key
                 (org-icompleting-read "Citation: " (obe-citations)))))
    (fmdkdd//org-reftex-setup
     (lambda () (reftex-view-cr-cite nil key nil)))))

(defvar fmdkdd/papers-directory "~/Archimède/Thèse/papers"
  "Path to search for PDF files when following a cite link in Org
with `fmdkdd/org-view-paper'")

(defun fmdkdd/org-view-paper ()
  "Find the PDF file corresponding to the cite link under point in an Org file.
If point is on link [[cite:KEY][...]], then it will look for a
file named KEY.pdf in the directory specified by
`fmdkdd/papers-directory' and open it."
  (interactive)
  (save-excursion
    (when (org-in-regexp org-bracket-link-regexp 1)
      (setq link (org-extract-attributes
                  (org-link-unescape (org-match-string-no-properties 1))))
      (string-match org-link-re-with-space3 link)
      (setq type (match-string 1 link) path (match-string 2 link))
      (when (equal type "cite")
        (org-open-file (expand-file-name (concat path ".pdf")
                                         fmdkdd/papers-directory))))))
