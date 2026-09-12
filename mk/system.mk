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

# --- Doctor (diagnostics) ---
.PHONY: doctor
doctor: ## Verify installation state
	@$(CURDIR)/scripts/doctor.sh
