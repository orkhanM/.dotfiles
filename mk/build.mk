# Build-from-source tools

NVIM         := /usr/local/bin/nvim
RUSTC        := $(HOME)/.cargo/bin/rustc
TPM_DIR      := $(HOME)/.tmux/plugins/tpm
OMZ_DIR      := $(HOME)/.oh-my-zsh
OMZ_COMPLETE := $(HOME)/.oh-my-zsh/completions
ZSH_AS       := $(HOME)/.oh-my-zsh/custom/plugins/zsh-autosuggestions
ZSH_SH       := $(HOME)/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
BUN          := $(HOME)/.bun/bin/bun

# --- Neovim (build from source) ---
.PHONY: neovim
neovim: $(NVIM) ## Build and install Neovim

$(NVIM): $(if $(IS_LINUX),| linux-packages)
	sudo rm -rf /tmp/neovim
	git clone --depth 1 --branch stable https://github.com/neovim/neovim /tmp/neovim
	cd /tmp/neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
	cd /tmp/neovim && sudo make install
	sudo rm -rf /tmp/neovim

# --- Kitty terminal ---
# kitty's installer drops an app bundle in /Applications on macOS but a plain
# tree under ~/.local/kitty.app on Linux, so the binaries to link differ.
ifeq ($(IS_MACOS),Darwin)
KITTY  := /Applications/kitty.app/Contents/MacOS/kitty
KITTEN := /Applications/kitty.app/Contents/MacOS/kitten
else
KITTY  := $(HOME)/.local/kitty.app/bin/kitty
KITTEN := $(HOME)/.local/kitty.app/bin/kitten
endif

.PHONY: kitty-terminal
kitty-terminal: ## Install kitty terminal
	@test -x $(KITTY) || \
		curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
	@mkdir -p $(HOME)/.local/bin
	@ln -sf $(KITTY) $(HOME)/.local/bin/kitty
	@ln -sf $(KITTEN) $(HOME)/.local/bin/kitten

# --- Rust ---
.PHONY: rust
rust: $(RUSTC) ## Install Rust via rustup

$(RUSTC):
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# --- TPM ---
.PHONY: tpm
tpm: $(TPM_DIR) ## Install tmux plugin manager

$(TPM_DIR):
	git clone https://github.com/tmux-plugins/tpm $@

# --- Oh-My-Zsh ---
.PHONY: oh-my-zsh
oh-my-zsh: $(OMZ_DIR) ## Install oh-my-zsh

$(OMZ_DIR):
	sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# --- Zsh completions directory ---
.PHONY: zsh-completions-dir
zsh-completions-dir: $(OMZ_COMPLETE)

$(OMZ_COMPLETE): | $(OMZ_DIR)
	mkdir -p $@

# --- Zsh plugins ---
.PHONY: zsh-plugins
zsh-plugins: $(ZSH_AS) $(ZSH_SH) ## Install zsh plugins

$(ZSH_AS): | $(OMZ_DIR)
	git clone https://github.com/zsh-users/zsh-autosuggestions $@

$(ZSH_SH): | $(OMZ_DIR)
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $@

# --- Go ---
ifeq ($(IS_LINUX),Linux)
GO := /usr/local/go/bin/go

.PHONY: go
go: $(GO) ## Install Go

# apt's golang is years behind, so fetch upstream. brew tracks latest on macOS,
# so track latest here too rather than pinning one platform and not the other.
# ?m=text returns e.g. "go1.27.1" on the first line.
$(GO):
	@ver=$$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1) && \
	tarball="$$ver.linux-$(ARCH).tar.gz" && \
	echo "installing $$ver" && \
	curl -fSL "https://go.dev/dl/$$tarball" -o "/tmp/$$tarball" && \
	sudo rm -rf /usr/local/go && \
	sudo tar -C /usr/local -xzf "/tmp/$$tarball" && \
	rm "/tmp/$$tarball"
