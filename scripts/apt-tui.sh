#!/bin/bash

set -e


installed() {
    dpkg-query -W -f='${binary:Package}\n' 2>/dev/null |
        grep -v ':'
}

installed_packages() {
    installed |
        fzf \
            --multi \
            --height=100% \
            --layout=reverse \
            --border \
            --prompt="Installed > " \
            --header="TAB select • ENTER remove • ESC back" \
            --preview='apt-cache show {} 2>/dev/null' \
            --preview-window='right:60%:wrap'
}

search_packages() {
    apt-cache pkgnames |
        fzf \
            --multi \
            --height=100% \
            --layout=reverse \
            --border \
            --prompt="Search > " \
            --header="TAB select • ENTER install • ESC back" \
            --preview='apt-cache show {} 2>/dev/null' \
            --preview-window='right:60%:wrap'
}

main_menu() {
    printf '%s\n' \
        "Installed packages" \
        "Search & install" \
        "Update package lists" \
        "Upgrade system" |
        fzf \
            --height=50% \
            --layout=reverse \
            --border \
            --prompt="[apt tui] > " \
            --header="Select an action"
}

while true; do
    action=$(main_menu) || exit 0

    case "$action" in
        "Installed packages")
            packages=$(installed_packages) || continue
            [ -z "$packages" ] && continue

            sudo apt remove $packages
            ;;

        "Search & install")
            packages=$(search_packages) || continue
            [ -z "$packages" ] && continue

            sudo apt install $packages
            ;;

        "Update package lists")
            sudo apt update
            ;;

        "Upgrade system")
            sudo apt upgrade
            ;;
    esac
done
