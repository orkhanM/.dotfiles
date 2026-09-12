// Bakes a VM image with the whole dev env installed, so you can boot it
// instantly instead of provisioning from scratch like tart/e2e.sh does.
//
//   make tart-image   # build the image (slow: runs the whole `make all`)
//   make tart-dev     # boot a throwaway VM from it and drop into a shell
//
// Stays local, nothing gets pushed to a registry. Clones are APFS
// copy-on-write so each throwaway VM is near-free.

packer {
  required_plugins {
    tart = {
      version = ">= 1.11.1"
      source  = "github.com/cirruslabs/tart"
    }
  }
}

variable "base_image" {
  type        = string
  default     = "ghcr.io/cirruslabs/macos-tahoe-base:latest"
  description = "Source image: macOS + Xcode CLT + SSH, but no Homebrew."
}

variable "image_name" {
  type        = string
  default     = "dotfiles-dev"
  description = "Name of the local VM image to produce. make tart-image passes this."
}

variable "display" {
  type    = string
  default = "1440x900"
  // points, not pixels. see the DISPLAY_SIZE note in tart/e2e.sh.
  description = "Guest resolution in points; the base image's 1024x768 is unusable."
}

source "tart-cli" "dotfiles" {
  vm_base_name = var.base_image
  vm_name      = var.image_name
  cpu_count    = 4
  memory_gb    = 8
  disk_size_gb = 60
  display      = var.display
  headless     = true
  ssh_username = "admin"
  ssh_password = "admin"
  ssh_timeout  = "120s"
}

build {
  sources = ["source.tart-cli.dotfiles"]

  provisioner "shell" {
    inline = ["mkdir -p /Users/admin/dotfiles"]
  }

  // Upload the repo rather than sharing it via --dir: a virtiofs share lives
  // under "/Volumes/My Shared Files/...", and the space in that path breaks
  // Make's $(wildcard) when mk/stow.mk computes STOW_PACKAGES.
  provisioner "file" {
    source      = "${path.root}/../"
    destination = "/Users/admin/dotfiles"
  }

  // Run under a login shell so brew's PATH is picked up, and non-interactively
  // so Homebrew doesn't stop to ask for install confirmation.
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} /bin/zsh -l {{ .Path }}"
    inline = [
      "cd ~/dotfiles && NONINTERACTIVE=1 CI=1 make all",
      "cd ~/dotfiles && make doctor",
    ]
  }
}
