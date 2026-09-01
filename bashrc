# Start Mango Compositor
if [ "$(tty)" = "/dev/tty1" ]  &&  [ -z "$WAYLAND_DISPLAY" ]; then
	exec mango
fi

# Container Runners
. /home/ajani/containers/container-env.sh

# Helper aliases
alias dnf-list="dnf repoquery --userinstalled | less"
alias ll='ls -la'
alias l='ls -la'

alias d="devbox"
alias v="devbox nvim $@"
alias nvim="devbox nvim $@"
alias lg="devbox lazygit $@"

# PS1
export PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\n\$ '
