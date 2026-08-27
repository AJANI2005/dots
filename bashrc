# Start Mango Compositor
if [ "$(tty)" = "/dev/tty1" ]  &&  [ -z "$WAYLAND_DISPLAY" ]; then
	exec mango
fi

# Helper aliases
alias dnf-list="dnf repoquery --userinstalled | less"
alias ll='ls -la'
alias l='ls -la'

alias nvim="db nvim $@"
alias lg="db lazygit $@"

# PS1
export PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\n\$ '

# Container Runners
d() {
podman run --rm -it \
    --security-opt label=disable \
    --secret github-token,type=env,target=GITHUB_TOKEN \
    --hostname=devbox \
    -e WAYLAND_DISPLAY \
    -e XDG_RUNTIME_DIR \
    -v "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" \
    -v devbox-nvim:/root/.local/share/nvim \
    -v devbox-nvim:/root/.local/state/nvim \
    -v "$PWD:/workspace" \
    -w /workspace \
    devbox:latest "$@"
}
