#!/bin/bash
#####################################################################################################
##
### NAME
##      %program-name% - %Description%
##
### SYNOPSIS
##      Usage: %program-name% [options] command [command-args]...
##
##      Options:
##
##          -c              Display default configuration.
##          -h              Display this message and exit.
##          -v              Display version information and exit.
##
##      Commands:
##
##          cmd
##
### CONFIGURATION
##      %VARIABLE%          = ${ENV_VAR}
##
### LICENSE
##      %program-name% v0.1
##
##      Copyright (C) 2020 André Werlang
##
##      License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
##      This is free software: you are free to change and redistribute it.
##      There is NO WARRANTY, to the extent permitted by law.
##
#####################################################################################################

set -o errexit -o nounset -o noclobber -o pipefail
#shopt -s nullglob

run() {
    # script body
}

parse_opts() {
    local OPTIND OPTARG flag
    while getopts hvczd: flag
    do
        case "$flag" in
        (h) help; exit 0;;
        (v) version; exit 0;;
        (c) configuration | about; exit 0;;
        (s) readonly STRING_OPTION="$OPTARG";;
        (b) readonly BOOL_OPTION="yes";;
        (*) usage; exit 1;;
        esac
    done
    shift $((OPTIND-1))

    if [ $# -eq 0 ]; then
        error "expected required argument -- command"
        usage;
        exit 1;
    fi

    readonly SUB_COMMAND=("$@")
}

# -- boilerplate code below  -- #

exec 3>&1

main() {
    parse_opts "$@"
    set_default_config

    run
}

read_default_config() {
    configuration | awk '/[[:alnum:]_ *= *.*]/{ print "[[ -v " $1 " ]] || readonly " $1 $2 "\x27" $3 "\x27" }'
}

set_default_config() {
    local vars=$(read_default_config)
    eval "$vars"
}

subst_vars() {
    export VARIABLE
    envsubst '$HOME'
}

about() {
    set_default_config
    subst_vars
}

usage() {
    sed '/^### SYNOPSIS$/,/^###/!d;//d;s/^## \{0,6\}//' "$0" | about
}

version() {
    sed '/^### LICENSE$/,/^###/!d;//d;s/^## \{0,6\}//' "$0" | about
}

help() {
    sed '/^##$/,/^####/!d;//d;s/^##.\{0,2\}//' "$0" | about
}

configuration() {
    sed '/^### CONFIGURATION$/,/^###/!d;//d;s/^## \{0,6\}//' "$0"
}

notify() {
    [[ $(command -v notify-send) ]] || return

    local summary=$1
    local body=$2
    notify-send -a "%program-name%" -t 5000 "$summary" "$body"
}

result() {
    local text=$1
    printf "%s\n" "$1"
}

error() {
    local text=$1
    printf "%s\n" "$1"
} >&2

log() {
    printf "$@"
} >&3

quiet() {
    exec 3>/dev/null
}

COLOR1=$(tput setaf 3)
COLOR2=$(tput setaf 4)
COLOR3=$(tput setaf 2)
NC='\e[0m'

task() {
    log "${COLOR1}> %s${NC}\n" "${1}"
}

content() {
    log "${COLOR2}  > %s${NC}\n" "${1}"
}

summary() {
    log "${COLOR3}> %s${NC}\n" "${1}"
}

logpath() {
    local target=${HOME}/.local/share/My/%program-name%
    mkdir -p "$target"
    result ${target}/$(date -I)
}

main "$@"
