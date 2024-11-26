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

cd $HOME
grep -qxFf .ssh/id_rsa.pub .ssh/authorized_keys || cat .ssh/id_rsa.pub >> .ssh/authorized_keys
[ ! -f images/oho_mamba.sif ] && singularity build images/oho_mamba.sif docker://thewillyp/oho:mamba-jammy-cuda-12.4.1
singularity exec --nv --containall --no-home \
--overlay /scratch/wlp9800/oho-mamba.ext3:rw \
--bind /home/wlp9800/.ssh,/home/wlp9800/dev:/workspace \
images/oho_mamba.sif bash -c \
'mkdir -p /home/wlp9800/hostkeys && \
ssh-keygen -q -N "" -t rsa -b 4096 -f /home/wlp9800/hostkeys/ssh_host_rsa_key <<< y && \
echo "if [ -d /.singularity.d/env ]; then
  for i in /.singularity.d/env/*.sh; do
    if [ -r \$i ]; then
      . \$i
    fi
  done
  unset i
fi" >> ~/.bashrc && \
/usr/sbin/sshd -D -p 2222 -o UsePAM=no -h /home/wlp9800/hostkeys/ssh_host_rsa_key'

