# ~/.bashrc

# Interactive shell only
[[ $- != *i* ]] && return

# PATH
export PATH="$HOME/.local/bin:$PATH"

# History
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth

# Useful aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias c='clear'
alias aptui="$HOME/.config/scripts/aptui.sh"
alias lg='lazygit'

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# Start Sway from a TTY
if [[ -z "$WAYLAND_DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
    exec sway
fi

