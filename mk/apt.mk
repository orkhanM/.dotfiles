# apt pattern rule, idempotent via dpkg -s
ifeq ($(IS_LINUX),Linux)

APT_STAMP := /tmp/.dotfiles-apt-update

$(APT_STAMP):
	sudo apt-get update
	@touch $@

.PHONY: apt-update
apt-update: $(APT_STAMP)

apt/%: | apt-update
	@dpkg -s $* >/dev/null 2>&1 || sudo apt-get install -y $*

else

apt/%:
	@true

endif