else
.PHONY: go
go: brew/go
endif

# --- fnm (Fast Node Manager) ---
ifeq ($(IS_LINUX),Linux)
FNM := $(HOME)/.local/share/fnm/fnm

.PHONY: fnm
fnm: $(FNM) ## Install fnm

$(FNM):
	curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
else
.PHONY: fnm
fnm: brew/fnm
endif

# --- Node.js LTS ---
.PHONY: node
node: | fnm ## Install Node.js LTS via fnm
	@fnm list 2>/dev/null | grep -q lts-latest || (fnm install --lts && fnm default lts-latest)

# --- Nerd Font ---
ifeq ($(IS_LINUX),Linux)
NERD_FONT := $(HOME)/.local/share/fonts/UbuntuMonoNerdFont-Regular.ttf

.PHONY: nerd-font
nerd-font: $(NERD_FONT) ## Install Ubuntu Mono Nerd Font

$(NERD_FONT):
	mkdir -p $(HOME)/.local/share/fonts
	curl -fSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.tar.xz -o /tmp/UbuntuMono.tar.xz
	tar xf /tmp/UbuntuMono.tar.xz -C $(HOME)/.local/share/fonts/
	rm /tmp/UbuntuMono.tar.xz
else
.PHONY: nerd-font
nerd-font: cask/font-ubuntu-mono-nerd-font
endif

# --- WezTerm ---
ifeq ($(IS_LINUX),Linux)
WEZTERM := /usr/bin/wezterm
# no ubuntu 24.04 build upstream, and only the arm64 asset has an arch in
# its filename (the amd64 one is bare)
WEZTERM_DEB := wezterm-$(WEZTERM_VERSION).Ubuntu22.04$(if $(filter arm64,$(ARCH)),.arm64,).deb

.PHONY: wezterm
wezterm: $(WEZTERM) ## Install WezTerm

$(WEZTERM):
	curl -fSL https://github.com/wez/wezterm/releases/download/$(WEZTERM_VERSION)/$(WEZTERM_DEB) -o /tmp/$(WEZTERM_DEB)
	sudo apt-get install -y /tmp/$(WEZTERM_DEB)
	rm /tmp/$(WEZTERM_DEB)
else
.PHONY: wezterm
wezterm: cask/wezterm ## Install WezTerm
endif

# --- uv (Python package/tool manager) ---
UV := $(HOME)/.local/bin/uv

.PHONY: uv
uv: $(UV) ## Install uv

$(UV):
	curl -fsSL https://astral.sh/uv/install.sh | sh

# --- python (unversioned, for scripts) ---
# pyenv used to put `python` on PATH, brew and apt only ship python3.
# --default links python and python3 into ~/.local/bin, ahead of both.
.PHONY: python
python: | uv ## Install Python via uv as the default python/python3
	@$(HOME)/.local/bin/python --version 2>/dev/null | grep -q ' $(PYTHON_VERSION)\.' || \
		$(UV) python install $(PYTHON_VERSION) --default --preview-features python-install-default

# --- ptpython (Python REPL) ---
# --with catppuccin[pygments] registers the catppuccin-* Pygments styles inside
# ptpython's own venv; the config selects catppuccin-mocha.
.PHONY: ptpython
ptpython: | uv ## Install ptpython REPL as a uv tool
	@$(UV) tool list 2>/dev/null | grep -q '^ptpython' || \
		$(UV) tool install ptpython --with "catppuccin[pygments]"

# --- bun ---
.PHONY: bun
bun: $(BUN) ## Install bun runtime

$(BUN):
	curl -fsSL https://bun.sh/install | bash

# --- Aggregate ---
.PHONY: tools
tools: neovim kitty-terminal wezterm rust tpm oh-my-zsh zsh-plugins zsh-completions-dir go fnm node nerd-font uv python ptpython bun ## Install all build-from-source tools
