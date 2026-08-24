# Start Mango Compositor
if [ "$(tty)" = "/dev/tty1" ]  &&  [ -z "$WAYLAND_DISPLAY" ]; then
	exec mango
fi

# Podman alias
alias dev=~/ContainerFiles/devbox/devbox.sh
function nvim() { dev nvim $@; }
function lg() { dev lazygit $@; }

alias dnf-list="dnf repoquery --userinstalled | less"
