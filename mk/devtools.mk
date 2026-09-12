# cli tools installed from upstream releases or the package manager.
# build.mk is for anything compiled from source. k8s tooling is a group in
# here, and the `k8s` target installs just that subset.

# --- kubectl ---
ifeq ($(IS_LINUX),Linux)
KUBECTL := /usr/local/bin/kubectl

.PHONY: kubectl
kubectl: $(KUBECTL) ## Install kubectl

$(KUBECTL):
	@KUBECTL_VERSION=$$(curl -sL https://dl.k8s.io/release/stable.txt) && \
	curl -fSL "https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/$(ARCH)/kubectl" -o /tmp/kubectl && \
	sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl && \
	rm /tmp/kubectl
else
.PHONY: kubectl
kubectl: brew/kubectl
endif

# --- kubectx ---
ifeq ($(IS_LINUX),Linux)
.PHONY: kubectx
kubectx: apt/kubectx kubectx-completion-fix ## Install kubectx

.PHONY: kubectx-completion-fix
kubectx-completion-fix:
	@if [ ! -L /usr/share/zsh/vendor-completions/_kubectx.zsh ] 2>/dev/null; then \
		sudo rm -f /usr/share/zsh/vendor-completions/_kubectx.zsh; \
		sudo ln -s /usr/share/kubectx/completion/_kubectx.zsh /usr/share/zsh/vendor-completions/_kubectx.zsh; \
	fi
	@if [ ! -L /usr/share/zsh/vendor-completions/_kubens.zsh ] 2>/dev/null; then \
		sudo rm -f /usr/share/zsh/vendor-completions/_kubens.zsh; \
		sudo ln -s /usr/share/kubectx/completion/_kubens.zsh /usr/share/zsh/vendor-completions/_kubens.zsh; \
	fi
else
.PHONY: kubectx
kubectx: brew/kubectx
endif

# --- helm ---
ifeq ($(IS_LINUX),Linux)
HELM := /usr/local/bin/helm

.PHONY: helm
helm: $(HELM) ## Install Helm

# helm publishes its own latest-version file, so no GitHub API call needed
$(HELM):
	@ver=$$(curl -fsSL https://get.helm.sh/helm-latest-version) && \
	echo "installing helm $$ver" && \
	curl -fSL "https://get.helm.sh/helm-$$ver-linux-$(ARCH).tar.gz" -o /tmp/helm.tar.gz && \
	tar xf /tmp/helm.tar.gz -C /tmp && \
	sudo install -o root -g root -m 0755 /tmp/linux-$(ARCH)/helm /usr/local/bin/helm && \
	rm -rf /tmp/helm.tar.gz /tmp/linux-$(ARCH)
else
.PHONY: helm
helm: brew/helm
endif

# --- stern ---
ifeq ($(IS_LINUX),Linux)
STERN := $(HOME)/go/bin/stern

.PHONY: stern
stern: $(STERN) ## Install stern

$(STERN): | go
	/usr/local/go/bin/go install github.com/stern/stern@latest
else
.PHONY: stern
stern: brew/stern
endif

# --- termshark ---
ifeq ($(IS_LINUX),Linux)
TERMSHARK := $(HOME)/go/bin/termshark

.PHONY: termshark
termshark: $(TERMSHARK) ## Install termshark

$(TERMSHARK): | go
	/usr/local/go/bin/go install github.com/gcla/termshark/v2/cmd/termshark@latest
else
.PHONY: termshark
termshark: brew/termshark
endif

# --- lazygit ---
ifeq ($(IS_LINUX),Linux)
LAZYGIT := /usr/local/bin/lazygit
# lazygit names its amd64 asset x86_64. getting this wrong doesn't fail the
# build -- the x86_64 tarball downloads fine on arm64 and installs a binary
# that can't exec.
LAZYGIT_ARCH := $(if $(filter amd64,$(ARCH)),x86_64,$(ARCH))

.PHONY: lazygit
lazygit: $(LAZYGIT) ## Install lazygit

$(LAZYGIT):
	@LAZYGIT_VERSION=$$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*') && \
	curl -fSL "https://github.com/jesseduffield/lazygit/releases/download/v$${LAZYGIT_VERSION}/lazygit_$${LAZYGIT_VERSION}_Linux_$(LAZYGIT_ARCH).tar.gz" -o /tmp/lazygit.tar.gz && \
	tar xf /tmp/lazygit.tar.gz -C /tmp lazygit && \
	sudo install /tmp/lazygit -D -t /usr/local/bin/ && \
	rm /tmp/lazygit.tar.gz /tmp/lazygit
else
.PHONY: lazygit
lazygit: brew/lazygit
endif

# --- krew ---
ifeq ($(IS_LINUX),Linux)
KREW := $(HOME)/.krew/bin/kubectl-krew

.PHONY: krew
krew: $(KREW) ## Install krew (kubectl plugin manager)

$(KREW): | kubectl
	@cd /tmp && \
	curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_$(ARCH).tar.gz" && \
	tar zxf krew-linux_$(ARCH).tar.gz && \
	./krew-linux_$(ARCH) install krew && \
	rm -f krew-linux_$(ARCH)*
else
.PHONY: krew
krew: brew/krew
endif

# --- argocd ---
ifeq ($(IS_LINUX),Linux)
ARGOCD := /usr/local/bin/argocd

.PHONY: argocd
argocd: $(ARGOCD) ## Install ArgoCD CLI

$(ARGOCD):
	curl -sSL -o /tmp/argocd "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-$(ARCH)"
	sudo install -m 555 /tmp/argocd /usr/local/bin/argocd
	rm /tmp/argocd
else
.PHONY: argocd
argocd: brew/argocd
endif

# --- gh (GitHub CLI) ---
ifeq ($(IS_LINUX),Linux)
GH := /usr/bin/gh

.PHONY: gh
gh: $(GH) ## Install GitHub CLI

$(GH):
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
	sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
	echo "deb [arch=$(ARCH) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y gh
else
.PHONY: gh
gh: brew/gh
endif

# --- yubico ---
ifeq ($(IS_LINUX),Linux)
YUBICO_TARBALL := $(HOME)/Applications/yubico-authenticator-latest-linux.tar.gz

.PHONY: yubico
yubico: $(YUBICO_TARBALL) ## Install Yubico Authenticator

$(YUBICO_TARBALL):
	mkdir -p $(HOME)/Applications
	curl -fSL https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-latest-linux.tar.gz -o $@
	@cd $(HOME)/Applications && \
	tarball_dir=$$(tar -tf yubico-authenticator-latest-linux.tar.gz | head -n 1 | cut -f1 -d'/') && \
	tar xvf yubico-authenticator-latest-linux.tar.gz && \
	cd $$tarball_dir && \
	./desktop_integration.sh --install
else
.PHONY: yubico
yubico: cask/yubico-authenticator
endif

# --- gitleaks ---
# secret scanner, run by the pre-commit hook. see .gitleaks.toml
ifeq ($(IS_LINUX),Linux)
GITLEAKS      := /usr/local/bin/gitleaks
# gitleaks names its assets x64/arm64, not amd64
GITLEAKS_ARCH := $(if $(filter amd64,$(ARCH)),x64,$(ARCH))

.PHONY: gitleaks
gitleaks: $(GITLEAKS) ## Install gitleaks secret scanner

# asset names embed the version, so the tag has to be resolved first
$(GITLEAKS):
	@ver=$$(curl -fsSL "https://api.github.com/repos/gitleaks/gitleaks/releases/latest" \
		| grep -Po '"tag_name": *"v\K[^"]*') && \
	echo "installing gitleaks $$ver" && \
	curl -fSL "https://github.com/gitleaks/gitleaks/releases/download/v$$ver/gitleaks_$${ver}_linux_$(GITLEAKS_ARCH).tar.gz" -o /tmp/gitleaks.tar.gz && \
	tar xf /tmp/gitleaks.tar.gz -C /tmp gitleaks && \
	sudo install -m 755 /tmp/gitleaks /usr/local/bin/gitleaks && \
	rm /tmp/gitleaks.tar.gz /tmp/gitleaks
else
.PHONY: gitleaks
gitleaks: brew/gitleaks
endif

# --- pre-commit ---
# installed via uv, but an existing copy on PATH counts
.PHONY: pre-commit
pre-commit: | uv ## Install pre-commit
	@command -v pre-commit >/dev/null 2>&1 || $(UV) tool install pre-commit

# wire the hook into .git/hooks. one shell block so the skip actually skips,
# and $(CURDIR) so this doesn't depend on stow.mk being included.
.PHONY: hooks
hooks: | pre-commit ## Install this repo's git hooks
	@if git -C "$(CURDIR)" rev-parse --git-dir >/dev/null 2>&1; then \
		cd "$(CURDIR)" && pre-commit install; \
	else \
		echo "not a git checkout, skipping hook install"; \
	fi

# --- Aggregates ---
# just the k8s bits, for a box that only needs cluster access
.PHONY: k8s
k8s: kubectl kubectx helm stern krew argocd ## Install Kubernetes tooling

# everything here. this is what `make all` runs.
.PHONY: devtools
devtools: k8s termshark lazygit gh yubico gitleaks pre-commit ## Install all CLI dev tools
