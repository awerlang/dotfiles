#!/bin/bash

if sudo zypper --no-refresh dup --details --auto-agree-with-licenses; then
    sudo rpmconfigcheck
fi

echo "Done."
