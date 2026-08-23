#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Niri source build
#
# Build directory: /tmp
# Install prefix:  /opt/niri
#
# Usage:
#   sudo ./niri-build.sh install
#   sudo ./niri-build.sh uninstall
#
# ============================================================

PROJECT="niri"
REPO="https://github.com/YaLTeR/niri.git"
PREFIX="/opt/niri"

BUILD_ROOT="$(mktemp -d /tmp/niri-build.XXXXXX)"
SOURCE_DIR="${BUILD_ROOT}/${PROJECT}"

cleanup() {
    rm -rf "$BUILD_ROOT"
}
trap cleanup EXIT

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "ERROR: This script must be run with sudo."
        echo
        echo "Usage:"
        echo "  sudo $0 install"
        echo "  sudo $0 uninstall"
        exit 1
    fi
}

install_dependencies() {
    echo "==> Installing build dependencies..."

    apt-get update

    apt-get install -y \
        git \
        curl \
        build-essential \
        pkg-config \
        libwayland-dev \
        wayland-protocols \
        libinput-dev \
        libudev-dev \
        libxkbcommon-dev \
        libegl-dev \
        libgles-dev \
        libdrm-dev \
        libgbm-dev \
        libseat-dev \
        libpipewire-0.3-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libdbus-1-dev \
        libsystemd-dev \
        libpango1.0-dev \
        libglib2.0-dev \
        libpixman-1-dev \
        scdoc

    if ! command -v rustc >/dev/null 2>&1 || \
       ! command -v cargo >/dev/null 2>&1; then

        echo
        echo "==> Rust/Cargo not found."
        echo "==> Installing Rust using rustup..."

        apt-get install -y rustup

        rustup default stable
    fi
}

build_niri() {
    echo
    echo "============================================================"
    echo " Building Niri"
    echo "============================================================"
    echo
    echo "Temporary build directory:"
    echo "  $BUILD_ROOT"
    echo

    echo "==> Cloning Niri..."

    git clone \
        --depth 1 \
        "$REPO" \
        "$SOURCE_DIR"

    cd "$SOURCE_DIR"

    echo "==> Rust version:"
    rustc --version

    echo "==> Cargo version:"
    cargo --version

    echo
    echo "==> Building Niri..."

    cargo build --release

    echo
    echo "==> Installing Niri to:"
    echo "    $PREFIX"
    echo

    install -d "$PREFIX/bin"

    install -m 0755 \
        target/release/niri \
        "$PREFIX/bin/niri"

    # Install desktop/session files if they exist.
    if [[ -d resources ]]; then
        mkdir -p "$PREFIX/share"

        cp -a resources/. "$PREFIX/share/" || true
    fi

    echo
    echo "==> Creating environment wrapper..."

    cat > "$PREFIX/bin/niri-env" <<'EOF'
#!/usr/bin/env bash

export PATH="/opt/niri/bin:$PATH"

exec /opt/niri/bin/niri "$@"
EOF

    chmod +x "$PREFIX/bin/niri-env"

    echo
    echo "============================================================"
    echo " Niri installed successfully"
    echo "============================================================"
    echo
    echo "Binary:"
    echo "  $PREFIX/bin/niri"
    echo
    echo "Run:"
    echo "  $PREFIX/bin/niri"
    echo
    echo "The temporary build directory has been removed."
    echo
}

uninstall_niri() {
    echo "==> Removing Niri from:"
    echo "    $PREFIX"

    if [[ -d "$PREFIX" ]]; then
        rm -rf "$PREFIX"
        echo "Removed $PREFIX"
    else
        echo "Niri is not installed at $PREFIX"
    fi

    echo
    echo "============================================================"
    echo " Niri has been removed"
    echo "============================================================"
    echo
    echo "No Debian packages were removed."
}

usage() {
    echo "Usage:"
    echo
    echo "  sudo $0 install"
    echo "  sudo $0 uninstall"
    echo
}

case "${1:-}" in
    install)
        require_root
        install_dependencies
        build_niri
        ;;

    uninstall)
        require_root
        uninstall_niri
        ;;

    *)
        usage
        exit 1
        ;;
esac
