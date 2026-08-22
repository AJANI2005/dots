#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/opt/nvim"
BIN_DIR="/usr/local/bin"
TMP_DIR="/tmp/nvim-install"

echo "==> Installing dependencies..."
sudo apt update
sudo apt install -y curl tar

echo "==> Detecting architecture..."
ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        NVIM_ARCH="linux-x86_64"
        ;;
    aarch64)
        NVIM_ARCH="linux-arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "==> Downloading latest Neovim..."

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

curl -L \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-${NVIM_ARCH}.tar.gz" \
    -o "$TMP_DIR/nvim.tar.gz"

echo "==> Installing to $INSTALL_DIR..."

sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"

sudo tar -xzf "$TMP_DIR/nvim.tar.gz" \
    --strip-components=1 \
    -C "$INSTALL_DIR"

echo "==> Creating commands in $BIN_DIR..."

sudo ln -sf "$INSTALL_DIR/bin/nvim" "$BIN_DIR/nvim"
sudo ln -sf "$INSTALL_DIR/bin/nvim" "$BIN_DIR/vi"
sudo ln -sf "$INSTALL_DIR/bin/nvim" "$BIN_DIR/vim"

rm -rf "$TMP_DIR"

echo
echo "==> Neovim installed:"
nvim --version | head -n 1
