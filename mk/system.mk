# System setup

# --- wheel group (Linux only) ---
ifeq ($(IS_LINUX),Linux)
.PHONY: wheel-group
wheel-group:
	@if ! getent group wheel >/dev/null 2>&1; then \
		sudo groupadd wheel; \
		sudo usermod -aG wheel $$(whoami); \
	fi
	@echo '%wheel         ALL = (ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/wheel >/dev/null
	@sudo chmod 440 /etc/sudoers.d/wheel

.PHONY: system-setup
system-setup: wheel-group ## System setup (Linux)
else
.PHONY: system-setup
system-setup: ## System setup (no-op on macOS)
	@true
endif

# --- Set zsh as default shell ---
.PHONY: zsh-default
zsh-default:
	@case "$$(basename "$$SHELL")" in zsh) ;; *) sudo chsh -s $$(which zsh) $$(whoami) ;; esac

# --- Post-stow setup ---
.PHONY: post-stow
post-stow: | stow ## Run post-stow setup (nvim plugins, tmux plugins, zsh default)
	nvim --headless '+Lazy! restore' +qa 2>/dev/null || true
	$(HOME)/.tmux/plugins/tpm/scripts/install_plugins.sh 2>/dev/null || true
	$(MAKE) ptpython-config-link
	$(MAKE) gpg-pinentry
	$(MAKE) macos-shortcuts
	$(MAKE) zsh-default

# --- ptpython config location (macOS) ---
# appdirs puts ptpython's config in ~/Library/Application Support, not
# ~/.config. .zshrc sets PTPYTHON_CONFIG_HOME; this symlink covers shells
# that don't inherit it. no-op on linux.
PTPYTHON_APPDIR := $(HOME)/Library/Application Support/ptpython

.PHONY: ptpython-config-link
ptpython-config-link: ## Link ptpython config into the macOS appdirs location
ifeq ($(IS_MACOS),Darwin)
	@mkdir -p "$(PTPYTHON_APPDIR)"
	@ln -sfn "$(HOME)/.config/ptpython/config.py" "$(PTPYTHON_APPDIR)/config.py"
else
	@true
endif

# --- gpg pinentry (macOS) ---
# brew's gnupg falls back to the curses pinentry, which can't prompt when git
# signs from an editor or GUI. point gpg-agent at pinentry-mac instead. not
# stowed: ~/.gnupg holds keys/state and the path is mac-only. leaves an
# existing pinentry-program line alone. no-op on linux.
GPG_AGENT_CONF := $(HOME)/.gnupg/gpg-agent.conf

.PHONY: gpg-pinentry
gpg-pinentry: brew/gnupg brew/pinentry-mac ## Point gpg-agent at pinentry-mac (macOS)
ifeq ($(IS_MACOS),Darwin)
	@mkdir -p "$(HOME)/.gnupg" && chmod 700 "$(HOME)/.gnupg"
	@if ! grep -qs '^pinentry-program' "$(GPG_AGENT_CONF)"; then \
		echo "pinentry-program $(BREW_PREFIX)/bin/pinentry-mac" >> "$(GPG_AGENT_CONF)"; \
		gpgconf --kill gpg-agent 2>/dev/null || true; \
	fi
else
	@true
endif

# --- keyboard shortcuts (macOS) ---
.PHONY: macos-shortcuts
macos-shortcuts: ## Apply keyboard shortcuts via defaults (macOS)
	@$(CURDIR)/scripts/macos-shortcuts.sh

# --- Doctor (diagnostics) ---
.PHONY: doctor
doctor: ## Verify installation state
	@$(CURDIR)/scripts/doctor.sh
