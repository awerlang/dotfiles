#!/bin/bash

target="${HOME}/.local/share/My/boot-svg"
mkdir -p "$target"
path="${target}/$(date -I)"
systemd-analyze plot >"${path}.svg"
xmllint --xpath '*//*[@class="left"]/text()' "${path}.svg" | sort | grep -Eo '^[^ ]+' >"${path}.txt"
xdg-open "${path}.svg"
