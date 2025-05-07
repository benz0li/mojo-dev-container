# Mojo dev container

<!-- markdownlint-disable line-length -->
[![minimal-readme compliant](https://img.shields.io/badge/readme%20style-minimal-brightgreen.svg)](https://github.com/RichardLitt/standard-readme/blob/main/example-readmes/minimal-readme.md) [![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active) <a href="https://liberapay.com/benz0li/donate"><img src="https://liberapay.com/assets/widgets/donate.svg" alt="Donate using Liberapay" height="20"></a> <a href='https://codespaces.new/benz0li/mojo-dev-container?hide_repo_select=true&ref=main'><img src='https://github.com/codespaces/badge.svg' alt='Open in GitHub Codespaces' height="20" style='max-width: 100%;'></a>
<!-- markdownlint-enable line-length -->

Multi-arch (`linux/amd64`, `linux/arm64/v8`) Mojo dev container.  
🔥 All [prerequisites](https://github.com/modular/modular/blob/main/mojo/stdlib/docs/development.md#prerequisites)
installed for Mojo standard library development.

Parent image: [`glcr.b-data.ch/mojo/base:nightly`](https://github.com/b-data/mojo-docker-stack)

<details><summary><b>Features</b></summary>
<p>

* **Git**: A distributed version-control system for tracking changes in source
  code.
* **Git LFS**: A Git extension for versioning large files.
* **LLVM** (optional, installed): A collection of modular and reusable compiler
  and toolchain technologies.
* **Mojo (nightly)**: A programming language for AI developers.
* **Pandoc**: A universal markup converter.
* **Python**: An interpreted, object-oriented, high-level programming language
  with dynamic semantics.
* **Zsh**: A shell designed for interactive use, although it is also a powerful
  scripting language.

</p>
</details>

:information_source: Regading [Magic](https://docs.modular.com/magic/), see
issue <https://github.com/benz0li/mojo-dev-container/issues/2>.

<details><summary><b>Pre-installed extensions</b></summary>
<p>

<!-- markdownlint-disable line-length -->
* [Black Formatter](https://marketplace.visualstudio.com/items?itemName=ms-python.black-formatter)
* [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
* [EditorConfig for VS Code](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
* [Git Graph](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph)
* [GitHub Actions](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-github-actions)
* [GitHub Pull Requests and Issues](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-pull-request-github)
* [GitLens — Git supercharged](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)  
  ℹ️ Pinned to version 11.7.0 due to unsolicited AI content
* [hadolint](https://marketplace.visualstudio.com/items?itemName=exiasr.hadolint)
* [Jupyter](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)
* [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
* [Mojo 🔥 (nightly)](https://marketplace.visualstudio.com/items?itemName=modular-mojotools.vscode-mojo-nightly)
* [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
* [Resource Monitor](https://marketplace.visualstudio.com/items?itemName=mutantdino.resourcemonitor)
* [ShellCheck](https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck)
* [YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
<!-- markdownlint-enable line-length -->

</p>
</details>

## Table of Contents

* [Prerequisites](#prerequisites)
* [Install](#install)
* [Usage](#usage)
* [Similar project](#similar-project)
* [Contributing](#contributing)
* [License](#license)

## Prerequisites

[A fork of the MAX repository](https://github.com/modular/modular/fork):

1. Owner: Your GitHub username
2. Repository name: max

Local: Dev containers require VS Code and either Docker or Podman to be
installed.

Web: Codespaces require no installation.

## Install

### VS Code

[Set up Visual Studio Code](https://code.visualstudio.com/docs/setup/setup-overview)
and install the [Remote Development Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack).

### Docker

See [Install Docker Engine | Docker Docs](https://docs.docker.com/engine/install).

* Docker CE: [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

### Podman

See [Podman Installation | Podman](https://podman.io/docs/installation).

## Usage

The Mojo dev container is not intended for work on this repository, but rather
for [Mojo standard library development](https://github.com/modular/modular/blob/main/mojo/stdlib/docs/development.md).

Everything is pre-installed – no Magic required. Just execute a task's shell
command in the terminal:

* build: `./stdlib/scripts/build-stdlib.sh`
* tests: `./stdlib/scripts/run-tests.sh`
* examples: `../examples/mojo/run-examples.sh`
* benchmarks: `./stdlib/scripts/run-benchmarks.sh`

For this, the dev container is set up in a unique way:

1. Default mount:
    * source: empty directory
    * target: `/home/vscode`
    * type: volume
1. Codespace only mount:
    * source: root of this repository
    * target: `/workspaces`
    * type: misc
1. Default path: `/home/vscode/projects/modular/modular/mojo`
    * Repository: <https://github.com/modular/modular.git>
    * Branch: main
1. Default user: `vscode`
    * uid: 1000 (auto-assigned)
    * gid: 1000 (auto-assigned)
1. Lifecycle scripts:
    * [`onCreateCommand`](.devcontainer/scripts/usr/local/bin/onCreateCommand.sh):
      home directory setup
    * [`postStartCommand`](.devcontainer/scripts/etc/skel/.local/bin/dockerSystemPrune.sh):
      Codespace only: Silently remove all unused images and all build cache
    * [`postAttachCommand`](.devcontainer/scripts/etc/skel/.local/bin/checkForUpdates.sh):
      Codespace only: Check for dev container updates

To disable the `postStartCommand` or `postAttachCommand`, comment out line 8 in
`~/.local/bin/dockerSystemPrune.sh` or `~/.local/bin/checkForUpdates.sh`.  

### Codespace

1. Click the **`<> Code`** button, then click the **Codespaces** tab.  
   A message is displayed at the bottom of the dialog telling you who will pay
   for the codespace.
1. Create your codespace after configuring advanced options:
    * **Configure advanced options**  
      To configure advanced options for your codespace, such as a different
      machine type or a particular `devcontainer.json` file:
        * At the top right of the **Codespaces** tab, select **`...`** and click
          **New with options...**.
        * On the options page for your codespace, choose your preferred options
          from the dropdown menus.
        * Click **Create codespace**.

– [Creating a codespace for a repository - GitHub Docs](https://docs.github.com/en/codespaces/developing-in-codespaces/creating-a-codespace-for-a-repository#creating-a-codespace-for-a-repository)

### Local/'Remote SSH'

Set `OWN_REPOSITORY_URL` in [devcontainer.json](.devcontainer/devcontainer.json).

Use the **Dev Containers: Reopen in Container** command from the Command Palette
(`F1`, `⇧⌘P` (Windows, Linux `Ctrl+Shift+P`))

ℹ️ For further information, see
[Developing inside a Container using Visual Studio Code Remote Development](https://code.visualstudio.com/docs/devcontainers/containers).

### Persistence

Data in the following locations is persisted:

1. The user's home directory (`/home/vscode`)[^1]
1. The dev container's workspace (`/workspaces`)

[^1]: Alternatively for the root user (`/root`). Use with Docker/Podman in
*rootless mode*.

This is accomplished via a *volume* (or *loop device* on Codespaces) and is
preconfigured.

| **Codespaces: A 'Full Rebuild Container' resets the home directory!**<br>ℹ️ This is never necessary unless you want exactly that. |
|:----------------------------------------------------------------------------------------------------------------------------------|

## Similar project

* [modular/modular](https://github.com/modular/modular/tree/main/examples)

What makes this project different:

1. Multi-arch: `linux/amd64`, `linux/arm64/v8`  
   ℹ️ Runs on Apple M series using Docker Desktop.
1. Base image: [Debian](https://hub.docker.com/_/debian) instead of
   [Ubuntu](https://hub.docker.com/_/ubuntu)
1. Just Python – no [Conda](https://github.com/conda/conda) /
   [Mamba](https://github.com/mamba-org/mamba)

## Contributing

PRs accepted.

This project follows the
[Contributor Covenant](https://www.contributor-covenant.org)
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

Copyright © 2024 Olivier Benz

Distributed under the terms of the [MIT License](LICENSE).
