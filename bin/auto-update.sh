#!/bin/bash

# Repositories
#
# | Alias       | Name                       | Required |
# +-------------+----------------------------+----------+
# | repo-oss    | openSUSE-Tumbleweed-Oss    | *        |
# | repo-update | openSUSE-Tumbleweed-Update | *        |
# | code        | Visual Studio Code         |          |
# | NVIDIA      | NVIDIA                     |          |

set -o nounset -o noclobber -o pipefail

COLOR1=$(tput setaf 3)
COLOR2=$(tput setaf 4)
COLOR3=$(tput setaf 2)
NC=$(tput sgr0)

exec 3>&1

main() {
    refresh
    vscode
    local major skip_system updates
    major=$(kernel)
    skip_system=$(nvidia "$major")
    updates=$(system "$skip_system")
    hotfixes

    if [[ -n "$updates" ]]; then
        summary "It's a good time to update the system."
    fi

    if [[ -n "$major" ]] && [[ -n "$skip_system" ]]; then
        exit 1
    fi
}

notify() {
    [[ "$(command -v notify-send)" ]] || return

    local summary=$1
    local body=$2
    notify-send -a "System update" -t 5000 "$summary" "$body"
}

result() {
    printf "%s\n" "$1"
}

error() {
    printf "%s\n" "$1"
} >&2

log() {
    #shellcheck disable=SC2059
    printf "$@"
} >&3

quiet() {
    exec 3>/dev/null
}

task() {
    log "${COLOR1}> %s${NC}\n" "${1}"
}

content() {
    log "${COLOR2}  > %s${NC}\n" "${1}"
}

summary() {
    log "${COLOR3}> %s${NC}\n" "${1}"
}

refresh() {
    task "Refreshing Repositories"

    sudo zypper refresh >/dev/null
}

vscode() {
    zypper --color repos code >/dev/null || return

    task "Checking Visual Studio Code"

    zypper list-updates --repo code | grep "^v " >/dev/null || return

    sudo zypper --non-interactive --color dup --details --auto-agree-with-licenses --from code >/dev/null
    content "New Visual Studio Code installed."
    notify "Visual Studio Code" "New VS Code installed"
}

kernel() {
    task "Checking Linux Kernel"

    local major
    major=$(zypper list-updates | awk -v kernel="kernel-default" '
        $5 == kernel {
            split($7, old, ".");
            split($9, new, ".");
            major=new[1] != old[1] || new[2] != old[2] ? $9 : "";
            print major;
        }
        '
    )

    if [[ -n "$major" ]]; then
        content "New major Linux kernel available."
    fi

    result "$major"
}

nvidia() {
    zypper --color repos NVIDIA >/dev/null || return

    task "Checking NVIDIA"

    local major=$1
    [[ -z "$major" ]] && return

    if ! zypper list-updates --repo NVIDIA | grep "^v " >/dev/null; then
        result "Waiting for NVIDIA release after major Linux Kernel"
    fi
}

system() {
    task "Checking System"

    local skip=$1
    if [[ -n "$skip" ]]; then
        content "Skipping System: ${skip}."
        return
    fi

    zypper list-updates | grep "^v " >/dev/null || return

    zypper-download.sh dup

    content "New system updates available."
    notify "New system updates available" "It's a good time to update the system ;)"
    result "yes"
}

hotfixes() {
    task "Checking Hot-Fixes"

    local pkglist
    pkglist=$(zypper list-updates | grep "openSUSE-Tumbleweed-Update" | awk -F \| '{ print $3 }')
    [[ -n "$pkglist" ]] || return

    local -a pkgtree
    while IFS= read -r pkg; do
        pkgtree+=('*'"$pkg")
        local deps
        deps=$(zypper search --installed-only --requires-pkg "$pkg" | grep "^i" | awk -F \| '{ print "  └─" $2 }' | grep -v " lib")
        [[ -n "$deps" ]] && pkgtree+=("$deps")
    done <<< "$pkglist"
    content "Found hot-fixes for installed packages."
    content "Packages:"
    local pkgtree_str
    pkgtree_str=$(printf '%s\n' "${pkgtree[@]}")
    content "$pkgtree_str"
    notify "Found hot-fixes" "Packages: \n$pkgtree_str"
}

main
