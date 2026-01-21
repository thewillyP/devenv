FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim@sha256:f106758c361464e22aa1946c1338ae94de22ec784943494f26485d345dac2d85

ENV UV_COMPILE_BYTECODE=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    dropbear \
    apt-utils \
    bash \
    build-essential \
    ca-certificates \
    curl \
    wget \
    git \
    nano \
    zip \
    unzip \
    net-tools \
    dnsutils \
    htop \
    lsof \
    strace \
    man \
    graphviz \
    pandoc \
    swig \
    gnupg \
    less \
    pinentry-curses \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys A6310ACC4672475C && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    curl -o awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig && \
    gpg --verify awscliv2.sig awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip awscliv2.sig aws

RUN curl -fsSL "https://github.com/99designs/aws-vault/releases/download/v7.2.0/aws-vault-linux-amd64" -o /usr/local/bin/aws-vault \
    && chmod +x /usr/local/bin/aws-vault

SHELL ["/bin/bash", "-c"]

WORKDIR /workspace

ARG VARIANT
COPY ./requirements-${VARIANT}.txt ./requirements.txt

RUN uv pip install --system --no-cache -r requirements.txt
