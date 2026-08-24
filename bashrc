# Start Mango Compositor
if [ "$(tty)" = "/dev/tty1" ]  &&  [ -z "$WAYLAND_DISPLAY" ]; then
	exec mango
fi

# Containers
alias devbox=~/dots/containers/devbox
alias nvim="devbox nvim \$@"
alias dnf-list="dnf repoquery --userinstalled | less"
