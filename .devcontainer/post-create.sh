#!/usr/bin/env bash

set -euo pipefail

echo "Installing dependencies..."

# Install curl and jq
sudo apt-get update
sudo apt-get install -y curl jq

echo "Installing APM..."
curl -sSL https://aka.ms/apm-unix | sh

echo "Installing OpenCode..."
curl -fsSL https://opencode.ai/install | bash

echo "Installing PI..."
curl -fsSL https://pi.dev/install.sh | sh

echo "Installing RTK..."
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
rtk init -g
