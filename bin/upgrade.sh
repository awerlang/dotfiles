#!/bin/bash

PKG_CACHE_DIR="$HOME/.cache/zypp/packages"

zypper() {
    sudo 'zypper' --no-refresh --pkg-cache-dir "$PKG_CACHE_DIR" "$@"
}

zypper-changelog.sh "$PKG_CACHE_DIR"
if zypper dup --details --auto-agree-with-licenses; then
    zypper clean
    sudo rpmconfigcheck > >(while read line; do echo -e "\e[01;31m$line\e[0m" >&2; done)
    local-overrides.sh
fi

echo "Done."
