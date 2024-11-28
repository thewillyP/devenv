#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=14G
#SBATCH --time=01:00:00
#SBATCH --job-name=build
#SBATCH --error=build.err
#SBATCH --output=build.log
#SBATCH --cpus-per-task=10

USER=wlp9800
IMAGE=devenv
DOCKER_URL="docker://thewillyp/${IMAGE}@sha256:c63e8c3cf3e3f4ea4d4aef514c869dc863e4a3e7cf84a678325c0271e034c8ff"
OVERLAY_TYPE="overlay-15GB-500K.ext3"
SAVE_DIR="/scratch/${USER}/"


# Check if the file already exists
# https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/singularity-with-miniconda?authuser=0
cp -rp /scratch/work/public/overlay-fs-ext3/${OVERLAY_TYPE}.gz "${SAVE_DIR}${IMAGE}.ext3.gz"
gunzip -f "${SAVE_DIR}${IMAGE}.ext3.gz"

singularity build /scratch/${USER}/images/${IMAGE}.sif ${DOCKER_URL} 
