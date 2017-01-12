#!/bin/sh

# git-delve files | scripts/extensions.sh
# will show a sorted list of filename extensions

cat $1 | grep '\.' | awk -F "." '{ print $(NF) }' | sort |uniq -c|sort -nr
