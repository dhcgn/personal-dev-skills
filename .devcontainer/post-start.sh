#!/usr/bin/env bash

mkdir -p  ~/.config/opencode/
cp /workspace/.devcontainer/opencode.jsonc  ~/.config/opencode/opencode.jsonc

while IFS= read -r name; do
    if value=$(printenv "$name" 2>/dev/null); then
        printf 'SET     %s = %s\n' "$name" "$value"
    else
        printf 'MISSING %s\n' "$name"
    fi
done < <(
    grep -oP '\{env:\K\w+(?=\})' \
        "$HOME/.config/opencode/opencode.jsonc" |
    sort -u
)

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

rtk init -g 