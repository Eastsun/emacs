;; Emacs configuration all in one file
;; Version: 0.11
;; Author: Eastsun
;; Date: 2013-03-24
;--------------------pre defined variable ------------------
;; Set gnu-ensime-root-dir to "" if you don't use ensime
(defvar gnu-ensime-root-dir "/home/future/dev/ensime_2.10.0-0.9.8.9")
(defvar win-ensime-root-dir "F:/Dev/ensime_2.10.0-0.9.8.9")
;; The full path of okular in windows
(defvar win-path-to-okular "F:/KDE/bin/okular.exe")
;; The full path of RTemin in windows
(defvar win-path-to-r "F:/Math/R-2.15.3/bin/i386/Rterm.exe")

;; The directory of numpy packages
;; You cant get it from
; import os; import numpy; print(os.path.dirname(os.path.dirname(numpy.__file__)))
(defconst win-numpy-root-dir "")
(defconst gnu-numpy-root-dir "/usr/lib/python2.7/dist-packages")
;;----install related packages manual if want to use python ---
; for linux
;<sudo easy_install pip>
;sudo pip install jedi
;sudo pip install epc
;%%%%%%%%%%%%%%%%%%%%%% init & install packages if needed %%%%%%%%%%%%%%%%%%%%
(setq debug-on-error t)
(require 'package)
(setq package-archives '(
   ("gnu" . "http://elpa.gnu.org/packages/") 
   ("melpa" . "http://melpa.milkbox.net/packages/")
   ("marmalade" . "http://marmalade-repo.org/packages/")
   ))
(package-initialize)

(when (not package-archive-contents) (package-refresh-contents))
(defvar my-packages 
  '(ac-math autopair ess auctex python yasnippet auto-complete tabbar scala-mode2 magit)
  "A list of packages to ensure are installed at launch."
)

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)
  ))

