#!/usr/bin/env bash
# Copyright (c) 2023 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

mkdir -p "$HOME/.local/bin"

# If existent, prepend the user's private bin to PATH
if ! grep -q "user's private bin" "$HOME/.bashrc"; then
  cat "/var/tmp/snippets/rc.sh" >> "$HOME/.bashrc"
fi
if ! grep -q "user's private bin" "$HOME/.zshrc"; then
  cat "/var/tmp/snippets/rc.sh" >> "$HOME/.zshrc"
fi

# Enable Oh My Zsh plugins
sed -i "s/plugins=(git)/plugins=(docker docker-compose git git-lfs pip screen tmux vscode)/g" \
  "$HOME/.zshrc"

# Remove old .zcompdump files
rm -f "$HOME"/.zcompdump*
