# brew and cask pattern rules, idempotent and cached for speed
ifeq ($(IS_MACOS),Darwin)

$(BREW):
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Snapshot installed formulae/casks once at Make parse time
BREW_INSTALLED := $(shell $(BREW) list --formula -1 2>/dev/null)
CASK_INSTALLED := $(shell $(BREW) list --cask -1 2>/dev/null)

brew/%: | $(BREW)
	@if echo ' $(BREW_INSTALLED) ' | grep -qw '$*'; then :; else $(BREW) install $*; fi

cask/%: | $(BREW)
	@if echo ' $(CASK_INSTALLED) ' | grep -qw '$*'; then :; else $(BREW) install --cask $*; fi

else

brew/%:
	@true

cask/%:
	@true

endif