;;;;;;;;;;python ;;;;;;;;;;;;;;;;
(cond ((eq system-type 'windows-nt) (defconst numpy-root-dir win-numpy-root-dir))
      ((eq system-type 'gnu/linux) (defconst numpy-root-dir gnu-numpy-root-dir)))

(when (not (string-equal numpy-root-dir ""))
      (unless (package-installed-p 'jedi) (package-refresh-contents) (package-install 'jedi))
      (autoload 'jedi:setup "jedi" nil t)
      (setq jedi:complete-on-dot t)
      (add-hook 'python-mode-hook 'jedi:setup)
      (setq jedi:server-args '("--sys-path" "/usr/lib/python2.7/dist-packages")))

(server-start)
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%Custom Setting%%%%%%%%%%%%%%%%%%%%%%%%%%%%
(custom-set-variables
 '(LaTeX-command "latex -synctex=1")
 '(ansi-color-names-vector ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"])
 '(custom-enabled-themes (quote (tango-dark)))
 '(preview-gs-options (quote ("-q" "-dNOPAUSE" "-DNOPLATFONTS" "-dPrinted" "-dTextAlphaBits=4" "-dGraphicsAlphaBits=4")))
 '(tool-bar-mode nil)
 '(menu-bar-mode nil)
 '(gnus-inhibit-startup-message t)
 '(inhibit-startup-message t)
 '(auto-image-file-mode t)
 '(make-backup-files nil)
 '(x-select-enable-clipboard t)
 '(frame-title-format " sun@ %f")
 '(show-paren-mode t)
 '(global-linum-mode t)
;'(global-hl-line-mode t)
 '(linum-format "%3d")
)
(set-face-foreground 'linum "white")
;(set-face-background 'hl-line "#749")
(add-to-list 'load-path "~/.emacs.d/")
(cond ((eq system-type 'windows-nt)
       (set-default-font "Consolas-11")
       (set-fontset-font (frame-parameter nil 'font)
			 'han '("Microsoft YaHei" . "unicode-bmp"))
       (set-fontset-font (frame-parameter nil 'font)
			 'cjk-misc '("Microsoft Yahei" . "unicode-bmp"))
       (set-fontset-font (frame-parameter nil 'font)
			 'bopomofo '("Microsoft Yahei" . "unicode-bmp"))
       (set-fontset-font (frame-parameter nil 'font)
			 'gb18030 '("Microsoft Yahei". "unicode-bmp"))
       (when (not (string-equal win-path-to-r "")) (setq inferior-R-program-name win-path-to-r))
))
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Packages' configurations%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;------tabbar-------
(tabbar-mode 1)
(global-set-key [(M-left)]    'tabbar-backward)
(global-set-key [(M-right)]   'tabbar-forward)
;------yas & auto ------
(yas-global-mode 1)
(setq-default mode-require-final-newline nil)
(yas/load-directory "~/.emacs.d/snippets/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)
(add-to-list 'ac-modes 'latex-mode 'python-mode)
;-----auctex--------
(defun okular-make-url () 
  (concat
   "\"file://"
   (expand-file-name (funcall file "pdf" t)
		     (file-name-directory (TeX-master-file)))
   "#src:"
   (TeX-current-line) (buffer-file-name)
   "\""))
(add-hook 'LaTeX-mode-hook '(lambda ()
			      (add-to-list 'TeX-expand-list '("%u" okular-make-url))
))

(require 'ac-math)					   
(add-hook 'LaTeX-mode-hook
  (lambda ()
    (setq ac-sources '(ac-source-math-latex ac-source-latex-commands ac-source-yasnippet))
  )
)

(setq reftex-plug-into-AUCTeX t)     ;;RefTex
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)  
(setq reftex-toc-split-windows-horizontally t)
(setq reftex-toc-split-windows-horizontally-fraction 0.15)
(modify-coding-system-alist 'file ".*\\.tex\\'" 'chinese-gbk-dos)
(setq preview-scale-function 1.5)
(setq preview-auto-cache-preamble nil)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)
(add-hook 'LaTeX-mode-hook 
  (lambda () 
    (TeX-PDF-mode t)
    (setq TeX-save-query nil) 
  )
)

(cond ((eq system-type 'windows-nt)
       (setq TeX-command-list
	     '(("TeX" "tex --src \"\\nonstopmode\\input %t\"" TeX-run-TeX nil t)
	       ("LaTeX" "%l --src \"\\nonstopmode\\input{%t}\"" TeX-run-LaTeX nil t)
	       ("View" "yap -1  -s %n%b %d" TeX-run-discard nil nil)
	       ("SView" (concat win-path-to-okular " --unique %o") TeX-run-discard nil nil)
	       ("PView" "start \"\" %s.pdf" TeX-run-command nil t)
	       ("BibTeX" "bibtex %s" TeX-run-BibTeX nil nil)
	       ("Index" "makeindex %s" TeX-run-command nil t)
	       )))
      ((eq system-type 'gnu/linux)
       (setq TeX-view-program-list '(("Okular" "okular --unique %u" TeX-run-command nil t)))
       (setq TeX-view-program-selection '((output-pdf "Okular") (output-dvi "Okular")))
       ))
;---------- scala --------------
(add-hook 'scala-mode-hook
  (lambda ()
    (local-set-key (kbd "RET") 'newline-and-indent)
    (setq scala-indent:default-run-on-strategy scala-indent:operator-strategy)
    (setq scala-indent:indent-value-expression t)
    (setq scala-indent:align-parameters t)
    (setq scala-indent:align-forms t)
    (setq ac-sources '(ac-source-words-in-same-mode-buffers ac-source-dictionary ac-source-yasnippet ac-source-words-in-same-mode-buffers ac-source-files-in-current-dir))
  )
)

(cond ((eq system-type 'windows-nt) (defvar ensime-root-dir win-ensime-root-dir))
      ((eq system-type 'gnu/linux) (defvar ensime-root-dir gnu-ensime-root-dir)))
       
(when (not (string-equal ensime-root-dir ""))
      (add-to-list 'load-path (concat ensime-root-dir "/elisp/"))
      (require 'ensime)
      (add-hook 'scala-mode-hook 'ensime-scala-mode-hook))

;------------ess --------------
(require 'ess-site)
;-----------magit-------------
(require 'magit)
;-------autopair---
(require 'autopair)
(autopair-global-mode)
