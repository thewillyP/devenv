#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=14G
#SBATCH --time=00:15:00
#SBATCH --job-name=build
#SBATCH --error=build.err
#SBATCH --output=build.log
#SBATCH --cpus-per-task=10

USER=wlp9800
IMAGE=devenv
DOCKER_URL="docker://thewillyp/${IMAGE}:master-1.0.16@sha256:0581745d5eef984b352dab2bc4d90393230ac297e5a92e82ad56f5a5160bd1a9"
OVERLAY_TYPE="overlay-15GB-500K.ext3"
SAVE_DIR="/scratch/${USER}/"


# Check if the file already exists
# https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/singularity-with-miniconda?authuser=0
cp -rp /scratch/work/public/overlay-fs-ext3/${OVERLAY_TYPE}.gz "${SAVE_DIR}${IMAGE}.ext3.gz"
gunzip -f "${SAVE_DIR}${IMAGE}.ext3.gz"

singularity build --force /scratch/${USER}/images/${IMAGE}.sif ${DOCKER_URL} 
