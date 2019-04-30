#!/usr/bin/env bash

readonly FILE=/tmp/pbench.loop.txt

while true; do
    if [[ -f "$FILE" ]]; then
        echo "$FILE exists, sleeping ..."
        sleep 30
    else
        echo "$FILE: not exist, exiting ..."
        break
    fi
done
