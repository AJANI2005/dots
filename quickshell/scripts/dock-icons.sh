#!/bin/sh

app_id=$(echo "$1" | tr '[:upper:]' '[:lower:]')

match_icon() {
    case "$app_id" in
        *browser*|*firefox*|*chrome*|*chromium*|*zen*|*zen_browser*|*zen-browser*|*app.zen_browser*|*edge*|*brave*|*opera*|*vivaldi*|*tor*|*epiphany*|*librewolf*|*waterfox*|*floorp*|*mercury*)
            echo "󰖟"
            ;;
        *foot*|*kitty*|*alacritty*|*ghostty*|*wezterm*|*konsole*|*terminal*|*tilix*|*st*|*xterm*|*gnome-terminal*|*uxterm*|*rxvt*|*urxvt*|*eterm*)
            echo "󰞷"
            ;;
        *code*|*editor*|*ide*|*neovim*|*nvim*|*vim*|*sublime*|*emacs*|*helix*|*qtcreator*|*goland*|*intellij*|*webstorm*|*pycharm*|*rider*|*clion*|*vscode*|*vscodium*|*cursor*|*zed*|*lazygit*|*gitui*)
            echo "󰨞"
            ;;
        *file*|*nautilus*|*thunar*|*dolphin*|*nemo*|*pcmanfm*|*caja*|*commander*|*ranger*|*lf*|*yazi*|*nnn*|*midnight-commander*|*mc*)
            echo "󰉋"
            ;;
        *discord*|*slack*|*chat*|*telegram*|*element*|*signal*|*whatsapp*|*matrix*|*vesktop*|*ferdium*|*teams*|*zoom*|*skype*|*discord-canary*|*discord-ptb*|*wechat*|*qq*)
            echo "󰙯"
            ;;
        *spotify*|*music*|*audio*|*vlc*|*mpv*|*rhythmbox*|*audacious*|*player*|*sound*|*cider*|*tidal*|*qogir*|*apple-music*|*youtube-music*|*soundcloud*|*pulsemixer*|*pavucontrol*)
            echo "󰝚"
            ;;
        *setting*|*control*|*pavucontrol*|*config*|*gnome-control-center*|*systemsettings*|*kde-systemsettings*|*xfce4-settings*|*lxappearance*|*nvidia-settings*)
            echo "󰒓"
            ;;
        *game*|*steam*|*lutris*|*heroic*|*minecraft*|*itch*|*retroarch*|*bottle*|*wine*|*proton*|*playonlinux*|*bottles*|*gog-galaxy*|*epic-games*|*ea-app*)
            echo "󰊴"
            ;;
        *mail*|*thunderbird*|*evolution*|*mutt*|*neomutt*|*geary*|*kmail*|*k-9*|*fair-email*|*thunderbird-esr*)
            echo "󰇮"
            ;;
        *doc*|*writer*|*calc*|*libreoffice*|*pdf*|*evince*|*okular*|*obsidian*|*note*|*logseq*|*ionide*|*zathura*|*mupdf*|*qpdfview*|*atril*|*xreader*)
            echo "󰏆"
            ;;
        *image*|*photo*|*gimp*|*inkscape*|*krita*|*blender*|*shotwell*|*imv*|*feh*|*eog*|*nsxiv*|*sxiv*|*viewnior*|*mirage*|*ristretto*|*nomacs*|*darktable*|*rawtherapee*|*photoshop*|*kdenlive*)
            echo "󰋩"
            ;;
        *video*|*obs*|*kdenlive*|*shotcut*|*cheese*|*mpv*|*vlc*|*handbrake*|*avidemux*|*ffmpeg*|*celluloid*|*haruna*|*plasma-tube*|*freetube*)
            echo "󰕧"
            ;;
        *download*|*qbittorrent*|*transmission*|*deluge*|*torrent*|*jd2*|*jdownloader*|*motrix*|*aria2*|*uget*|*flaresolverr*|*jd*|*jdownloader2*)
            echo "󰉍"
            ;;
        *git*|*github*|*gitlab*|*lazygit*|*gitui*|*tig*|*gitk*|*git-gui*|*git-cola*|*fork*|*github-desktop*|*gitkraken*)
            echo "󰊢"
            ;;
        *)
            echo "󰣆"
            ;;
    esac
}

match_icon