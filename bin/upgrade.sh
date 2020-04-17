#!/bin/bash

zypper() {
    sudo zypper --no-refresh --pkg-cache-dir "$HOME/.cache/zypp/packages" "$@"
}

if zypper dup --details --auto-agree-with-licenses; then
    zypper clean
    sudo rpmconfigcheck
    local-overrides.sh
fi

echo "Done."
