FROM ghcr.io/astral-sh/uv:bookworm-slim@sha256:d7dc3a704b9d17030f9d5e979025692cb283880af0335600163bbd99383e234f

ENV UV_COMPILE_BYTECODE=1

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
    pandoc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

WORKDIR /workspace

COPY ./requirements.txt .

RUN uv pip install --system --no-cache -r requirements.txt