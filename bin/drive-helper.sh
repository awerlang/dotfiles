#!/bin/bash

COLOR1='\033[0;33m'
COLOR2='\033[0;34m'
NC='\033[0m'

main() {
    target="${HOME}/.local/share/drive-helper"
    mkdir "$target"
    run | tee "${target}/disk-$(date -I).log"
}

run() {
    printf "${COLOR1}> Disk state before maintenance${NC}\n\n"
    sudo btrfs filesystem usage /
    printf "\n"

    printf "${COLOR1}> Cleaning old snapshots${NC}\n\n"
    sudo /usr/lib/snapper/systemd-helper --cleanup
    printf "\n"

    printf "${COLOR1}> Checking data integrity${NC}\n\n"
    sudo btrfs scrub start -BR /
    printf "\n"

    printf "${COLOR1}> Compacting data blocks${NC}\n\n"
    sudo btrfs balance start --verbose -dusage=5 /
    printf "\n"

    printf "${COLOR1}> Discarding unused blocks${NC}\n\n"
    sudo fstrim --fstab --verbose
    printf "\n"

    printf "${COLOR1}> Disk state after maintenance${NC}\n\n"
    sudo btrfs filesystem usage /
    printf "\n"

    printf "${COLOR1}> S.M.A.R.T.${NC}\n\n"
    sudo smartctl --scan | awk '{ print $1 } ' | sort | xargs -n1 -I {} sh -c 'printf "${COLOR2}>> {}${NC}\n\n" && sudo smartctl -a {}'
    printf "\n"
}

main
