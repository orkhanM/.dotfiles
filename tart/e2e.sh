#!/usr/bin/env bash
#
# Runs this repo's Makefile in a clean macOS VM via tart (https://tart.run),
# same idea as the Dockerfile's apt path. Needs the tart CLI and an arm64
# host.
#
# Base image is a Cirrus "-base": macOS + CLT + SSH (admin/admin), no
# homebrew, so `make all` has to bootstrap brew itself (mk/brew.mk).
#
# `tart exec` was unreliable against this image even with the agent up, so
# provisioning goes over SSH, with `expect` driving the password prompt.
#
# Usage:
#   ./tart/e2e.sh            # run `make all && make doctor`, then tear down
#   ./tart/e2e.sh --keep     # leave the VM running afterwards for inspection
#   ./tart/e2e.sh --reuse    # reuse an existing VM instead of recloning
#   ./tart/e2e.sh --gui      # same, but with Tart's VM window open to watch
#   ./tart/e2e.sh --shell    # boot a fresh VM and drop into a shell instead
#   ./tart/e2e.sh --clean    # delete the VM and exit

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VM_NAME="${TART_VM_NAME:-dotfiles-e2e}"
IMAGE="${TART_IMAGE:-ghcr.io/cirruslabs/macos-tahoe-base:latest}"
CPU="${TART_CPU:-4}"
MEMORY="${TART_MEMORY:-8192}"
# In points, not pixels, for macOS guests. Keep this under the *logical*
# resolution of the smallest screen you use, or the window won't fit on it:
# a 16" MacBook Pro panel is 3456x2234 physical but only 1728x1117 points.
DISPLAY_SIZE="${TART_DISPLAY:-1440x900}"
export SSH_USER="admin"
export SSH_PASS="admin"
# Fixed by the --dir="dotfiles:...":ro mount below (macOS auto-mounts
# directory shares under this path, named after the share).
REPO_MOUNT="/Volumes/My Shared Files/dotfiles"
# copy the repo off the share before running make: the space in the mount
# path breaks make's $(wildcard) outright, and make 3.81 leaks plain files
# through a dir-only glob
GUEST_REPO="/Users/${SSH_USER}/dotfiles"
KEEP=0
REUSE=0
GUI=0
MODE=test

usage() {
	cat <<EOF
Usage: $(basename "$0") [--keep] [--reuse] [--gui] [--shell|--clean] [--name NAME] [--image IMAGE]

  --keep     Leave the VM running after the test instead of deleting it
  --reuse    Reuse an existing VM with this name instead of recloning it
  --gui      Open Tart's VM window instead of running headless, so you can
             watch the VM while the test drives it over SSH
  --shell    Boot the VM and drop into an interactive shell instead of
             running the e2e test (dotfiles staged at ~/dotfiles)
  --clean    Delete the VM and exit without booting anything
  --name     VM name (default: dotfiles-e2e, or \$TART_VM_NAME)
  --image    Base OCI image to clone from (default: $IMAGE)
EOF
}

while [ $# -gt 0 ]; do
	case "$1" in
	--keep) KEEP=1 ;;
	--reuse) REUSE=1 ;;
	--gui) GUI=1 ;;
	--shell) MODE=shell ;;
	--clean) MODE=clean ;;
	--name)
		VM_NAME="$2"
		shift
		;;
	--image)
		IMAGE="$2"
		shift
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "Unknown argument: $1" >&2
		usage
		exit 1
		;;
	esac
	shift
done

if ! command -v tart >/dev/null 2>&1; then
	echo "error: tart not found (brew install cirruslabs/cli/tart, or make tart-e2e)" >&2
	exit 1
fi

# Delete and exit. Deliberately before the `expect` check and the EXIT trap:
# cleaning up needs neither, and should work even if expect is missing.
if [ "$MODE" = clean ]; then
	if tart get "$VM_NAME" >/dev/null 2>&1; then
		tart delete "$VM_NAME" && echo "deleted $VM_NAME"
	else
		echo "no VM $VM_NAME"
	fi
	exit 0
fi

if ! command -v expect >/dev/null 2>&1; then
	echo "error: this script needs 'expect' to drive the VM's SSH password prompt (ships with macOS)" >&2
	exit 1
fi

RUN_PID=""
EXPECT_SCRIPT="$(mktemp "${TMPDIR:-/tmp}/tart-e2e-ssh.XXXXXX")"
LOG_FILE="$(mktemp "${TMPDIR:-/tmp}/tart-e2e-output.XXXXXX")"

