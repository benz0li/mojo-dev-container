#!/usr/bin/env bash
# Copyright (c) 2023 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# Create user's private bin
mkdir -p "$HOME/.local/bin"

# Add own repository as origin
if [ -n "$CODESPACES" ]; then
  OWN_REPOSITORY_URL=${UPSTREAM_REPOSITORY_URL//modular/$GITHUB_USER}
else
  if [ -z "$OWN_REPOSITORY_URL" ]; then
    ADD_OWN_REPOSITORY_URL=1
  fi
fi
if git -C "$HOME/projects/modular/max" remote | grep -q origin ; then
  if [ "$(git -C "$HOME/projects/modular/max" remote get-url origin)" != "$OWN_REPOSITORY_URL" ]; then
    git -C "$HOME/projects/modular/max" remote remove origin
  else
    NO_ADD_REMOTE=1
  fi
fi
if [ -z "$NO_ADD_REMOTE" ] && [ -z "$ADD_OWN_REPOSITORY_URL" ]; then
  git -C "$HOME/projects/modular/max" remote add origin "$OWN_REPOSITORY_URL"
fi

# Set remote-tracking branch to origin
if [ -z "$NO_ADD_REMOTE" ]; then
  if git -C "$HOME/projects/modular/max" ls-remote --exit-code origin; then
    git -C "$HOME/projects/modular/max" fetch origin
    git -C "$HOME/projects/modular/max" branch -u origin/main main
  else
    if [ -z "$ADD_OWN_REPOSITORY_URL" ]; then
      git -C "$HOME/projects/modular/max" remote remove origin
    fi
    echo
    echo "Please fork the Mojo repository"
    echo "  1. Owner: Your GitHub username"
    echo "  2. Repository name: mojo"
    if [ -n "$ADD_OWN_REPOSITORY_URL" ]; then
      printf "set OWN_REPOSITORY_URL "
    fi
    echo "and rebuild the container."
    echo
    echo "ℹ️ https://github.com/benz0li/mojo-dev-container#prerequisites"
    echo
  fi
fi

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
