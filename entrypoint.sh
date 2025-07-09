#!/bin/bash
set -euo pipefail

BASHRC="${HOME}/.bashrc"
DOCKER_SOURCE='source /.singularity.d/env/10-docker2singularity.sh'
LIB_EXPORT='export LD_LIBRARY_PATH="/.singularity.d/libs"'

# Create .bashrc if it doesn't exist
[ -f "$BASHRC" ] || touch "$BASHRC"

# Add docker2singularity source line if not already present
grep -qxF "$DOCKER_SOURCE" "$BASHRC" || echo "$DOCKER_SOURCE" >> "$BASHRC"

# Add LD_LIBRARY_PATH export if not already present
grep -qxF "$LIB_EXPORT" "$BASHRC" || echo "$LIB_EXPORT" >> "$BASHRC"

# Source .bashrc to apply changes in the current session
source "$BASHRC"

# Launch Jupyter notebook
mkdir -p "${HOME}/notebooks"
jupyter lab --notebook-dir="${HOME}/notebooks" --ip="0.0.0.0" --port=8888 --no-browser &

### SSH Server
# BIG: ASSUMES YOU OVERLAY THE $USER'S .ssh folder into the container. WILL NOT WORK IF YOU DON'T
# 1. add machines preexisting key to its own authorized, no-password access list
# Why: If I overlay my .ssh/, the container inherits the user's no-password access list, tricking sshd to not need password
# How: This only needs to be run once, but want idempotency so do if-else check
grep -qxFf ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys || cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
# 2. Dynamically generate sshd keys for the ssh server
mkdir -p ~/hostkeys
ssh-keygen -q -N "" -t rsa -b 4096 -f ~/hostkeys/ssh_host_rsa_key <<< y
exec /usr/sbin/sshd -D -p 2222 \
  -o PermitUserEnvironment=yes \
  -o PermitTTY=yes \
  -o X11Forwarding=yes \
  -o AllowTcpForwarding=yes \
  -o GatewayPorts=yes \
  -o ForceCommand=/bin/bash \
  -o UsePAM=no \
  -h ~/hostkeys/ssh_host_rsa_key
