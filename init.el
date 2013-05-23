;; Emacs configuration all in one file
;; Version: 0.12
;; Author: Eastsun
;; Date: 2013-03-25
;--------------------pre defined variable ------------------
;; Set it to "" if you don't use proxy
(defconst http-proxy-address "")
;; Set gnu-ensime-root-dir to "" if you don't use ensime
(defconst gnu-ensime-root-dir "/home/future/dev/ensime_2.10.0-0.9.8.9")
(defconst win-ensime-root-dir "")
;; The full path of okular in windows
(defconst win-path-to-okular "D:/KDE/bin/okular.exe")
;; The full path of RTemin in windows
(defconst win-path-to-r "F:/Math/R-2.15.3/bin/x64/Rterm.exe")
;; The directory of numpy packages
;; You cant get it from
; import os; import numpy; print(os.path.dirname(os.path.dirname(numpy.__file__)))
(defconst win-numpy-root-dir "C:/Program Files/Enthought/Canopy/App/appdata/canopy-1.0.0.1160.win-x86_64/lib/site-packages")
(defconst gnu-numpy-root-dir "/usr/lib/python2.7/dist-packages")
;; The directory where python installed
(defconst win-ipython-root-dir "C:/Program Files/Enthought/Canopy/App/appdata/canopy-1.0.0.1160.win-x86_64/Scripts")
;;----install related packages manual if want to use python ---
; for linux
;<sudo easy_install pip>
;sudo pip install jedi
;sudo pip install epc
;install ipython
;%%%%%%%%%%%%%%%%%%%%%% init & install packages if needed %%%%%%%%%%%%%%%%%%%%
(when (not (string-equal http-proxy-address ""))
  (setq url-using-proxy t)
  (setq url-proxy-services  `(("http" . ,http-proxy-address)))
)

(require 'package)
(setq package-archives '(
   ("gnu" . "http://elpa.gnu.org/packages/") 
   ("melpa" . "http://melpa.milkbox.net/packages/")
   ("marmalade" . "http://marmalade-repo.org/packages/")
   ))
(package-initialize)

(when (not package-archive-contents) (package-refresh-contents))
(defvar my-packages 
  '(ac-math autopair ess auctex yasnippet auto-complete tabbar scala-mode2 magit)
  "A list of packages to ensure are installed at launch."
)

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)
  ))

;;;;;;;;;;python ;;;;;;;;;;;;;;;;
(defconst numpy-root-dir (if (eq system-type 'windows-nt) win-numpy-root-dir gnu-numpy-root-dir))

(add-hook 'python-mode-hook
  (lambda () (local-set-key (kbd "RET") 'newline-and-indent)))
(when (not (string-equal numpy-root-dir ""))
      (unless (package-installed-p 'jedi) (package-refresh-contents) (package-install 'jedi))
      (autoload 'jedi:setup "jedi" nil t)
      (setq jedi:complete-on-dot t)
      (add-hook 'python-mode-hook 'jedi:setup)
      (setq jedi:server-args `("--sys-path", numpy-root-dir))

  (setq python-shell-interpreter "ipython"
        python-shell-interpreter-args ""
        python-shell-prompt-regexp "In \\[[0-9]+\\]: "
        python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
        python-shell-completion-setup-code "from IPython.core.completerlib import module_completion"
        python-shell-completion-module-string-code "';'.join(module_completion('''%s'''))\n"
        python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")
  (when (and (eq system-type 'windows-nt) (not (eq win-ipython-root-dir "")))
        (setq python-shell-interpreter "python.exe"
              python-shell-interpreter-args (concat "-i \"" win-ipython-root-dir  "/ipython-script.py" "\""))))

(server-start)
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%Custom Setting%%%%%%%%%%%%%%%%%%%%%%%%%%%%
(custom-set-variables
 '(ansi-color-names-vector ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"])
 '(auto-image-file-mode t)
 '(custom-enabled-themes (quote (tango-dark)))
 '(frame-title-format " sun@ %f" t)
 '(global-linum-mode t)
 '(gnus-inhibit-startup-message t)
 '(inhibit-startup-screen t)
 '(linum-format "%3d")
 '(make-backup-files nil)
 '(menu-bar-mode nil)
 '(preview-gs-options (quote ("-q" "-dNOPAUSE" "-DNOPLATFONTS" "-dPrinted" "-dTextAlphaBits=4" "-dGraphicsAlphaBits=4")))
 '(show-paren-mode t)
 '(tool-bar-mode nil)
 '(x-select-enable-clipboard t))
(set-face-foreground 'linum "white")
(add-to-list 'load-path "~/.emacs.d/")
(cond ((eq system-type 'windows-nt)
       (set-default-font "Consolas-11")
       (set-fontset-font (frame-parameter nil 'font) 'han '("Microsoft YaHei" . "unicode-bmp"))
       (set-fontset-font (frame-parameter nil 'font) 'cjk-misc '("Microsoft Yahei" . "unicode-bmp"))
       (set-fontset-font (frame-parameter nil 'font) 'bopomofo '("Microsoft Yahei" . "unicode-bmp"))
       (set-fontset-font (frame-parameter nil 'font) 'gb18030 '("Microsoft Yahei". "unicode-bmp"))
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
   (expand-file-name (funcall file "pdf" t) (file-name-directory (TeX-master-file)))
   "#src:"
   (TeX-current-line) (buffer-file-name) "\""))

(add-hook 'LaTeX-mode-hook '(lambda ()  (add-to-list 'TeX-expand-list '("%u" okular-make-url))))

(require 'ac-math)					   
(add-hook 'LaTeX-mode-hook
  (lambda () (setq ac-sources '(ac-source-math-latex ac-source-latex-commands ac-source-yasnippet)))
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
(setq LaTeX-command "latex -synctex=1")
(setq-default TeX-master nil)
(setq TeX-source-correlate-mode 1 )
(setq TeX-source-correlate-method 'source-specials)
(add-hook 'LaTeX-mode-hook 
  (lambda () 
    (TeX-PDF-mode t)
    (setq TeX-save-query nil)))

(cond ((eq system-type 'windows-nt)
       (setq TeX-view-program-list `(("Okular" ,(concat win-path-to-okular " --unique %u") TeX-run-command nil t)
                                     ("Yap" "yap -1  -s %n%b %d" TeX-run-command nil t)))
       (setq TeX-view-program-selection '((output-pdf "Okular") (output-dvi "Yap"))))
      ((eq system-type 'gnu/linux)
       (setq TeX-view-program-list '(("Okular" "okular --unique %u" TeX-run-command nil t)))
       (setq TeX-view-program-selection '((output-pdf "Okular") (output-dvi "Okular")))))
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

(defconst ensime-root-dir (if (eq system-type 'windows-nt) win-ensime-root-dir gnu-ensime-root-dir))
       
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
