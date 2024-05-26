ARG BUILD_ON_IMAGE=glcr.b-data.ch/mojo/base
ARG MOJO_VERSION=nightly
ARG MOJO_REPOSITORY=https://github.com/modularml/mojo.git
ARG LLVM_VERSION

FROM ${BUILD_ON_IMAGE}:${MOJO_VERSION} as mojo

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG LLVM_VERSION

ENV PARENT_IMAGE=${BUILD_ON_IMAGE}:${MOJO_VERSION} \
    PARENT_IMAGE_BUILD_DATE=${BUILD_DATE} \
    LLVM_VERSION=${LLVM_VERSION}

ENV PATH=${LLVM_VERSION:+/usr/lib/llvm-}${LLVM_VERSION}${LLVM_VERSION:+/bin:}$PATH

RUN dpkgArch="$(dpkg --print-architecture)" \
  ## Ensure that common CA certificates
  ## and OpenSSL libraries are up to date
  && apt-get update \
  && apt-get -y install --no-install-recommends --only-upgrade \
    ca-certificates \
    openssl \
## Install Modular
  && apt-get -y install --no-install-recommends \
    apt-transport-https \
  && curl -s https://dl.modular.com/public/installer/setup.deb.sh | bash - \
  && apt-get -y install --no-install-recommends \
    modular \
  && if [ "$MOJO_VERSION" = "nightly" ]; then \
    ## Update Mojo nightly
    modular update nightly/mojo; \
  fi \
  ## Clean up
  && rm -rf /root/.cache \
    /root/.ipython \
    /root/.lldb \
    /root/.local \
## Install tools for buildig and testing the Mojo standard library
  && if [ -n "$LLVM_VERSION" ]; then \
    ## Install LLVM
    apt-get -y install --no-install-recommends \
      lsb-release \
      software-properties-common; \
    curl -sSLO https://apt.llvm.org/llvm.sh; \
    chmod +x llvm.sh; \
    ./llvm.sh "$LLVM_VERSION"; \
    ## Clean up
    rm -rf llvm.sh \
      /root/.ssh \
      /root/.wget-hsts; \
  else \
    ## Install FileCheck
    apt-get -y install --no-install-recommends llvm-14-tools; \
    cp -a /usr/lib/llvm-14/bin/FileCheck /usr/local/bin/FileCheck; \
    ## Clean up
    apt-get -y purge llvm-14-tools; \
    apt-get -y autoremove; \
  fi \
  ## Install lit
  && pip install --no-cache-dir lit \
  ## Install pre-commit
  && pip install --no-cache-dir pre-commit \
## Dev Container only
  ## Install hadolint
  && case "$dpkgArch" in \
    amd64) tarArch="x86_64" ;; \
    arm64) tarArch="arm64" ;; \
    *) echo "error: Architecture $dpkgArch unsupported"; exit 1 ;; \
  esac \
  && apiResponse="$(curl -sSL \
    https://api.github.com/repos/hadolint/hadolint/releases/latest)" \
  && downloadUrl="$(echo "$apiResponse" | grep -e \
    "browser_download_url.*Linux-$tarArch\"" | cut -d : -f 2,3 | tr -d \")" \
  && echo "$downloadUrl" | xargs curl -sSLo /usr/local/bin/hadolint \
  && chmod 755 /usr/local/bin/hadolint \
  ## Create backup of root directory
  && cp -a /root /var/backups \
  ## Clean up
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

FROM ${BUILD_ON_IMAGE}:${MOJO_VERSION} as files

ARG MOJO_VERSION
ARG MOJO_REPOSITORY

RUN mkdir /files

COPY conf/shell /files
COPY scripts /files

  ## Ensure file modes are correct
RUN find /files -type d -exec chmod 755 {} \; \
  && find /files -type f -exec chmod 644 {} \; \
  && find /files/etc/skel/.local/bin -type f -exec chmod 755 {} \; \
  && find /files/usr/local/bin -type f -exec chmod 755 {} \; \
  ## Clone Mojo's repository
  && git clone "$MOJO_REPOSITORY" /files/etc/skel/projects/modularml/mojo \
  && git -C /files/etc/skel/projects/modularml/mojo remote rename origin upstream \
  && if [ "$MOJO_VERSION" = "nightly" ]; then \
    ## Checkout branch nightly
    git -C /files/etc/skel/projects/modularml/mojo checkout nightly; \
  fi \
  ## Install pre-commit
  && pip install --no-cache-dir pre-commit \
  && cd /files/etc/skel/projects/modularml/mojo \
  && pre-commit install \
  ## Clean up
  && rm -rf /root/.cache \
  ## Copy skeleton files for root
  && cp -r /files/etc/skel/. /files/root \
  ## except .bashrc and .profile
  && bash -c 'rm -rf /files/root/{.bashrc,.profile}' \
  && chmod 700 /files/root

FROM docker.io/koalaman/shellcheck:stable as sci

FROM mojo

## Copy files as late as possible to avoid cache busting
COPY --from=files /files /

## Copy shellcheck as late as possible to avoid cache busting
COPY --from=sci --chown=root:root /bin/shellcheck /usr/local/bin

ARG DEBIAN_FRONTEND=noninteractive

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
  ## Update timezone if needed
  && if [ "$TZ" != "Etc/UTC" ]; then \
    echo "Setting TZ to $TZ"; \
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime \
      && echo "$TZ" > /etc/timezone; \
  fi \
  ## Add/Update locale if needed
  && if [ "$LANG" != "en_US.UTF-8" ]; then \
    sed -i "s/# $LANG/$LANG/g" /etc/locale.gen; \
    locale-gen; \
    echo "Setting LANG to $LANG"; \
    update-locale --reset LANG="$LANG"; \
  fi

## Set repository environment variable
ARG MOJO_REPOSITORY

ENV MOJO_REPOSITORY=${MOJO_REPOSITORY}

## Unset environment variable BUILD_DATE
ENV BUILD_DATE=
