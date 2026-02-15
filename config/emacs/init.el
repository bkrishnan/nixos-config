;; Disable package.el completely (packages managed by Nix)
(setq package-enable-at-startup nil)
(setq package-archives nil)

;; Pre-load all packages since they're built into the Nix Emacs
;; This ensures use-package can find them with :ensure nil
(require 'vertico)
(require 'marginalia)
(require 'orderless)
(require 'denote)
(require 'ef-themes)

;; Enable Vertico.
;; https://github.com/minad/vertico
(use-package vertico
  :ensure nil
  ;; :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

;; Enable rich annotations using the Marginalia package
;; https://github.com/minad/marginalia
(use-package marginalia
  :ensure nil
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

;; https://github.com/oantolin/orderless
(use-package orderless
  :ensure nil
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; http://xahlee.info/emacs/emacs/emacs_set_backup_into_a_directory.html
;; disable emacs automatic backup~ file
(setq make-backup-files nil)

;; Power user packages that are now enabled
(put 'narrow-to-region 'disabled nil)

;; Org-mode BEGIN ==========================================================

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c C-x t") #'org-toggle-link-display)
(setq org-log-done 'time)

;; Protesilaos tweaks
;; Emacs: Org todo and agenda basics
;; https://youtu.be/L0EJeN1fCYw?t=2073
(use-package org
  :ensure nil
  :config
  (setq org-use-speed-commands t)
  (setq org-M-RET-may-split-line '((default . nil)))
  (setq org-insert-heading-respect-content t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-tag-alist '(
			(:startgroup . nil)
			("@anywhere" . ?a) ("@home" . ?h) ("@errands" . ?e) ("@india" . ?i)
			("@computer" . ?c)  ("@imac" . ?m) ("@thinkpad" . ?t) ("@phone" . ?p)
			("@lavanya" . ?l)  ("@ramki" . ?r)  ("@bommi" . ?b)
			(:endgroup . nil)
			)
  )
  (setq org-agenda-files '("~/Notes/org/gtd.org"
			   "~/Notes/org/dbot.org"
                           "~/Notes/org/tickler.org"))
  ;; https://orgmode.org/manual/Tracking-TODO-state-changes.html
  (setq org-todo-keywords '((sequence "TODO(t)" "WAIT(w@/!)" "|" "DONE(d@)" "CANCEL(c@/!)")))
  (setq org-capture-templates '(("t" "Todo [inbox]" entry
				 (file+headline "~/Notes/org/inbox.org" "Tasks")
                                 "* %i%?")
                                 ("T" "Tickler" entry
                                 (file+headline "~/Notes/org/tickler.org" "Tickler")
                                 "* %i%? \n %U")))
  (setq org-refile-targets '(("~/Notes/org/gtd.org" :maxlevel . 3)
			     ("~/Notes/org/someday.org" :level . 1)
                             ("~/Notes/org/tickler.org" :maxlevel . 2)))
  )

;; Other GTD setup - https://archive.is/fcSzM
;; I use custom agenda commands mostly to get an overview of actions by context or tag.
;; Here's an example custom agenda command that will display all actions for the @office context:
;; https://orgmode.org/worg/org-tutorials/org-custom-agenda-commands.html
(setq org-agenda-custom-commands 
      '(("o" "At the office" tags-todo "@office"
         ((org-agenda-overriding-header "Office")
          (org-agenda-skip-function #'my-org-agenda-skip-all-siblings-but-first)))))

;; Following the GTD principle, what I usually want is to only show the first action to be done (or next action) for each project with the @office tag
;; That can be achieved using a skipping condition:
(defun my-org-agenda-skip-all-siblings-but-first ()
  "Skip all but the first non-done entry."
  (let (should-skip-entry)
    (unless (org-current-is-todo)
      (setq should-skip-entry t))
    (save-excursion
      (while (and (not should-skip-entry) (org-goto-sibling t))
        (when (org-current-is-todo)
          (setq should-skip-entry t))))
    (when should-skip-entry
      (or (outline-next-heading)
          (goto-char (point-max))))))
		  
(defun org-current-is-todo ()
  (string= "TODO" (org-get-todo-state)))

;; Org-mode END  ==========================================================

;; Denote
(use-package denote
  :ensure nil
  :hook (dired-mode . denote-dired-mode)
  :bind
  (("C-c n n" . denote)
   ("C-c n N" . denote-type)
   ("C-c n r" . denote-rename-file)
   ("C-c n l" . denote-link)
   ("C-c n b" . denote-backlinks)
   ("C-c n d" . denote-sort-dired))
  :config
  (setq denote-directory (expand-file-name "~/Notes/denote/"))
  ;; default is Org---others are Markdown+{TOML,YAML} and plain text
  (setq denote-file-type nil)

  ;; Automatically rename Denote buffers when opening them so that
  ;; instead of their long file name they have, for example, a literal
  ;; "[D]" followed by the file's title.  Read the doc string of
  ;; `denote-rename-buffer-format' for how to modify this.
  (denote-rename-buffer-mode 1))

;; Themes
;; modus-themes
;;(load-theme 'modus-operandi)
;;(load-theme 'modus-vivendi)

;; Emacs: use-package essentials
;; https://www.youtube.com/watch?v=RaqtzemHFDU
(use-package ef-themes
  :ensure nil
  :config
  (ef-themes-select 'ef-cyprus))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(denote ef-themes marginalia modus-themes orderless vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
