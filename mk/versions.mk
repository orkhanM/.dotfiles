# Most tools resolve their own latest version at install time, the way brew
# does on macOS, so there's nothing to pin here. What's left needs a literal:
#
# wezterm's newest *stable* is still 20240203 (they ship nightlies in between),
# and the asset name embeds both the version and the distro, so tracking
# "latest" would gain nothing today and break on the next naming change.
WEZTERM_VERSION := 20240203-110809-5046fc22
