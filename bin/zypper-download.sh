#!/bin/bash
#####################################################################################################
##
### NAME
##      zypper-download - Downloads packages using any amount of available openSUSE mirrors.
##
### SYNOPSIS
##      Usage: zypper-download.sh [options] command [command-args]...
##
##      Options:
##
##          -d <dir>        Package cache directory. It can be an absolute path or relative to the
##                              current directory, or start with the environment variable ${HOME}.
##                              Default: $PKG_CACHE_DIR
##          -z              Run zypper once packages are ready in cache.
##          -c              Display default configuration.
##          -h              Display this message and exit.
##          -v              Display version information and exit.
##
##      Commands:
##
##          dup, dist-upgrade
##          in,  install package-name...
##          inr, install-new-recommends
##
### CONFIGURATION
##      PKG_CACHE_DIR       = ${HOME}/.cache/zypp/packages
##      RUN_ZYPPER          = no
##
### LICENSE
##      zypper-download v0.1
##
##      Copyright (C) 2020 André Werlang
##
##      License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
##      This is free software: you are free to change and redistribute it.
##      There is NO WARRANTY, to the extent permitted by law.
##
#####################################################################################################

set -o errexit -o nounset -o noclobber -o pipefail
shopt -s nullglob

function main () {
    parse_opts "$@"
    set_default_config

    run
}

function error () {
    echo "$0: $*"
} 1>&2

function parse_opts () {
    local OPTIND OPTARG flag
    while getopts hvczd: flag
    do
        case "$flag" in
        (h) help; exit 0;;
        (v) version; exit 0;;
        (c) configuration | about; exit 0;;
        (d) readonly PKG_CACHE_DIR="$OPTARG";;
        (z) readonly RUN_ZYPPER="yes";;
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

function read_default_config () {
    configuration | awk '/[[:alnum:]_ *= *.*]/{ print "[[ -v " $1 " ]] || readonly " $1 $2 "\x27" $3 "\x27" }'
}

function set_default_config () {
    local vars=$(read_default_config)
    eval "$vars"
}

function subst_vars () {
    export PKG_CACHE_DIR
    envsubst '$HOME $PKG_CACHE_DIR'
}

function about () {
    set_default_config
    subst_vars
}

function usage () {
    sed '/^### SYNOPSIS$/,/^###/!d;//d;s/^## \{0,6\}//' "$0" | about
}

function version () {
    sed '/^### LICENSE$/,/^###/!d;//d;s/^## \{0,6\}//' "$0" | about
}

function help () {
    sed '/^##$/,/^####/!d;//d;s/^##.\{0,2\}//' "$0" | about
}

function configuration () {
    sed '/^### CONFIGURATION$/,/^###/!d;//d;s/^## \{0,6\}//' "$0"
}

function package_dir () {
    echo "$PKG_CACHE_DIR" | subst_vars
}

function run () {
    call_zypper "${SUB_COMMAND[@]}" \
        | create_download_spec \
        | download_all

    check_rpm

    if [[ "$RUN_ZYPPER" == yes ]]; then
        local dir=$(package_dir)
        sudo zypper --pkg-cache-dir "$dir" "${SUB_COMMAND[@]}"
    fi
}

function call_zypper () {
    local command="$1"
    local command_args=("${@:2}")

    sudo zypper --quiet \
                --terse \
                --non-interactive \
                "$command" --details \
                           --dry-run \
                "${command_args[@]}"
}

function create_download_spec () {
    local repo_arrays=$(zypper repos --uri | awk -F "|" '
        function trim(s) {
            gsub(/^ +| +$/, "", s);
            return s;
        }
        BEGIN {
            print "BEGIN {";
        }
        /^[0-9]/ {
            alias=trim($2);
            name=trim($3);
            uri=trim($NF);
            print "    uri[\"" name "\"]=\"" uri "\";";
            print "    alias[\"" name "\"]=\"" alias "\";";
        }
        END {
            print "}";
        }
        '
    )

    awk -v PKG_CACHE_DIR="$PKG_CACHE_DIR" "$repo_arrays"'
        function trim(s) {
            gsub(/^ +| +$/, "", s);
            return s;
        }
        NF==0 {
            pkg=0;
            next;
        }
        / packages? (is|are) going to be (installed|upgraded):$/ {
            pkg=1;
            next;
        }
        pkg==1 {
            name=$1;        getline;
            version=$NF;    getline;
            arch=$1;        getline;
            repo=trim($0);  getline;
            print uri[repo] "/" arch "/" name "-" version "." arch ".rpm";
            print "  dir=" PKG_CACHE_DIR "/" alias[repo] "/" arch;
        }
        ' -
}

function download_all () {
    aria2c --input-file=- \
           --max-connection-per-server=10 \
           --split=16 \
           --min-split-size=1M \
           --check-integrity=true \
           --allow-overwrite=true \
           --auto-file-renaming=false \
           --continue=true
}

function check_rpm () {
    local dir=$(package_dir)
    find "$dir" -type f -name "*.rpm" -print0 | xargs -0 rpm --checksig
}

main "$@"
