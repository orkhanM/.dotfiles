# Dotfiles

Cross-platform (macOS + Debian/Ubuntu) configuration managed with
[GNU Stow](https://www.gnu.org/software/stow/), with a Makefile that installs
the tools the configs expect.

Each top-level directory is a Stow package whose internal layout mirrors
`$HOME`, so `nvim/.config/nvim/init.lua` symlinks to `~/.config/nvim/init.lua`.

## Quick start

```bash
git clone https://github.com/orkhanM/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make all        # packages + from-source tools + symlinks + post-stow hooks
make doctor     # verify the result
```

`make all` is idempotent: every target checks for an existing install first,
and platform-specific rules are no-ops on the wrong OS. Run `make help` for
the full target list.

| Target | Effect |
| --- | --- |
| `make stow` | Create all symlinks (conflicts are backed up to `~/.dotfiles.bak/`) |
| `make stow/<pkg>` | Stow one package, e.g. `make stow/nvim` |
| `make unstow` / `make restow` | Remove / re-create symlinks. Use `restow` after deleting files from a package, so stale links go too |
| `make packages` | System packages via `apt` or `brew` |
| `make tools` | From-source builds: neovim, kitty, rust, go, fnm, node, bun, uv |
| `make devtools` | CLI tools from upstream releases: kubectl, kubectx, helm, stern, krew, argocd, termshark, lazygit, gh, yubico, gitleaks, pre-commit |
| `make k8s` | Just the Kubernetes subset of the above |
| `make hooks` | Install the pre-commit hook (run by `make all`) |
| `make doctor` | Check installed tools, and that every package is stowed from this repo. Exits non-zero on a problem |

## Local overrides

Nothing machine-specific, work-specific, or secret is committed here. Five
optional files, all gitignored, are picked up if present. Each has a
committed `.example` beside it showing the shape:

| File | Holds | Mechanism |
| --- | --- | --- |
| `~/.config/zsh/secrets.zsh` | Tokens, API keys, credentials | sourced by `.zshrc` |
| `~/.config/zsh/work.zsh` | Employer helpers, account ids, internal hosts | sourced by `.zshrc` |
| `~/.config/zsh/local.zsh` | Machine-specific `PATH` entries | sourced by `.zshrc` |
| `~/.gitconfig.local` | Git identity, signing key, URL rewrites | git `include.path` |
| `~/.ssh/config.local` | Private hosts, agent forwarding | ssh `Include` |

To adopt one, copy the example and edit it:

```bash
cp ~/.config/zsh/work.zsh.example ~/.config/zsh/work.zsh
cp ~/.gitconfig.local.example     ~/.gitconfig.local
```

The examples stow into `$HOME` alongside their real counterparts, so the copy
works in place. Every override is absent-safe: git silently skips a missing
`include.path`, ssh tolerates a missing `Include`, and `.zshrc` guards each
`source` with a `-f` test.

## Secret scanning

`make hooks` installs a pre-commit hook (gitleaks + pre-commit, both from
`make devtools`) that scans staged changes and refuses the commit on a hit:

| Pass | Catches |
| --- | --- |
| `.gitleaks.toml` | credentials, via gitleaks' built-in ruleset |
| `.gitleaks-identity.toml` | emails, hardcoded `/Users/<name>` paths, AWS account ids, non-public hostnames |
| `scripts/check-no-overrides.sh` | a `git add -f` of one of the override files above |

The identity rules match by *class*, never by literal value, so the configs
don't re-commit the strings they exist to keep out. The hostname rule is
deny-by-default against a list of hosts this repo actually fetches from, so
adding a tool means adding its download host.

Two configs rather than one because gitleaks' default allowlist silently
drops any finding containing `/home/`, which broke the home-path rule when
they shared a file. The identity config inherits nothing.

Scan by hand:

```bash
gitleaks git --no-banner --log-opts=main   # this branch's history
gitleaks dir --no-banner                   # working tree
```

Two gotchas for manual runs. `gitleaks git` walks *every* ref without
`--log-opts`, so it will surface anything in old branches you still have
locally. And `gitleaks dir` reads gitignored files, so it reports the real
tokens in `secrets.zsh`. Both are working as intended; the hook only ever
looks at what's staged. Pass `--config .gitleaks-identity.toml` to either
command to run the identity rules instead of the credential ones.

## Layout

```
.dotfiles/
├── mk/          # Makefile modules (not a Stow package)
│   ├── platform.mk   # OS/arch detection
│   ├── versions.mk   # The one version that still needs pinning
│   ├── apt.mk        # Debian/Ubuntu packages
│   ├── brew.mk       # Homebrew packages
│   ├── build.mk      # From-source builds
│   ├── devtools.mk   # CLI tools from upstream releases (k8s = subset target)
│   ├── stow.mk       # Stow orchestration + conflict backup
│   ├── system.mk     # System setup, post-stow hooks, doctor
│   └── tart.mk       # macOS VM test targets
├── tart/        # macOS VM e2e test + Packer image (not a Stow package)
├── scripts/     # helper scripts (not a Stow package)
└── <pkg>/       # One Stow package per tool, mirroring $HOME
```

Adding a package: create `toolname/.config/toolname/`, mirror the `$HOME`
layout inside it, add a Make target that installs the tool, then
`make stow/toolname`.

## Testing

```bash
docker build -t dotfiles . && docker run -it dotfiles   # linux/apt path
make tart-e2e                                           # macOS path, clean VM
make tart-clean                                         # delete e2e + dev VMs
```

`tart/e2e.sh` is the full interface (`--keep`, `--gui`, `--reuse`, `--shell`,
`--clean`, `--name`, `--image`) and the make targets are shortcuts for the
common runs. macOS/arm64 only; `make tart-e2e` installs the tart CLI if
it's missing.

Baking a local image with Packer (`tart/dotfiles.pkr.hcl`) skips the ~30
minutes of provisioning:

```bash
make tart-image           # bake
make tart-dev             # throwaway VM from it, into a shell
make tart-clean IMAGE=1   # delete the VMs *and* the image
```

`tart-dev` uses its own VM (`dotfiles-dev-vm`), so it never clobbers an e2e
VM you kept. The image only goes away with an explicit `IMAGE=1`.
