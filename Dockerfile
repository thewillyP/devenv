# ------------------------------------------------------------------
# Base image: NVIDIA CUDA with development tools
# ------------------------------------------------------------------
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------
# System packages
# ------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gfortran \
    gfortran-multilib \
    wget \
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
    libopenblas-dev \
    liblapack-dev \
    software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# Install Python 3.13 + pip
# ------------------------------------------------------------------
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.13 \
        python3.13-venv \
        python3.13-dev \
        python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 1 && \
    python3 -m ensurepip --upgrade && \
    python3 -m pip install --upgrade pip setuptools wheel && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# Build MAGMA from source (GPU-enabled)
# ------------------------------------------------------------------
WORKDIR /opt
RUN git clone https://github.com/icl-utk-edu/magma.git magma && \
    cd magma && \
    cp make.inc-examples/make.inc.openblas make.inc && \
    sed -i 's|^OPENBLASDIR.*|OPENBLASDIR = /usr|' make.inc && \
    sed -i 's|^CUDADIR.*|CUDADIR = /usr/local/cuda|' make.inc && \
    make -j$(nproc) && \
    make install prefix=/usr/local/magma

# ------------------------------------------------------------------
# Environment variables for MAGMA
# ------------------------------------------------------------------
ENV MAGMA_HOME=/usr/local/magma
ENV LD_LIBRARY_PATH=$MAGMA_HOME/lib:$LD_LIBRARY_PATH
ENV PATH=$MAGMA_HOME/bin:$PATH

# ------------------------------------------------------------------
# Install AWS CLI and aws-vault
# ------------------------------------------------------------------
RUN gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys A6310ACC4672475C && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    curl -o awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig && \
    gpg --verify awscliv2.sig awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip awscliv2.sig aws

RUN curl -fsSL "https://github.com/99designs/aws-vault/releases/download/v7.2.0/aws-vault-linux-amd64" -o /usr/local/bin/aws-vault \
    && chmod +x /usr/local/bin/aws-vault

# ------------------------------------------------------------------
# SSHD setup
# ------------------------------------------------------------------
RUN mkdir /var/run/sshd

# ------------------------------------------------------------------
# Set bash as default shell
# ------------------------------------------------------------------
SHELL ["/bin/bash", "-c"]

# ------------------------------------------------------------------
# Workdir and Python requirements
# ------------------------------------------------------------------
WORKDIR /workspace
ARG VARIANT
COPY ./requirements-${VARIANT}.txt ./requirements.txt

RUN python3 -m pip install --no-cache-dir -r requirements.txt
