#!/bin/bash

MAX_PROC=6

function repos_to_update () {
    zypper list-updates | grep '^v ' | awk -F '|' '{ print $2 }' | sort --unique | tr -d ' '
}

function packages_from_repo () {
    local repo=$1

    zypper list-updates | grep " | $repo " | awk -F '|' '{ print $6, "#", $3, "-", $5, ".", $6, ".rpm" }' | tr -d ' '
}

function repo_uri () {
    local repo=$1

    zypper repos --uri | grep " | $repo " | awk -F '|' '{ print $7 }' | tr -d ' '
}

function repo_alias () {
    local repo=$1

    zypper repos | grep " | $repo " | awk -F '|' '{ print $2 }' | tr -d ' '
}

function download_package () {
    local alias=$1
    local uri=$2
    local line=$3
    IFS=# read arch package_name <<< "$line"

    local package_uri="$uri/$arch/$package_name"
    local local_dir="$HOME/.cache/zypp/packages/$alias/$arch"
    local local_path="$local_dir/$package_name"
    printf -v y %-30s "$repo"
    printf "Repository: $y Package: $package_name\n"
    if [ ! -f "$local_path" ]; then
        mkdir -p $local_dir
        curl --silent --fail -L -o $local_path $package_uri
    fi
}

function download_repo () {
    local repo=$1

    local uri=$(repo_uri $repo)
    local alias=$(repo_alias $repo)
    local pkgs=$(packages_from_repo $repo)
    local max_proc=$MAX_PROC
    while IFS= read -r line; do
        if [ $max_proc -eq 0 ]; then
            wait -n
            ((max_proc++))
        fi
        download_package "$alias" "$uri" "$line" &
        ((max_proc--))
    done <<< "$pkgs"
}

function download_all () {
    local repos=$(repos_to_update)
    while IFS= read -r line; do
        download_repo $line &
    done <<< "$repos"
    wait
}

download_all
#sudo cp -r ~/.cache/zypp/packages/* /var/cache/zypp/packages/
