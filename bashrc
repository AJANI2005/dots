# Start Mango Compositor
if [ "$(tty)" = "/dev/tty1" ]  &&  [ -z "$WAYLAND_DISPLAY" ]; then
	exec mango
fi

# Containers
alias dev=~/ContainerFiles/devbox/devbox.sh

alias dnf-list="dnf repoquery --userinstalled | less"
