FROM python@sha256:4efa69bf17cfbd83a9942e60e2642335c3b397448e00410063a0421f9727c4c4

RUN apt update \
    && apt install -y --no-install-recommends \
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
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

# Set bash as the default shell
SHELL ["/bin/bash", "-c"]

WORKDIR /workspace

COPY ./requirements.txt ./

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt