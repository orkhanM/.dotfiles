FROM ubuntu:24.04

ARG USERNAME=orion

# Bootstrap
RUN apt-get update && apt-get install -y sudo make stow git curl

# Create user and setup sudo
RUN groupadd wheel && \
    echo "%wheel         ALL = (ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel && \
    useradd -m -d /home/${USERNAME} --groups sudo,wheel ${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}/dotfiles

# Layer 1: Foundation (Makefile + package manager rules)
ADD --chown=${USERNAME}:${USERNAME} Makefile Makefile
ADD --chown=${USERNAME}:${USERNAME} mk/versions.mk mk/versions.mk
ADD --chown=${USERNAME}:${USERNAME} mk/platform.mk mk/platform.mk
ADD --chown=${USERNAME}:${USERNAME} mk/apt.mk mk/apt.mk
ADD --chown=${USERNAME}:${USERNAME} mk/brew.mk mk/brew.mk

# Layer 2: System setup
ADD --chown=${USERNAME}:${USERNAME} mk/system.mk mk/system.mk
RUN make system-setup

# Layer 3: Packages (slow, changes rarely)
RUN make packages

# Layer 4: Build-from-source tools (slowest)
ADD --chown=${USERNAME}:${USERNAME} mk/build.mk mk/build.mk
RUN make tools

# Layer 5: CLI dev tools (incl. Kubernetes tooling)
ADD --chown=${USERNAME}:${USERNAME} mk/devtools.mk mk/devtools.mk
RUN make devtools

# Layer 6: Stow configs (change often, so added last)
ADD --chown=${USERNAME}:${USERNAME} mk/stow.mk mk/stow.mk
ADD --chown=${USERNAME}:${USERNAME} scripts/ scripts/
ADD --chown=${USERNAME}:${USERNAME} git/ git/
ADD --chown=${USERNAME}:${USERNAME} kitty/ kitty/
ADD --chown=${USERNAME}:${USERNAME} ncdu/ ncdu/
ADD --chown=${USERNAME}:${USERNAME} nvim/ nvim/
ADD --chown=${USERNAME}:${USERNAME} ssh/ ssh/
ADD --chown=${USERNAME}:${USERNAME} tmux/ tmux/
ADD --chown=${USERNAME}:${USERNAME} wezterm/ wezterm/
ADD --chown=${USERNAME}:${USERNAME} zsh/ zsh/
RUN make stow

# Layer 7: Post-stow
RUN make post-stow

CMD ["/bin/zsh"]
