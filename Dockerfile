FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim@sha256:f106758c361464e22aa1946c1338ae94de22ec784943494f26485d345dac2d85

ENV UV_COMPILE_BYTECODE=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    rm cuda-keyring_1.1-1_all.deb && \
    apt-get update

RUN echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server \
    apt-utils \
    bash \
    build-essential \
    ca-certificates \
    curl \
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
    libmagma2 \
    libmagma-dev \
    libmagma-sparse2 \
    libmagma-test \
    libmagma-doc \
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

RUN mkdir /var/run/sshd

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

WORKDIR /workspace

# Use build argument to select the correct requirements file
ARG VARIANT
COPY ./requirements-${VARIANT}.txt ./requirements.txt

RUN uv pip install --system --no-cache -r requirements.txt
