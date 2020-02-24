#!/bin/bash
xmllint --xpath '*//*[@class="left"]/text()' $1.svg | sort | grep -Eo '^[^ ]+' > $1.txt
