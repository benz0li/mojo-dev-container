#!/usr/bin/env bash
# Copyright (c) 2024 b-data GmbH
# Distributed under the terms of the MIT License.

set -e

# MAX SDK: Evaluate and set version
if [ -n "$CODESPACES" ]; then
  extDataDir=$HOME/.vscode-remote/data/User/globalStorage/modular-mojotools.vscode-mojo-nightly
else
  extDataDir=$HOME/.vscode-server/data/User/globalStorage/modular-mojotools.vscode-mojo-nightly
fi
while :
  do
  extDirs=( "$HOME"/.vscode-*/extensions/modular-mojotools.vscode-mojo-nightly* )
  [ "${#extDirs[@]}" -ge 2 ] && exit 1
  if [ -d "${extDirs[0]}" ]; then
    sdkVersion=$(jq -r '.sdkVersion' "${extDirs[0]}/package.json")
    break
  else
    sleep 1
  fi
done

# MAX SDK: Create symlink to /opt/modular
mkdir -p "$extDataDir/magic-data-home/envs"
ln -snf /opt/modular "$extDataDir/magic-data-home/envs/max"
mkdir -p "$extDataDir/versionDone/$sdkVersion"
