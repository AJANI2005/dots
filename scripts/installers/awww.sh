#!/usr/bin/env bash
set -euo pipefail

REPO="https://codeberg.org/LGFae/awww.git"
INSTALL_DIR="/opt/awww"
BUILD_DIR="/tmp/awww-build"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

install_awww() {
    echo "==> Installing system dependencies..."

    sudo apt update

    sudo apt install -y \
        curl \
        git \
        build-essential \
        pkg-config \
        liblz4-dev \
        libwayland-dev \
        wayland-protocols

    echo "==> Setting up Rust..."

    if ! command -v rustup >/dev/null 2>&1; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | sh -s -- -y
    fi

    export PATH="$HOME/.cargo/bin:$PATH"

    rustup toolchain install stable
    rustup default stable

    echo "==> Rust:"
    rustc --version
    cargo --version

    echo "==> Cloning awww..."

    rm -rf "$BUILD_DIR"
    git clone --depth 1 "$REPO" "$BUILD_DIR"

    cd "$BUILD_DIR"

    echo "==> Building awww..."

    cargo build --release || die "awww compilation failed"

    [[ -f target/release/awww ]] ||
        die "awww binary was not produced"

    [[ -f target/release/awww-daemon ]] ||
        die "awww-daemon binary was not produced"

    echo "==> Installing to $INSTALL_DIR..."

    sudo rm -rf "$INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"

    sudo install -m 755 \
        target/release/awww \
        "$INSTALL_DIR/awww"

    sudo install -m 755 \
        target/release/awww-daemon \
        "$INSTALL_DIR/awww-daemon"

    echo
    echo "==> Installation complete:"
    ls -lh "$INSTALL_DIR"

    echo
    "$INSTALL_DIR/awww" --version
    
    echo "==> Coping to /usr/local/bin"
    sudo chmod 755 /usr/local/bin/awww
    sudo cp target/release/awww /usr/local/bin/awww

    sudo chmod 755 /usr/local/bin/awww-daemon
    sudo cp target/release/awww-daemon /usr/local/bin/awww-daemon
}

uninstall_awww() {
    echo "==> Removing awww..."

    sudo rm -rf "$INSTALL_DIR"

    echo "==> Removing build directory..."
    rm -rf "$BUILD_DIR"

    echo
    echo "awww has been removed from:"
    echo "$INSTALL_DIR"
}

reinstall_awww() {
    uninstall_awww
    install_awww
}

case "${1:-}" in
    install)
        install_awww
        ;;
    uninstall|remove)
        uninstall_awww
        ;;
    reinstall)
        reinstall_awww
        ;;
    *)
        echo "Usage: $0 {install|uninstall|reinstall}"
        echo
        echo "  install      Build and install awww"
        echo "  uninstall    Remove awww from /opt/awww"
        echo "  reinstall    Remove and build awww again"
        exit 1
        ;;
esac
