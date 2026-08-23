#!/usr/bin/env bash
set -euo pipefail

REPO="https://gitlab.com/asus-linux/asusctl.git"
INSTALL_DIR="/opt/asusctl"
BUILD_DIR="/tmp/asusctl-build"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

install_asusctl() {
    echo "==> Installing system dependencies..."

    sudo apt update

    sudo apt install -y \
        curl \
        git \
        build-essential \
        pkg-config \
        libudev-dev \
        libsystemd-dev \
        libdbus-1-dev \
        libinput-dev \
        libfontconfig-dev \
        libwayland-dev \
        wayland-protocols \
        libseat-dev \
        libxkbcommon-dev \
        libclang-dev \
        power-profiles-daemon

    echo "==> Setting up Rust..."

    if ! command -v rustup >/dev/null 2>&1; then
        curl --proto '=https' --tlsv1.2 -sSf \
            https://sh.rustup.rs | sh -s -- -y
    fi

    export PATH="$HOME/.cargo/bin:$PATH"

    rustup toolchain install stable
    rustup default stable

    echo "==> Rust:"
    rustc --version
    cargo --version

    echo "==> Cloning asusctl..."

    rm -rf "$BUILD_DIR"
    git clone --depth 1 "$REPO" "$BUILD_DIR"

    cd "$BUILD_DIR"

    echo "==> Building asusctl..."

    make build || die "asusctl compilation failed"

    echo "==> Installing to $INSTALL_DIR..."

    sudo rm -rf "$INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"

    echo "==> Installing binaries..."

    if [[ -f target/release/asusctl ]]; then
        sudo install -m 755 \
            target/release/asusctl \
            "$INSTALL_DIR/asusctl"

        sudo install -m 755 \
            target/release/asusd \
            "$INSTALL_DIR/asusd"
    else
        die "asusctl binaries were not produced"
    fi

    echo "==> Installing system files..."

    sudo make install

    echo "==> Reloading systemd..."

    sudo systemctl daemon-reload

    echo "==> Reloading udev..."

    sudo udevadm control --reload
    sudo udevadm trigger

    echo "==> Enabling power-profiles-daemon..."

    sudo systemctl enable --now power-profiles-daemon.service

    echo "==> Starting asusd..."

    if systemctl list-unit-files | grep -q '^asusd.service'; then
        sudo systemctl restart asusd.service
    else
        echo "WARNING: asusd.service was not installed"
    fi

    echo
    echo "==> Installation complete:"
    ls -lh "$INSTALL_DIR"

    echo
    echo "==> asusctl:"
    "$INSTALL_DIR/asusctl" --version || true

    echo
    echo "==> Copying binaries to /usr/local/bin..."

    sudo install -m 755 \
        "$INSTALL_DIR/asusctl" \
        /usr/local/bin/asusctl

    sudo install -m 755 \
        "$INSTALL_DIR/asusd" \
        /usr/local/bin/asusd

    echo
    echo "asusctl installed successfully."
}

uninstall_asusctl() {
    echo "==> Stopping asusd..."

    if systemctl list-unit-files | grep -q '^asusd.service'; then
        sudo systemctl disable --now asusd.service || true
    fi

    echo "==> Removing asusctl..."

    sudo rm -rf "$INSTALL_DIR"

    echo "==> Removing build directory..."

    rm -rf "$BUILD_DIR"

    echo "==> Removing binaries from /usr/local/bin..."

    sudo rm -f \
        /usr/local/bin/asusctl \
        /usr/local/bin/asusd

    echo
    echo "asusctl has been removed."
}

reinstall_asusctl() {
    uninstall_asusctl
    install_asusctl
}

case "${1:-}" in
    install)
        install_asusctl
        ;;
    uninstall|remove)
        uninstall_asusctl
        ;;
    reinstall)
        reinstall_asusctl
        ;;
    *)
        echo "Usage: $0 {install|uninstall|reinstall}"
        echo
        echo "  install      Build and install asusctl"
        echo "  uninstall    Remove asusctl"
        echo "  reinstall    Remove and build asusctl again"
        exit 1
        ;;
esac
