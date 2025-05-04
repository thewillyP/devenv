#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=10G
#SBATCH --time=00:15:00
#SBATCH --job-name=build
#SBATCH --error=build.err
#SBATCH --output=build.log
#SBATCH --cpus-per-task=6
#SBATCH --mail-type=END
#SBATCH --mail-user=wlp9800@nyu.edu

USER=wlp9800
IMAGE=devenv
DOCKER_URL="docker://thewillyp/${IMAGE}:master-1.0.35-gpu"
OVERLAY_TYPE="overlay-25GB-500K.ext3"
SAVE_DIR="/scratch/${USER}/"


# Check if the file already exists
# https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/singularity-with-miniconda?authuser=0
cp -rp /scratch/work/public/overlay-fs-ext3/${OVERLAY_TYPE}.gz "${SAVE_DIR}${IMAGE}.ext3.gz"
gunzip -f "${SAVE_DIR}${IMAGE}.ext3.gz"

singularity build --force /scratch/${USER}/images/${IMAGE}.sif ${DOCKER_URL} 
