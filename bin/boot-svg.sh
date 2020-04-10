#!/bin/bash
path="${1%.txt}"
xmllint --xpath '*//*[@class="left"]/text()' "${path}.svg" | sort | grep -Eo '^[^ ]+' >"${path}.txt"
