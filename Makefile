.DEFAULT_GOAL := help

# --- Includes ---
# Foundation (always required)
include mk/versions.mk
include mk/platform.mk
include mk/apt.mk
include mk/brew.mk
# Optional (use -include so Docker can add these incrementally for layer caching)
-include mk/system.mk
-include mk/build.mk
-include mk/devtools.mk
-include mk/stow.mk
-include mk/tart.mk

# ============================================================================
# Package lists
# ============================================================================

# common packages (wrong-platform target is a no-op)
.PHONY: common-packages
common-packages: apt/curl      brew/curl
common-packages: apt/cmake     brew/cmake
common-packages: apt/fzf       brew/fzf
common-packages: apt/htop      brew/htop
common-packages: apt/nmap      brew/nmap
common-packages: apt/direnv    brew/direnv
common-packages: apt/python3   brew/python3
common-packages: apt/ripgrep   brew/ripgrep
common-packages: apt/tmux      brew/tmux
common-packages: apt/tree      brew/tree
common-packages: apt/wget      brew/wget
common-packages: apt/bzip2     brew/bzip2
common-packages: apt/gzip      brew/gzip
common-packages: apt/unzip     brew/unzip
common-packages: apt/zip       brew/zip
common-packages: apt/zsh       brew/zsh
common-packages: apt/luarocks  brew/luarocks
common-packages: apt/stow      brew/stow
common-packages: apt/ncdu      brew/ncdu

# linux-only packages (no-op on macOS)
.PHONY: linux-packages
linux-packages: apt/build-essential
linux-packages: apt/cmake-data
linux-packages: apt/dnsutils
linux-packages: apt/gettext
linux-packages: apt/libsqlite3-dev
linux-packages: apt/libncurses-dev
linux-packages: apt/libbzip3-dev
linux-packages: apt/libffi-dev
linux-packages: apt/tk-dev
linux-packages: apt/liblzma-dev
linux-packages: apt/libreadline-dev
linux-packages: apt/tshark
linux-packages: apt/iotop
linux-packages: apt/net-tools
linux-packages: apt/libpython3-dev
linux-packages: apt/pcscd
linux-packages: apt/python3-dev
linux-packages: apt/python3-pip
linux-packages: apt/acl
linux-packages: apt/xclip
linux-packages: apt/shfmt
linux-packages: apt/apt-transport-https
linux-packages: apt/fd-find

# macos-only packages (deduplicated, no-op on linux)
.PHONY: macos-packages
macos-packages: brew/cmake     brew/gettext    brew/sqlite     brew/ncurses
macos-packages: brew/xz        brew/readline
macos-packages: brew/gnu-sed   brew/gnu-tar    brew/grep       brew/findutils
macos-packages: brew/coreutils brew/go         brew/fnm        brew/fd
macos-packages: brew/tldr      brew/glow       brew/bat        brew/bash
macos-packages: brew/curl      brew/gawk       brew/gnu-which  brew/gzip
macos-packages: brew/jq        brew/make       brew/moreutils  brew/unzip
macos-packages: brew/watch     brew/ncdu
macos-packages: cask/font-ubuntu-mono-nerd-font
macos-packages: cask/yubico-authenticator

.PHONY: packages
packages: common-packages linux-packages macos-packages ## Install all packages

# ============================================================================
# Top-level targets
# ============================================================================

.PHONY: all
all: system-setup packages tools devtools stow post-stow hooks ## Full setup from scratch

.PHONY: help
help: ## Show available targets
	@grep -hE '^[a-zA-Z0-9_/%.-]+:.*## .*$$' $(MAKEFILE_LIST) | \
		sort -u | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
