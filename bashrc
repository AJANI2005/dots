# Start Mango Compositor
if [ "$(tty)" = "/dev/tty1" ]  &&  [ -z "$WAYLAND_DISPLAY" ]; then
	exec mango
fi

# Containers
alias dev=~/ContainerFiles/devbox/devbox.sh
commands=( "v:nvim" "lg:lazygit" "f:fzf" )
for cmd in "${commands[@]}"; do
    name="${cmd%%:*}"
    command="${cmd#*:}"
    eval "$name() { dev \"$command\" \"\$@\"; }"
done

alias dnf-list="dnf repoquery --userinstalled | less"
