FROM mambaorg/micromamba:ubuntu22.04@sha256:46420ba0d87aaa518ca2a70df2c33f26994e3f34b55af2d3e0583e4aa237f55c

# NECESSARY for mamba images
USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    openssh-server \
    apt-utils \
    bash \
    build-essential \
    ca-certificates \
    curl \
    wget \
    git \
    nano \
    zip \
    net-tools \
    dnsutils \
    htop \
    lsof \
    strace \
    man \
    graphviz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

WORKDIR /workspace

COPY ./environment.yml .

RUN micromamba create -f environment.yml && micromamba clean --all --yes