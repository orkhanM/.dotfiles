# Stow orchestration

STOW_DIR      := $(shell git rev-parse --show-toplevel 2>/dev/null || pwd)
STOW_EXCLUDES := mk scripts tart
# ls, not $(wildcard): make 3.81 (macOS stock, used on the first run) doesn't
# filter dirs, so README.md leaks into the package list
STOW_PACKAGES := $(filter-out $(STOW_EXCLUDES),$(patsubst %/,%,$(shell cd "$(STOW_DIR)" && ls -d */ 2>/dev/null)))

# stow all packages, backing up conflicts.
#
# The message shapes differ by stow version and both are in play: brew ships
# 2.4.1, ubuntu 24.04 ships 2.3.1, and they word "a real file is in the way"
# differently. Missing the 2.3.1 wording meant `make all` always died here on
# linux, since `make tools` installs oh-my-zsh, which writes a ~/.zshrc.
#
#   2.3.1  existing target is neither a link nor a directory: X
#   2.4.1  cannot stow ... over existing target X since neither a link nor a
#          directory and --adopt not specified
#   2.4.1  cannot stow non-directory ... over existing directory target X
#   both   existing target is not owned by stow: X
#
# "stowed to a different package" is left unmatched on purpose, so a genuine
# cross-package conflict still fails loudly instead of being moved aside.
.PHONY: stow
stow: ## Stow all dotfiles packages
	@backup_dir="$(HOME)/.dotfiles.bak/$$(date +%s)"; \
	for pkg in $(STOW_PACKAGES); do \
		conflicts=$$(stow -n -v -t $(HOME) -d $(STOW_DIR) $$pkg 2>&1 | grep -E "^  \* (existing target is not owned by stow|existing target is neither a link nor a directory|cannot stow .* over existing target .* since neither a link nor a directory|cannot stow non-directory .* over existing directory target)" || true); \
		if [ -n "$$conflicts" ]; then \
			echo "  Backing up conflicts for $$pkg..."; \
			echo "$$conflicts" | \
			sed -E \
				-e 's/.*existing target is not owned by stow: (.*)/\1/' \
				-e 's/.*existing target is neither a link nor a directory: (.*)/\1/' \
				-e 's/.*over existing target (.*) since neither a link nor a directory.*/\1/' \
				-e 's/.*cannot stow non-directory .* over existing directory target (.*)/\1/' | \
			while IFS= read -r target; do \
				if [ -e "$(HOME)/$$target" ] && [ ! -L "$(HOME)/$$target" ]; then \
					mkdir -p "$$backup_dir/$$(dirname $$target)"; \
					mv "$(HOME)/$$target" "$$backup_dir/$$target"; \
					echo "    backed up $$target"; \
				fi; \
			done; \
		fi; \
		stow -v -t $(HOME) -d $(STOW_DIR) $$pkg; \
	done

stow/%: ## Stow a specific package (e.g., make stow/nvim)
	@stow -v -t $(HOME) -d $(STOW_DIR) $*

.PHONY: unstow
unstow: ## Unstow all dotfiles packages
	@for pkg in $(STOW_PACKAGES); do \
		stow -v -D -t $(HOME) -d $(STOW_DIR) $$pkg 2>/dev/null || true; \
	done

unstow/%: ## Unstow a specific package
	@stow -v -D -t $(HOME) -d $(STOW_DIR) $*

.PHONY: restow
restow: ## Restow all packages
	@for pkg in $(STOW_PACKAGES); do \
		stow -v -R -t $(HOME) -d $(STOW_DIR) $$pkg; \
	done

restow/%: ## Restow a specific package
	@stow -v -R -t $(HOME) -d $(STOW_DIR) $*
