# Start Mango Compositor
if [ "$(tty)" = "/dev/tty1" ]  &&  [ -z "$WAYLAND_DISPLAY" ]; then
	exec mango
fi

# Helper aliases
alias dnf-list="dnf repoquery --userinstalled | less"
alias ll='ls -la'
alias l='ls -la'

# PS1
export PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\n\$ '

# Container Runners
dev() {
podman run --rm -it \
    --userns=keep-id \
    --security-opt label=disable \
    --secret github-token,type=env,target=GITHUB_TOKEN \
    -v "$PWD:/workspace" \
    -w /workspace \
    dev:v1
}
