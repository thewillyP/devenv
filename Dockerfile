# ------------------------------------------------------------------
# Base image: NVIDIA CUDA with development tools (so we have nvcc)
# ------------------------------------------------------------------
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# ------------------------------------------------------------------
# Preserve your UV env variable
# ------------------------------------------------------------------
ENV UV_COMPILE_BYTECODE=1

# ------------------------------------------------------------------
# System packages and original libraries
# ------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# CUDA setup is already provided by NVIDIA image, no need to add keyring manually
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Build MAGMA from source (GPU-enabled)
# ------------------------------------------------------------------
WORKDIR /opt
RUN git clone https://github.com/icl-utk-edu/magma.git magma && \
    cd magma && \
    cp make.inc-examples/make.inc.mkl-gcc make.inc && \
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
# Install AWS CLI and aws-vault (from your original Dockerfile)
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
# Workdir and Python requirements via uv
# ------------------------------------------------------------------
WORKDIR /workspace
ARG VARIANT
COPY ./requirements-${VARIANT}.txt ./requirements.txt

# Install uv if missing (NVIDIA image does not include uv)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Python dependencies using uv
RUN uv pip install --system --no-cache -r requirements.txt

# ------------------------------------------------------------------
# Default command
# ------------------------------------------------------------------
CMD ["bash"]
