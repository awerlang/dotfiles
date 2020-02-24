#!/bin/bash

COLOR1='\033[0;33m'
COLOR2='\033[0;34m'
NC='\033[0m'

tmpfile=$(mktemp /tmp/auto_update.XXXXXX)

printf "${COLOR1}> Checking Visual Studio Code${NC}\n\n"
sudo zypper refresh --repo code
sudo zypper --non-interactive --color dup --details --auto-agree-with-licenses --from code | tee $tmpfile
if grep --extended-regexp "Installing: .*done\]" $tmpfile; then
    printf "\n${COLOR2}>> New Visual Studio Code installed.${NC}\n"
    notify-send -a "Visual Studio Code" -t 5000 "New VS Code installed"
else
    printf "\n${COLOR2}>> Done.${NC}\n"
fi

echo ""

SKIP_SYSTEM_REASON=""

printf "${COLOR1}> Checking NVIDIA${NC}\n\n"
if zypper --color repos NVIDIA > /dev/null; then
    sudo zypper refresh --repo NVIDIA
    sudo zypper --non-interactive --color dup --dry-run --details --auto-agree-with-licenses --from NVIDIA | tee $tmpfile
    if grep --extended-regexp "Nothing to do." $tmpfile > /dev/null; then
        SKIP_SYSTEM_REASON="Waiting for NVIDIA"
        printf "\n${COLOR2}>> No updates to NVIDIA found.${NC}\n"
    else
        sudo zypper refresh
        sudo zypper --non-interactive --color dup --download-only --details --auto-agree-with-licenses

        echo ""
        printf "${COLOR2}>> New NVIDIA driver available.${NC}\n"
        printf "${COLOR2}>> It's a good time to update the system.${NC}\n"
        notify-send -a "System update" -t 5000 "New NVIDIA driver available" "It's a good time to update the system ;)"
    fi
fi

echo ""

printf "${COLOR1}> Checking System${NC}\n\n"
if [ -z "$SKIP_SYSTEM_REASON" ]; then
    sudo zypper refresh
    sudo zypper --non-interactive --color dup --dry-run --details --auto-agree-with-licenses | tee $tmpfile
    if grep --extended-regexp "Nothing to do." $tmpfile > /dev/null; then
        printf "\n${COLOR2}>> No updates found. Hooray!${NC}\n"
    else
        sudo zypper --non-interactive --color dup --download-only --details --auto-agree-with-licenses

        echo ""
        printf "${COLOR2}>> New system updates available.${NC}\n"
        printf "${COLOR2}>> It's a good time to update the system.${NC}\n"
        notify-send -a "System update" -t 5000 "New system updates available" "It's a good time to update the system ;)"
    fi
else
    printf "\n${COLOR2}>> Skipping System: $SKIP_SYSTEM_REASON.${NC}\n"
fi

echo ""

printf "${COLOR1}> Checking hot-fixes${NC}\n\n"
sudo zypper refresh --repo repo-update
if zypper search --installed-only --repo=repo-update | awk -F \| '{ print $2 }' | sort | uniq | sed 's/^ *//;s/ *$//' | grep -v -e "^Name$" -e "^$"; then
    printf ">> Found hot-fixes for installed packages.\n"
    notify-send -a "System update" -t 5000 "Found hot-fixes" "It's a good time to update the system ;)"
else
    printf "\n${COLOR2}>> No urgent updates found.${NC}\n"
fi
