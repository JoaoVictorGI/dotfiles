;; -*- lexical-binding: t; -*-
;; Most of these configurations come from: https://github.com/D4lj337/Emacs-performance

;; Disable package.el
(setq package-enable-at-startup nil)

;; Increase GC threshold
(setq gc-cons-threshold 100000000)

;; Improve performance with LSPs
(setq read-process-output-max (* 4 1024 1024))

;; Improve tree-sitter performance
(setenv "LSP_USE_PLISTS" "true")
(setq lsp-use-plists t)

;; Disable "file-name-handler-alist" than enable it later for speed.
(defvar startup/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist startup/file-name-handler-alist)
            (makunbound 'startup/file-name-handler-alist)))

(setq
 inhibit-splash-screen t
 inhibit-startup-screen t
 inhibit-startup-message t
 inhibit-startup-buffer-menu t)

(setq
 mode-line-format nil
 make-backup-files nil
 backup-directory-alist '((".*" . "~/.local/share/Trash/files")))

(custom-set-faces
 ;; Default font for all text
 '(default ((t (:family "Iosvmata" :height 110))))
 '(fixed-pitch ((t (:family "Iosvmata" :height 110)))))

;; Fix gap in the bottom
(setq frame-resize-pixelwise t)
(setq window-resize-pixelwise nil)

;; Stolen from here 
;; https://emacsredux.com/blog/2026/04/07/stealing-from-the-best-emacs-configs/
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

(setq redisplay-skip-fontification-on-input t)

(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)
