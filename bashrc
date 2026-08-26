# Start Mango Compositor
if [ "$(tty)" = "/dev/tty1" ]  &&  [ -z "$WAYLAND_DISPLAY" ]; then
	exec mango
fi

# Helper aliases

# Containers
alias dnf-list="dnf repoquery --userinstalled | less"

dev() {
podman run --rm -it \
    --userns=keep-id \
    --security-opt label=disable \
    -v "$PWD:/workspace" \
    -w /workspace \
    dev:v1
}
