#!/usr/bin/env bash

mkdir -p  ~/.config/opencode/
cp /workspace/.devcontainer/opencode.jsonc  ~/.config/opencode/opencode.jsonc

while IFS= read -r name; do
    if printenv "$name" >/dev/null 2>&1; then
        printf 'SET     %s\n' "$name"
    else
        printf 'MISSING %s\n' "$name"
    fi
done < <(
    grep -oP '\{env:\K\w+(?=\})' \
        "$HOME/.config/opencode/opencode.jsonc" |
    sort -u
)
