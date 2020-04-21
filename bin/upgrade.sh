#!/bin/bash

PKG_CACHE_DIR="$HOME/.cache/zypp/packages"

zypper() {
    sudo zypper --no-refresh --pkg-cache-dir "$PKG_CACHE_DIR" "$@"
}

zypper-changelog.sh "$PKG_CACHE_DIR"
if zypper dup --details --auto-agree-with-licenses; then
    zypper clean
    sudo rpmconfigcheck
    local-overrides.sh
fi

echo "Done."
