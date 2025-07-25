#!/usr/bin/env bash
# Copyright (c) 2023 b-data GmbH
# Distributed under the terms of the MIT License.

set -e

# Create user's private bin
mkdir -p "$HOME/.local/bin"

# Add own repository as origin
if [ -n "$CODESPACES" ]; then
  OWN_REPOSITORY_URL=${UPSTREAM_REPOSITORY_URL//modular\/modular/$GITHUB_USER\/modular}
else
  if [ -z "$OWN_REPOSITORY_URL" ]; then
    ADD_OWN_REPOSITORY_URL=1
  fi
fi
if git -C "$HOME/projects/modular/modular" remote | grep -q origin ; then
  if [ "$(git -C "$HOME/projects/modular/modular" remote get-url origin)" != "$OWN_REPOSITORY_URL" ]; then
    git -C "$HOME/projects/modular/modular" remote remove origin
  else
    NO_ADD_REMOTE=1
  fi
fi
if [ -z "$NO_ADD_REMOTE" ] && [ -z "$ADD_OWN_REPOSITORY_URL" ]; then
  git -C "$HOME/projects/modular/modular" remote add origin "$OWN_REPOSITORY_URL"
fi

# Set remote-tracking branch to origin
if [ -z "$NO_ADD_REMOTE" ]; then
  if git -C "$HOME/projects/modular/modular" ls-remote --exit-code origin; then
    git -C "$HOME/projects/modular/modular" fetch origin
    git -C "$HOME/projects/modular/modular" branch -u origin/main main
  else
    if [ -z "$ADD_OWN_REPOSITORY_URL" ]; then
      git -C "$HOME/projects/modular/modular" remote remove origin
    fi
    echo
    echo "Please fork the MAX repository"
    echo "  1. Owner: Your GitHub username"
    echo "  2. Repository name: max"
    if [ -n "$ADD_OWN_REPOSITORY_URL" ]; then
      printf "set OWN_REPOSITORY_URL "
    fi
    echo "and rebuild the container."
    echo
    echo "ℹ️ https://github.com/benz0li/mojo-dev-container#prerequisites"
    echo
  fi
fi

# Append the user's pixi bin dir to PATH
if ! grep -q "user's pixi bin dir" "$HOME/.bashrc"; then
  mkdir -p "$HOME/.pixi/bin"
  echo -e echo "\n# Append the user's pixi bin dir to PATH\nif [[ \"\$PATH\" != *\"\$HOME/.pixi/bin\"* ]] ; then\n    PATH=\"\$PATH:\$HOME/.pixi/bin\"\nfi" >> "$HOME/.bashrc"
fi
if ! grep -q "user's pixi bin dir" "$HOME/.zshrc"; then
  mkdir -p "$HOME/.pixi/bin"
  echo -e echo "\n# Append the user's pixi bin dir to PATH\nif [[ \"\$PATH\" != *\"\$HOME/.pixi/bin\"* ]] ; then\n    PATH=\"\$PATH:\$HOME/.pixi/bin\"\nfi" >> "$HOME/.zshrc"
fi

# Prepend the user's private bin to PATH
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
