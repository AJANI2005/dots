# Start Mango Compositor
if [ "$(tty)" = "/dev/tty1" ]  &&  [ -z "$WAYLAND_DISPLAY" ]; then
	exec mango
fi

# Containers
alias dev=~/ContainerFiles/devbox/devbox.sh
commands=(nvim lazygit fzf)

for cmd in ${commands[@]}; do
	eval "function $cmd { dev $cmd \"\$@\"; };"
done

alias dnf-list="dnf repoquery --userinstalled | less"