cleanup() {
	rm -f "$EXPECT_SCRIPT" "$LOG_FILE"
	if [ -n "$RUN_PID" ] && kill -0 "$RUN_PID" 2>/dev/null; then
		tart stop "$VM_NAME" >/dev/null 2>&1 || kill "$RUN_PID" 2>/dev/null || true
		wait "$RUN_PID" 2>/dev/null || true
	fi
	if [ "$KEEP" -eq 0 ]; then
		tart delete "$VM_NAME" >/dev/null 2>&1 || true
	fi
}
trap cleanup EXIT

# SSH in as $SSH_USER (password from $SSH_PASS), answering the one password
# prompt automatically. argv: <ip> [remote-command]. With no remote command,
# hands control to an interactive shell (used by --shell); otherwise streams
# the remote command's output and exits with its exit code.
cat >"$EXPECT_SCRIPT" <<'EXPECT_EOF'
#!/usr/bin/expect -f
set timeout -1
set ip [lindex $argv 0]
set remote_cmd [lindex $argv 1]
if {$remote_cmd eq ""} {
	spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR $env(SSH_USER)@$ip
} else {
	spawn ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR $env(SSH_USER)@$ip $remote_cmd
}
expect -nocase "password:"
send "$env(SSH_PASS)\r"
if {$remote_cmd eq ""} {
	interact
} else {
	expect eof
	catch wait result
	exit [lindex $result 3]
}
EXPECT_EOF
chmod +x "$EXPECT_SCRIPT"

if [ "$REUSE" -eq 0 ] || ! tart get "$VM_NAME" >/dev/null 2>&1; then
	tart delete "$VM_NAME" >/dev/null 2>&1 || true
	echo "==> Cloning $IMAGE -> $VM_NAME"
	tart clone "$IMAGE" "$VM_NAME"
	# The base OCI image ships 1024x768 with no display-refit, so set both
	# on the clone: without refit the guest holds a fixed resolution and a
	# smaller window just clips the bottom. (`tart clone` does preserve
	# refit, so a clone of the baked dotfiles-dev image already has it --
	# this matters for the base image.)
	tart set "$VM_NAME" --cpu "$CPU" --memory "$MEMORY" --display "$DISPLAY_SIZE" --display-refit
fi

if [ "$GUI" -eq 1 ]; then
	echo "==> Booting $VM_NAME (window open, dotfiles mounted read-only)"
	# --capture-system-keys sends Cmd+Space, Cmd+Tab and friends to the guest
	# while its window has focus, so the host doesn't eat them first.
	tart run "$VM_NAME" --capture-system-keys --dir="dotfiles:${REPO_ROOT}:ro" &
else
	echo "==> Booting $VM_NAME (headless, dotfiles mounted read-only)"
	tart run "$VM_NAME" --no-graphics --dir="dotfiles:${REPO_ROOT}:ro" &
fi
RUN_PID=$!

echo "==> Waiting for network"
IP="$(tart ip "$VM_NAME" --wait 120)"

echo "==> Waiting for SSH"
for _ in $(seq 1 60); do
	nc -z -w2 "$IP" 22 2>/dev/null && break
	sleep 2
done

echo "==> Staging dotfiles at $GUEST_REPO"
STAGE_CMD="rm -rf \"$GUEST_REPO\" && cp -R \"$REPO_MOUNT\" \"$GUEST_REPO\""
"$EXPECT_SCRIPT" "$IP" "$STAGE_CMD" >/dev/null

if [ "$MODE" = shell ]; then
	echo "==> Dropping into shell (dotfiles staged at '$GUEST_REPO')"
	"$EXPECT_SCRIPT" "$IP" ""
	exit 0
fi

echo "==> Running make all && make doctor"
set +e
# No remote pty is requested here (unlike --shell mode), and NONINTERACTIVE/
# CI are set too: Homebrew shows a "Do you want to proceed with the
# installation?" confirmation whenever its output looks interactive, which
# would otherwise hang this script waiting for input that never comes.
REMOTE_CMD="/bin/zsh -lc \"cd \\\"$GUEST_REPO\\\" && NONINTERACTIVE=1 CI=1 make all && make doctor\"; echo E2E_EXIT_CODE:\$?"
"$EXPECT_SCRIPT" "$IP" "$REMOTE_CMD" | tee "$LOG_FILE"
status="$(grep -o 'E2E_EXIT_CODE:[0-9]*' "$LOG_FILE" | tail -1 | cut -d: -f2)"
set -e
status="${status:-1}"

if [ "$status" -eq 0 ]; then
	echo "==> e2e PASSED"
else
	echo "==> e2e FAILED (exit $status)"
fi
exit "$status"
