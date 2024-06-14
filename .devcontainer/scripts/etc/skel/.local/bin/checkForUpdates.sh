#!/usr/bin/env bash
# Copyright (c) 2023 b-data GmbH.
# Distributed under the terms of the MIT License.

set -e

# Codespace only: Check for Mojo dev container updates
if [ -n "$CODESPACES" ]; then git -C "/workspaces/$RepositoryName" pull -q; fi
