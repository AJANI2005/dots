# Start Mango Compositor
if [ "$(tty)" = "/dev/tty1" ]  &&  [ -z "$WAYLAND_DISPLAY" ]; then
	exec mango
fi

# Helper aliases
alias dnf-list="dnf repoquery --userinstalled | less"
alias ll='ls -la'
alias l='ls -la'

alias v="nvim"


devbox=~/containers/podman-devbox

alias d="$devbox"
alias nvim="$devbox nvim $@"
alias lg="$devbox lazygit $@"

# PS1
export PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\n\$ '

# Container Runners
