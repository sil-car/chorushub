#!/usr/bin/env bash

port=5913

mkdir -p ~/ChorusHub
cd ~/ChorusHub || exit 1

# Ensure hg repo.
if [[ ! -d ./.hg ]]; then
    hg init
fi

hg serve -A accessLog.txt -E log.txt -p "$port" --verbose
