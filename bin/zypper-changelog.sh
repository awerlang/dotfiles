#!/bin/bash

# Original work: https://github.com/bubbleguuum/zypperdiff

# compare changelogs between downloaded rpm packages and installed packages

PKG_CACHE_DIR="${1-.}"
packages=$(find "$PKG_CACHE_DIR" -name '*.rpm' -exec rpm -q --qf '{}\t%{NAME}\t%{SOURCERPM}\t%{SUMMARY}\n' -p '{}' \; \
                | awk -F $'\t' 'BEGIN { OFS = FS } $2~/^lib/ { print $1, "~" $2, $3, $4; next; } { print $0 }' \
                | LC_ALL=C sort -t $'\t' -k2,2 \
                | sort -s -t $'\t' -k3,3 -u \
                | sort -s -t $'\t' -k2,2 \
                | awk -F $'\t' 'BEGIN { OFS = FS } { print $1, $2, $4 }' \
          )

[[ -z "$packages" ]] && exit

temp_chg=$(mktemp)
temp_diff=$(mktemp)

trap 'rm -f $temp_chg $temp_diff' EXIT

pkg_sep=$(printf '=%.0s' {1..72})

while IFS=$'\t' read -r filename package summary; do
    package="${package#'~'}"
    if rpm -q --changelog "$package" >"$temp_chg"; then
        temp_pkg_diff=$(rpm -q --changelog -p "$filename" | diff --unchanged-line-format= --old-line-format= --new-line-format='%L' "$temp_chg" -)
        [[ -n "$temp_pkg_diff" ]] || temp_pkg_diff='No new changelogs for this package'
    else
        temp_pkg_diff='Package not yet installed'
    fi

    printf '%s\n%s: %s\n%s\n\n%s\n\n' "$pkg_sep" "$package" "$summary" "$pkg_sep" "$temp_pkg_diff" >>"$temp_diff"
done <<<"$packages"

# display diff using PAGER

if [[ -s "$temp_diff" ]]; then
    "${PAGER-less}" "$temp_diff"
fi
