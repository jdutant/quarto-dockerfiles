ARG UBUNTU_VERSION=latest
ARG OS=linux
ARG ARCH=arm64
ARG QUARTO_VERSION=1.3.302
#
#   Installer
#

# Quarto requires glibc, ubuntu much easier than alpine
FROM ubuntu:${UBUNTU_VERSION} as installer
ARG OS
ARG ARCH
ARG QUARTO_VERSION
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dpkg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && curl -o quarto-${OS}-${ARCH}.deb \
        -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-${OS}-${ARCH}.deb \
    && dpkg --add-architecture ${ARCH} \
    && dpkg --install quarto-${OS}-${ARCH}.deb \
    && rm -f quarto-${OS}-${ARCH}.deb

# @TODO? from the installer we only need the folders where docker was installed
# we don't need ca-certificates, curl, dpkg. But we need the symlinks and PATH.

# 
#   Application
#
FROM installer
# install make for tests
RUN apt-get install -y --no-install-recommends \
        make
WORKDIR /data
ENTRYPOINT [ "quarto" ]
