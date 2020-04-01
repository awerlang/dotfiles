#!/bin/bash

# Repositories
#
# | Alias       | Name                       | Required |
# +-------------+----------------------------+----------+
# | repo-oss    | openSUSE-Tumbleweed-Oss    | *        |
# | repo-update | openSUSE-Tumbleweed-Update | *        |
# | code        | Visual Studio Code         |          |
# | NVIDIA      | NVIDIA                     |          |

COLOR1='\033[0;33m'
COLOR2='\033[0;34m'
NC='\033[0m'

if zypper --color repos code > /dev/null; then
    printf "${COLOR1}> Checking Visual Studio Code${NC}\n\n"

    sudo zypper refresh --repo code
    if zypper list-updates --repo code | grep "^v "; then
        sudo zypper --non-interactive --color dup --details --auto-agree-with-licenses --from code
        printf "\n${COLOR2}>> New Visual Studio Code installed.${NC}\n"
        notify-send -a "Visual Studio Code" -t 5000 "New VS Code installed"
    else
        printf "\n${COLOR2}>> Done.${NC}\n"
    fi

    echo ""
fi

SKIP_SYSTEM_REASON=""

if zypper --color repos NVIDIA > /dev/null; then
    printf "${COLOR1}> Checking NVIDIA${NC}\n\n"

    sudo zypper refresh --repo NVIDIA
    if zypper list-updates --repo NVIDIA | grep "^v "; then
        sudo zypper refresh
        sudo zypper --non-interactive --color dup --download-only --details --auto-agree-with-licenses

        echo ""
        printf "${COLOR2}>> New NVIDIA driver available.${NC}\n"
        printf "${COLOR2}>> It's a good time to update the system.${NC}\n"
        notify-send -a "System update" -t 5000 "New NVIDIA driver available" "It's a good time to update the system ;)"
    else
        SKIP_SYSTEM_REASON="Waiting for NVIDIA"
        printf "\n${COLOR2}>> No updates to NVIDIA found.${NC}\n"
    fi

    echo ""
fi

printf "${COLOR1}> Checking System${NC}\n\n"
if [ -z "$SKIP_SYSTEM_REASON" ]; then
    sudo zypper refresh
    if zypper list-updates | grep "^v "; then
        sudo zypper --non-interactive --color dup --download-only --details --auto-agree-with-licenses

        echo ""
        printf "${COLOR2}>> New system updates available.${NC}\n"
        printf "${COLOR2}>> It's a good time to update the system.${NC}\n"
        notify-send -a "System update" -t 5000 "New system updates available" "It's a good time to update the system ;)"
    else
        printf "\n${COLOR2}>> No updates found. Hooray!${NC}\n"
    fi
else
    printf "${COLOR2}>> Skipping System: $SKIP_SYSTEM_REASON.${NC}\n"
fi

echo ""

printf "${COLOR1}> Checking hot-fixes${NC}\n\n"
sudo zypper refresh --repo repo-update
pkglist=$(zypper list-updates | grep "openSUSE-Tumbleweed-Update" | awk -F \| '{ print $3 }')
if [ -n "$pkglist" ]; then
    pkgtree=""
    while IFS= read -r pkg; do
        pkgtree+="*$pkg\n"
        deps=$(zypper search --installed-only --requires-pkg $pkg | grep "^i" | awk -F \| '{ print "  └─" $2 }' | grep -v " lib")
        [ -n "$deps" ] && pkgtree+="$deps\n"
    done <<< "$pkglist"
    printf "\n${COLOR2}>> Found hot-fixes for installed packages.${NC}\n\nPackages:\n$pkgtree\n"
    notify-send -a "System update" -t 5000 "Found hot-fixes" "Packages: \n$pkgtree"
else
    printf "\n${COLOR2}>> No urgent updates found.${NC}\n"
fi
