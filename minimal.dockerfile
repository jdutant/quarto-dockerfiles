ARG UBUNTU_VERSION=latest
ARG QUARTO_VERSION=1.3.302
#
#   Installer
#

# Quarto requires glibc, ubuntu much easier than alpine
FROM ubuntu:${UBUNTU_VERSION} as installer
ARG TARGETARCH
ARG TARGETOS
ARG QUARTO_VERSION
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dpkg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && curl -o quarto-$(TARGETOS)-$(TARGETARCH).deb \
        -L https://github.com/quarto-dev/quarto-cli/releases/download/v$(QUARTO_VERSION)/quarto-$(QUARTO_VERSION)-$(TARGETOS)-$(TARGETARCH).deb \
    && dpkg --add-architecture $(TARGETARCH) \
    && dpkg --install quarto-$(TARGETOS)-$(TARGETARCH).deb \
    && rm -f quarto-$(TARGETOS)-$(TARGETARCH).deb

# @TODO? from the installer we only need the folders where docker was installed
# we don't need ca-certificates, curl, dpkg. But we need the symlinks and PATH.

# 
#   Application
#
FROM installer
# install make for tests
RUN apt-get update && apt-get install -y --no-install-recommends \
        make \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /data
ENTRYPOINT [ "quarto" ]
