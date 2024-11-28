FROM mambaorg/micromamba:cuda12.4.1-ubuntu22.04@sha256:3d2c726920261b6237acf5dc43f7ad04ef69e7774926135c79ca789d0cbfd9dc

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