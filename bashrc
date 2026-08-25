# Start Mango Compositor
if [ "$(tty)" = "/dev/tty1" ]  &&  [ -z "$WAYLAND_DISPLAY" ]; then
	exec mango
fi

# Helper aliases

# Containers
alias dnf-list="dnf repoquery --userinstalled | less"
alias nvim="dev nvim \$@"
alias v="dev nvim \$@"
alias lg="dev lazygit \$@"

dev() {
	folder="$(basename $PWD)"
	podman run --rm -it \
		--hostname=dev \
		--security-opt label=disable \
		--secret github-token,type=env,target=GITHUB_TOKEN \
		-w "/workspace/$folder" \
		-v "$PWD:/workspace/$folder" \
		-v dev-nvim:/root/.local/share/nvim \
		-v dev-nvim:/root/.local/state/nvim \
		dev:latest "$@"
}

