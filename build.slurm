#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=14G
#SBATCH --time=00:15:00
#SBATCH --job-name=build
#SBATCH --error=build.err
#SBATCH --output=build.log
#SBATCH --cpus-per-task=10
#SBATCH --mail-type=END
#SBATCH --mail-user=wlp9800@nyu.edu

USER=wlp9800
IMAGE=devenv
DOCKER_URL="docker://thewillyp/${IMAGE}:master-1.0.25-gpu@sha256:d0050f2c8be567eab6fb3bbd534b4cc0cbe6d4cb14e1dac6789d5df6402c0e01"
OVERLAY_TYPE="overlay-15GB-500K.ext3"
SAVE_DIR="/scratch/${USER}/"


# Check if the file already exists
# https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/singularity-with-miniconda?authuser=0
cp -rp /scratch/work/public/overlay-fs-ext3/${OVERLAY_TYPE}.gz "${SAVE_DIR}${IMAGE}.ext3.gz"
gunzip -f "${SAVE_DIR}${IMAGE}.ext3.gz"

singularity build --force /scratch/${USER}/images/${IMAGE}.sif ${DOCKER_URL} 
