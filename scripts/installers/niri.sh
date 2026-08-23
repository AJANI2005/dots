#!/usr/bin/env bash
set -e

PREFIX="/opt/niri"
BUILD="/tmp/niri-build"
REF="${NIRI_REF:-main}"

install() {
    sudo apt update

    sudo apt install -y \
        build-essential \
        clang \
        pkg-config \
        git \
        curl \
        libudev-dev \
        libgbm-dev \
        libxkbcommon-dev \
        libegl1-mesa-dev \
        libwayland-dev \
        libinput-dev \
        libdbus-1-dev \
        libsystemd-dev \
        libseat-dev \
        libpipewire-0.3-dev \
        libpango1.0-dev \
        libdisplay-info-dev \
        xwayland \
        xdg-desktop-portal \
        xdg-desktop-portal-gtk 

    if ! command -v cargo >/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    rm -rf "$BUILD"
    git clone --depth 1 --branch "$REF" \
        https://github.com/niri-wm/niri.git "$BUILD"

    cd "$BUILD"
    cargo build --release

    sudo mkdir -p \
        "$PREFIX/bin" \
        "$PREFIX/share/wayland-sessions" \
        "$PREFIX/share/xdg-desktop-portal" \
        "$PREFIX/lib/systemd/user"

    sudo install -Dm755 \
        target/release/niri \
        "$PREFIX/bin/niri"

    sudo install -Dm755 \
        resources/niri-session \
        "$PREFIX/bin/niri-session"

    sudo install -Dm644 \
        resources/niri.desktop \
        "$PREFIX/share/wayland-sessions/niri.desktop"

    sudo install -Dm644 \
        resources/niri-portals.conf \
        "$PREFIX/share/xdg-desktop-portal/niri-portals.conf"

    sudo install -Dm644 \
        resources/niri.service \
        "$PREFIX/lib/systemd/user/niri.service"

    sudo install -Dm644 \
        resources/niri-shutdown.target \
        "$PREFIX/lib/systemd/user/niri-shutdown.target"

    sudo sed -i \
        's#ExecStart=/usr/bin/niri#ExecStart=/usr/local/bin/niri#' \
        "$PREFIX/lib/systemd/user/niri.service"

    sudo mkdir -p \
        /usr/local/bin \
        /usr/local/share/wayland-sessions \
        /usr/local/lib/systemd/user \
        /usr/share/xdg-desktop-portal

    sudo ln -sfn \
        "$PREFIX/bin/niri" \
        /usr/local/bin/niri

    sudo ln -sfn \
        "$PREFIX/bin/niri-session" \
        /usr/local/bin/niri-session

    sudo ln -sfn \
        "$PREFIX/share/wayland-sessions/niri.desktop" \
        /usr/local/share/wayland-sessions/niri.desktop

    sudo ln -sfn \
        "$PREFIX/lib/systemd/user/niri.service" \
        /usr/local/lib/systemd/user/niri.service

    sudo ln -sfn \
        "$PREFIX/lib/systemd/user/niri-shutdown.target" \
        /usr/local/lib/systemd/user/niri-shutdown.target

    sudo ln -sfn \
        "$PREFIX/share/xdg-desktop-portal/niri-portals.conf" \
        /usr/share/xdg-desktop-portal/niri-portals.conf

    rm -rf "$BUILD"

    systemctl --user daemon-reload 2>/dev/null || true

    echo "Niri installed: $(readlink -f /usr/local/bin/niri)"
}

uninstall() {
    systemctl --user stop niri.service 2>/dev/null || true
    systemctl --user disable niri.service 2>/dev/null || true

    sudo rm -f \
        /usr/local/bin/niri \
        /usr/local/bin/niri-session \
        /usr/local/share/wayland-sessions/niri.desktop \
        /usr/local/lib/systemd/user/niri.service \
        /usr/local/lib/systemd/user/niri-shutdown.target \
        /usr/share/xdg-desktop-portal/niri-portals.conf

    sudo rm -rf "$PREFIX"

    systemctl --user daemon-reload 2>/dev/null || true

    echo "Niri uninstalled."
}

case "${1:-install}" in
    install)
        install
        ;;
    uninstall|remove)
        uninstall
        ;;
    *)
        echo "Usage: $0 [install|uninstall]"
        exit 1
        ;;
esac
