;; -*- lexical-binding: t; -*-
(use-package eglot
  :ensure nil
  :hook (java-ts-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
			   '((java-mode java-ts-mode) .
				 ("jdtls"
				  :initializationOptions
				  (:bundles ["/usr/share/java-debug/com.microsoft.java.debug.plugin.jar"]))))
  :bind (("C-c l f" . eglot-format-buffer)
		 ("C-c l a" . eglot-code-actions)
		 ("C-c l g i" . eglot-find-implementation)
		 ("C-c l g d" . eglot-find-declaration)))


(use-package magit
  :bind ("C-x g" . magit-status))



;; SQL
(use-package sqlformat
  :config
  (setq sqlformat-command 'pgformatter))


;; Java
(use-package java-ts-mode
  :ensure nil
  :mode "\\.java\\'")


;; Debug
(use-package dape)
