# Platform detection and common variables
OS       := $(shell uname)
RAW_ARCH := $(shell uname -m)
ARCH     := $(if $(filter x86_64,$(RAW_ARCH)),amd64,$(if $(filter aarch64 arm64,$(RAW_ARCH)),arm64,$(RAW_ARCH)))

IS_LINUX := $(filter Linux,$(OS))
IS_MACOS := $(filter Darwin,$(OS))

HOME := $(shell echo $$HOME)

# Homebrew prefix (macOS only)
BREW_PREFIX := $(if $(IS_MACOS),$(if $(filter arm64,$(ARCH)),/opt/homebrew,/usr/local),)
BREW        := $(BREW_PREFIX)/bin/brew

# Extend PATH for tools installed by this Makefile
export PATH := $(HOME)/.local/bin:$(HOME)/.cargo/bin:$(HOME)/go/bin:/usr/local/go/bin:$(HOME)/.local/share/fnm:$(HOME)/.bun/bin:$(HOME)/.krew/bin:$(PATH)
