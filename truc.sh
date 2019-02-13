#!/bin/sh

echo Downloading...
for i in {1..5}; do
    rm -f "$1"
    /usr/bin/curl -fLC - --retry 5 --retry-delay 3 -A Mozilla -o "$1" "$2"
    echo Checking...
    unzip -tq "$1" && break
done
