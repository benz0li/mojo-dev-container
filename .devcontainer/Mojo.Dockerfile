ARG BUILD_ON_IMAGE=glcr.b-data.ch/mojo/base
ARG MOJO_VERSION=nightly
ARG UPSTREAM_REPOSITORY_URL=https://github.com/modular/modular.git

FROM ${BUILD_ON_IMAGE}:${MOJO_VERSION} as mojo

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${MOJO_VERSION} \
    PARENT_IMAGE_BUILD_DATE=${BUILD_DATE}

RUN dpkgArch="$(dpkg --print-architecture)" \
  ## Add user to group users
  && sed -i- "s/users:x:100:/users:x:100:vscode/g" /etc/group \
  ## Ensure that common CA certificates
  ## and OpenSSL libraries are up to date
  && apt-get update \
  && apt-get -y install --no-install-recommends --only-upgrade \
    ca-certificates \
    openssl \
## Install tools for buildig and testing the Mojo standard library
  && apt-get -y install --no-install-recommends \
    lsb-release \
    software-properties-common \
  ## Install pre-commit
  && pip install --no-cache-dir pre-commit \
## Dev container only
  ## Create backup of root directory
  && cp -a /root /var/backups \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

FROM ${BUILD_ON_IMAGE}:${MOJO_VERSION} as files

ARG MOJO_VERSION
ARG UPSTREAM_REPOSITORY_URL

RUN mkdir /files

COPY conf/shell /files
COPY vsix /files
COPY scripts /files

  ## Ensure file modes are correct
RUN find /files -type d -exec chmod 755 {} \; \
  && find /files -type f -exec chmod 644 {} \; \
  && find /files/etc/skel/.local/bin -type f -exec chmod 755 {} \; \
  && find /files/usr/local/bin -type f -exec chmod 755 {} \; \
  ## Clone Mojo's repository
  && git clone "$UPSTREAM_REPOSITORY_URL" /files/etc/skel/projects/modular/modular \
  && git -C /files/etc/skel/projects/modular/modular remote rename origin upstream \
  ## Install pre-commit
  && pip install --no-cache-dir pre-commit \
  && cd /files/etc/skel/projects/modular/modular \
  && pre-commit install \
  ## Clean up
  && rm -rf /root/.cache \
  ## Copy skeleton files for root
  && cp -r /files/etc/skel/. /files/root \
  ## except .bashrc and .profile
  && bash -c 'rm -rf /files/root/{.bashrc,.profile}' \
  && chmod 700 /files/root

FROM ghcr.io/hadolint/hadolint:latest as hsi

FROM docker.io/koalaman/shellcheck:stable as sci

FROM mojo

## Copy files as late as possible to avoid cache busting
COPY --from=files /files /

## Copy binaries as late as possible to avoid cache busting
## Install Haskell Dockerfile Linter
COPY --from=hsi /bin/hadolint /usr/local/bin
## Install ShellCheck
COPY --from=sci --chown=root:root /bin/shellcheck /usr/local/bin

ARG DEBIAN_FRONTEND=noninteractive

## Update Modular settings
ARG MODULAR_TELEMETRY_ENABLE
ARG MODULAR_CRASHREPORTING_ENABLE

RUN if [ -n "$MODULAR_TELEMETRY_ENABLE" ]; then \
    ## Enable telemetry
    sed -i '/[Tt]elemetry/!b;n;cenabled = true' "$MODULAR_HOME/modular.cfg"; \
  fi \
  && if [ -n "$MODULAR_CRASHREPORTING_ENABLE" ]; then \
    ## Enable crash reporting
    sed -i '/[Cc]rash/!b;n;cenabled = true' "$MODULAR_HOME/modular.cfg"; \
  fi

## Update environment
ARG USE_ZSH_FOR_ROOT
ARG LANG
ARG TZ

ARG LANG_OVERRIDE=${LANG}
ARG TZ_OVERRIDE=${TZ}

ENV LANG=${LANG_OVERRIDE:-$LANG} \
    TZ=${TZ_OVERRIDE:-$TZ}

  ## Change root's shell to ZSH
RUN if [ -n "$USE_ZSH_FOR_ROOT" ]; then \
    chsh -s /bin/zsh; \
  fi \
  ## Info about timezone
  && echo "TZ is set to $TZ" \
  ## Add/Update locale if requested
  && if [ "$LANG" != "en_US.UTF-8" ]; then \
    sed -i "s/# $LANG/$LANG/g" /etc/locale.gen; \
    locale-gen; \
  fi \
  && update-locale --reset LANG="$LANG" \
  ## Info about locale
  && echo "LANG is set to $LANG"

## Set repository environment variable
ARG UPSTREAM_REPOSITORY_URL

ENV UPSTREAM_REPOSITORY_URL=${UPSTREAM_REPOSITORY_URL}

## Unset environment variable BUILD_DATE
ENV BUILD_DATE=
