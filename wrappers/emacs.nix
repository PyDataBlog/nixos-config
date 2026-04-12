{ pkgs }:
let
  lib = pkgs.lib;
  shellPath = lib.getExe pkgs.nushell;
  emacsPackages = pkgs.emacsPackagesFor pkgs.emacs-pgtk;
  emacsConfigured = emacsPackages.emacsWithPackages (
    epkgs: with epkgs; [
      cape
      consult
      corfu
      doom-modeline
      doom-themes
      embark
      embark-consult
      evil
      evil-collection
      general
      helpful
      magit
      marginalia
      orderless
      org-modern
      use-package
      vertico
      vterm
      which-key
    ]
  );
  initDir = pkgs.runCommandLocal "emacs-init" { } ''
    mkdir -p "$out"
    cat > "$out/early-init.el" <<'EOF'
    (setq package-enable-at-startup nil
          inhibit-startup-screen t
          inhibit-startup-message t
          initial-scratch-message nil
          frame-inhibit-implied-resize t
          frame-resize-pixelwise t)

    (push '(menu-bar-lines . 0) default-frame-alist)
    (push '(tool-bar-lines . 0) default-frame-alist)
    (push '(vertical-scroll-bars . nil) default-frame-alist)
    (push '(internal-border-width . 12) default-frame-alist)
    EOF

    cat > "$out/init.el" <<'EOF'
    (defconst repo/emacs-state-dir
      (expand-file-name
       "emacs/"
       (or (getenv "XDG_STATE_HOME")
           (expand-file-name ".local/state" (getenv "HOME")))))

    (make-directory repo/emacs-state-dir t)

    (setq use-short-answers t
          ring-bell-function #'ignore
          make-backup-files nil
          auto-save-default nil
          create-lockfiles nil
          sentence-end-double-space nil
          inhibit-startup-screen t
          initial-scratch-message nil
          recentf-save-file (expand-file-name "recentf" repo/emacs-state-dir)
          recentf-max-saved-items 200
          savehist-file (expand-file-name "history" repo/emacs-state-dir)
          savehist-additional-variables '(kill-ring search-ring regexp-search-ring)
          tab-always-indent 'complete
          completion-cycle-threshold 3
          completion-ignore-case t
          read-file-name-completion-ignore-case t
          read-buffer-completion-ignore-case t
          enable-recursive-minibuffers t
          custom-file (expand-file-name "custom.el" repo/emacs-state-dir))

    (load custom-file 'noerror 'nomessage)

    (menu-bar-mode -1)
    (tool-bar-mode -1)
    (scroll-bar-mode -1)
    (blink-cursor-mode -1)
    (electric-pair-mode 1)
    (show-paren-mode 1)
    (savehist-mode 1)
    (recentf-mode 1)
    (save-place-mode 1)
    (global-auto-revert-mode 1)
    (winner-mode 1)
    (when (fboundp 'pixel-scroll-precision-mode)
      (pixel-scroll-precision-mode 1))

    (setq-default indent-tabs-mode nil
                  tab-width 2)

    (add-hook 'prog-mode-hook #'display-line-numbers-mode)
    (dolist (hook '(org-mode-hook term-mode-hook shell-mode-hook eshell-mode-hook vterm-mode-hook))
      (add-hook hook (lambda () (display-line-numbers-mode 0))))

    (require 'use-package)
    (setq use-package-always-ensure nil)

    (use-package doom-themes
      :config
      (load-theme 'doom-nord t))

    (use-package doom-modeline
      :hook (after-init . doom-modeline-mode)
      :custom
      (doom-modeline-height 24)
      (doom-modeline-icon nil))

    (use-package which-key
      :demand t
      :config
      (which-key-mode 1))

    (use-package vertico
      :demand t
      :config
      (vertico-mode 1))

    (use-package orderless
      :custom
      (completion-styles '(orderless basic))
      (completion-category-defaults nil)
      (completion-category-overrides '((file (styles basic partial-completion)))))

    (use-package marginalia
      :demand t
      :after vertico
      :config
      (marginalia-mode 1))

    (use-package consult
      :bind
      (("C-s" . consult-line)
       ("C-x b" . consult-buffer)
       ("M-y" . consult-yank-pop)
       ("C-c h" . consult-history)
       ("C-c i" . consult-imenu)))

    (use-package embark
      :bind
      (("C-." . embark-act)
       ("C-;" . embark-dwim)
       ("C-h B" . embark-bindings))
      :init
      (setq prefix-help-command #'embark-prefix-help-command))

    (use-package embark-consult
      :after (embark consult)
      :hook (embark-collect-mode . consult-preview-at-point-mode))

    (use-package corfu
      :demand t
      :custom
      (corfu-auto t)
      (corfu-cycle t)
      (corfu-preview-current nil)
      :config
      (global-corfu-mode 1))

    (use-package cape
      :init
      (add-to-list 'completion-at-point-functions #'cape-file)
      (add-to-list 'completion-at-point-functions #'cape-dabbrev))

    (use-package evil
      :init
      (setq evil-want-keybinding nil
            evil-want-C-u-scroll t
            evil-undo-system 'undo-redo)
      :config
      (evil-mode 1))

    (use-package evil-collection
      :after evil
      :config
      (evil-collection-init))

    (use-package general
      :after evil
      :config
      (general-auto-unbind-keys)
      (general-create-definer repo/leader
        :states '(normal visual motion)
        :keymaps 'override
        :prefix "SPC"
        :global-prefix "C-SPC")
      (repo/leader
        "b" '(:ignore t :which-key "buffer")
        "bb" '(consult-buffer :which-key "switch buffer")
        "bk" '(kill-current-buffer :which-key "kill buffer")
        "f" '(:ignore t :which-key "file")
        "ff" '(find-file :which-key "find file")
        "fr" '(consult-ripgrep :which-key "ripgrep")
        "g" '(:ignore t :which-key "git")
        "gs" '(magit-status :which-key "status")
        "h" '(:ignore t :which-key "help")
        "hf" '(helpful-callable :which-key "function")
        "hv" '(helpful-variable :which-key "variable")
        "hk" '(helpful-key :which-key "key")
        "p" '(:ignore t :which-key "project")
        "pf" '(project-find-file :which-key "find file")
        "pp" '(project-switch-project :which-key "switch project")
        "ps" '(project-shell :which-key "shell")
        "t" '(:ignore t :which-key "toggle")
        "tt" '(vterm :which-key "terminal")
        "q" '(:ignore t :which-key "quit")
        "qq" '(save-buffers-kill-terminal :which-key "quit emacs")))

    (use-package helpful
      :bind
      (([remap describe-function] . helpful-callable)
       ([remap describe-command] . helpful-command)
       ([remap describe-variable] . helpful-variable)
       ([remap describe-key] . helpful-key)))

    (use-package magit
      :commands (magit-status magit-dispatch))

    (use-package org-modern
      :hook (org-mode . org-modern-mode))

    (use-package vterm
      :commands vterm
      :custom
      (vterm-max-scrollback 10000)
      (vterm-shell shell-file-name))

    (require 'server)
    (unless (server-running-p)
      (server-start))
    EOF
  '';
  runtimePath = lib.makeBinPath [
    pkgs.fd
    pkgs.git
    pkgs.nushell
    pkgs.ripgrep
  ];
in
pkgs.symlinkJoin {
  name = "emacs";
  paths = [ emacsConfigured ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    mkdir -p "$out/share/emacs"
    cp ${initDir}/early-init.el "$out/share/emacs/early-init.el"
    cp ${initDir}/init.el "$out/share/emacs/init.el"

    wrapProgram "$out/bin/emacs" \
      --add-flags "--init-directory=$out/share/emacs" \
      --prefix PATH : "${runtimePath}" \
      --set SHELL "${shellPath}"

    if [ -x "$out/bin/emacsclient" ]; then
      wrapProgram "$out/bin/emacsclient" \
        --prefix PATH : "${runtimePath}" \
        --set ALTERNATE_EDITOR "$out/bin/emacs" \
        --set SHELL "${shellPath}"
    fi
  '';
}
