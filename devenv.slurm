#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=12G
#SBATCH --time=06:00:00
#SBATCH --job-name=devenv
#SBATCH --error=devenv_err.
#SBATCH --output=devenv.log
#SBATCH --gres=gpu:0
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=BEGIN
#SBATCH --mail-user=wlp9800@nyu.edu

USER=wlp9800
IMAGE=devenv
DOCKER_URL=docker://thewillyp/oho@sha256:c63e8c3cf3e3f4ea4d4aef514c869dc863e4a3e7cf84a678325c0271e034c8ff
SAVE_DIR="/scratch/${USER}/"
OVERLAY_TYPE="overlay-15GB-500K.ext3"


# Check if the file already exists
# https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/singularity-with-miniconda?authuser=0
if [ ! -f "${SAVE_DIR}${IMAGE}.ext3" ]; then
    cp -rp /scratch/work/public/overlay-fs-ext3/${OVERLAY_TYPE}.gz "${SAVE_DIR}${IMAGE}.ext3.gz"
    gunzip "${SAVE_DIR}${IMAGE}.ext3.gz"
else
    echo "File $OVERLAY_TYPE already exists in $SAVE_DIR."
fi

# Build image
[ ! -f /scratch/${USER}/images/${IMAGE}.sif ] && \
singularity build /scratch/${USER}/images/${IMAGE}.sif ${DOCKER_URL}  # check exist in my cache, else build

# 1. check if key exist 
# 2. trust our own key 
# 3. then will copy this key into container through overlay, makes container trust our key. No need to rebuild docker with key injected bc inject w/ overlay
# 4. let's us jump from greene -> container w/ no password
grep -qxFf $HOME/.ssh/id_rsa.pub $HOME/.ssh/authorized_keys || cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys  # 1. 2.

singularity exec --nv --containall --no-home \
--overlay ${SAVE_DIR}${IMAGE}.ext3:rw \
--bind /home/${USER}/.ssh,/home/${USER}/dev \  # 3.
/scratch/${USER}/images/${IMAGE}.sif bash -c \
'mkdir -p /home/${USER}/hostkeys && \
ssh-keygen -q -N "" -t rsa -b 4096 -f /home/${USER}/hostkeys/ssh_host_rsa_key <<< y && \  # server needs new key initialized
/usr/sbin/sshd -D -p 2222 -o UsePAM=no -h /home/${USER}/hostkeys/ssh_host_rsa_key  && \  # 4.
if ! grep -q "source /.singularity.d/env/10-docker2singularity.sh" ~/.bashrc; then \
    echo "source /.singularity.d/env/10-docker2singularity.sh" >> ~/.bashrc; \
fi" >> ~/.bashrc'

