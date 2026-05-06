;; -*- lexical-binding: t; -*-
;; Change native-comp-speed for performance
(setq native-comp-speed 3)

(native-compile-async "/usr/lib/emacs/31.0.50/native-lisp" 'recursively)
(setq native-comp-compiler-options '("-march=znver3" "-Ofast" "-g0" "-fno-finite-math-only" "-fgraphite-identity" "-floop-nest-optimize" "-fdevirtualize-at-ltrans" "-fipa-pta" "-fno-semantic-interposition" "-flto=auto" "-fuse-linker-plugin"))

(setq native-comp-driver-options '("-march=znver3" "-Ofast" "-g0" "-fno-finite-math-only" "-fgraphite-identity" "-floop-nest-optimize" "-fdevirtualize-at-ltrans" "-fipa-pta" "-fno-semantic-interposition" "-flto=auto" "-fuse-linker-plugin"))

;; Build and activate Elpaca
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Setup use-package
(elpaca elpaca-use-package
  (elpaca-use-package-mode)
  (setq use-package-always-ensure t) ; Ensure packages are installed
  )


;; Basic emacs configurations
(use-package emacs
  :ensure nil
  :init
  (setq use-short-answers t
		backup-directory-alist '(("." . "~/.saves"))
		create-lockfiles nil
		tab-always-indent 'complete)
  :config
  (setq-default truncate-lines t
				display-line-numbers t
				fill-column 80
				tab-width 4)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (show-paren-mode 1)
  (delete-selection-mode 1)) ; Automatically delete selected text when you start typing


;; Theme
(load-theme 'modus-operandi-tinted)

(use-package windmove
  :ensure nil
  :bind
  (("M-<left>" . windmove-left)
   ("M-<right>" . windmove-right)
   ("M-<up>" . windmove-up)
   ("M-<down>" . windmove-down)))


(use-package golden-ratio
  :hook (after-init . golden-ratio-mode)
  :config
  (golden-ratio-toggle-widescreen))


(use-package vundo
  :config
  (setq vundo-compact-display t)
  :bind
  ("C-M-z" . vundo))


;; Follow symlinks that links to a file in a git repo
(setq vc-follow-symlinks t)

(setq xref-search-program 'ripgrep)


;; Completion
(use-package vertico
  :config
  (vertico-mode)
  (vertico-multiform-mode)
  :custom
  (vertico-resize t)
  (vertico-count 15))

(use-package marginalia :init (marginalia-mode))

(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-trigger ".")
  (corfu-quit-no-match t)
  (corfu-quit-no-match))



(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t)
  (orderless-matching-styles '(orderless-flex orderless-regexp orderless-literal)))


(use-package which-key
  :init
  (which-key-mode)
  (which-key-setup-minibuffer)
  :config
  (setq which-key-idle-delay 0.3)
  (setq which-key-sort-order 'which-key-key-order-alpha
		which-key-min-display-lines 3
		which-key-max-display-columns nil)) 


;; Copy-Paste between Emacs and Windows (WSL2)
(setq select-active-regions nil)
(setq select-enable-clipboard 't)
(setq select-enable-primary nil)
(setq interprogram-cut-function #'gui-select-text)


;; RSS Reader
(use-package newsticker
  :ensure nil
  :custom
  (newsticker-url-list
   '(("https://sachachua.com/blog/feed" "Sasha Chua's Blog")
	 ("https://protesilaos.com/master.xml" "Protesilaos Stavrou")
	 ("https://planet.emacslife.com/atom.xml" "Planet Emacs Life")
	 ("https://karl-voit.at/feeds/lazyblorg-all.atom_1.0.links-and-content.xml" "Karl Voit – Lazyblorg")
	 ("https://irreal.org/blog/?feed=rss2" "Irreal")
	 ("https://www.emacswiki.org/emacs?action=rss" "Emacs Wiki")
	 ("https://gluer.org/rss/" "Gluer.org")
	 ("https://fnguy.com/atom.xml" "fnguy.com")
	 ("https://xenodium.com/feed" "Xenodium")
	 ("https://j3s.sh/feed.atom" "j3s")
	 ("https://www.dbdebunk.com/feeds/posts/default" "Database Debunkings")
	 ("https://mydbanotebook.org/posts/" "My DBA Notebook")
	 ("https://clojure.org/feed.xml" "Clojure")
	 ("https://planet.clojure.in/" "Planet Clojure")
	 ("https://clojurebr.substack.com/feed" "(concat)")
	 ("https://www.jvm-weekly.com/feed" "JVM Weekly")
	 ("https://inside.java/feed.xml" "Inside Java")
	 ("https://blog.jetbrains.com/feed/" "JetBrains Blog")
	 ("https://vladmihalcea.com/feed/" "Vlad Mihalcea")
	 ("https://www.sivalabs.in/index.xml" "SivaLabs"))))

(defun close-newsticker ()
  "Kill all tree-view related buffers."
  (kill-buffer "*Newsticker List*")
  (kill-buffer "*Newsticker Item*")
  (kill-buffer "*Newsticker Tree*"))

(advice-add 'newsticker-treeview-quit :after 'my/close-newsticker)


;; Org
(use-package denote
  :custom
  (denote-directory (expand-file-name "~/org/"))
  :hook
  (dired-mode . denote-dired-mode)
  :bind
  (("C-c n n" . denote)
   ("C-c n r" . denote-rename-file)
   ("C-c n l" . denote-link)
   ("C-c n b" . denote-backlinks)
   ("C-c n d" . denote-dired)
   ("C-c n g" . denote-grep))
  :config
  (denote-rename-buffer-mode 1))
(use-package denote-org)

(setq org-agenda-include-diary t
	  org-agenda-diary-file "~/diary"
	  diary-file "~/diary")

;;; PlantUML
(setq org-plantuml-exec-mode 'plantuml)
(use-package plantuml-mode
  :custom (org-plantuml-executable-path (executable-find "plantuml")))


(load-file "~/.emacs.d/programming.el")


;; Pinentry
(setq epg-pinentry-mode 'loopback)
