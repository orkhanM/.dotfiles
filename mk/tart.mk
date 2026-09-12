# tart VM targets: macOS e2e test, same idea as the Dockerfile's apt one.
#
# tart/e2e.sh is the real interface and carries every flag (--keep, --reuse,
# --gui, --shell, --clean, --name, --image). These targets are shortcuts for
# the runs I actually do; reach for the script for anything else.
#
# macOS/arm64 only, since tart VMs need Apple Silicon.

TART   := $(BREW_PREFIX)/bin/tart
PACKER := $(BREW_PREFIX)/bin/packer

# the baked image, and the throwaway VM tart-dev clones from it. kept distinct
# from the e2e VM name (which lives in e2e.sh) so the two don't clobber.
TART_IMAGE  := dotfiles-dev
TART_DEV_VM := dotfiles-dev-vm

$(TART):
	$(BREW) install cirruslabs/cli/tart

# packer left homebrew-core when it moved to the BUSL licence
$(PACKER):
	$(BREW) install hashicorp/tap/packer

.PHONY: tart-e2e
tart-e2e: | $(TART) ## Run `make all` + `make doctor` in a clean macOS VM
	@./tart/e2e.sh

.PHONY: tart-image
tart-image: | $(TART) $(PACKER) ## Bake a local VM image with the dev env preinstalled (slow)
	@cd tart && packer init dotfiles.pkr.hcl && \
		packer build -var image_name=$(TART_IMAGE) dotfiles.pkr.hcl
	@# packer has no field for this. `tart clone` does carry it over, so
	@# setting it on the image is what lets tart-dev's clones resize with
	@# the window. (the base OCI image doesn't have it, which is why
	@# e2e.sh sets it on its own clones too.)
	@tart set $(TART_IMAGE) --display-refit

.PHONY: tart-dev
tart-dev: | $(TART) ## Boot a throwaway VM from the prebuilt image, drop into a shell
	@tart get $(TART_IMAGE) >/dev/null 2>&1 || { \
		echo "no '$(TART_IMAGE)' image yet -- run: make tart-image" >&2; exit 1; }
	@./tart/e2e.sh --image $(TART_IMAGE) --name $(TART_DEV_VM) --shell

# VMs only unless IMAGE=1: the image takes ~30 minutes and tens of GB to bake,
# so it shouldn't go away by accident.
.PHONY: tart-clean
tart-clean: ## Delete the e2e and dev VMs (IMAGE=1 also deletes the prebuilt image)
	@./tart/e2e.sh --clean
	@./tart/e2e.sh --clean --name $(TART_DEV_VM)
	@if [ -n "$(IMAGE)" ]; then \
		tart delete $(TART_IMAGE) 2>/dev/null && echo "deleted image $(TART_IMAGE)" || \
			echo "no image $(TART_IMAGE)"; \
	fi
