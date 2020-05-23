#!/bin/bash

set -o errexit -o nounset -o noclobber -o pipefail

main() {
    systemctl cat grub2-once.service | grep -F 'ExecStartPost=-/usr/bin/systemctl disable grub2-once.service' >/dev/null \
        || printf "> To review: Service grub2-once.service has changed since the override was applied.\n"
}

main
