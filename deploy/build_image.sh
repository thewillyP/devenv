#!/bin/bash
SCRATCH_DIR=$1
OVERLAY_PATH=$2
SIF_PATH=$3
DOCKER_URL=$4
LOG_DIR=$5
IMAGE=$6

sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=build_${IMAGE}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=10G
#SBATCH --time=00:30:00
#SBATCH --output=${LOG_DIR}/build-${IMAGE}-%j.log
#SBATCH --error=${LOG_DIR}/build-${IMAGE}-%j.err

mkdir -p ${SCRATCH_DIR}/images
cp -rp /scratch/work/public/overlay-fs-ext3/overlay-25GB-500K.ext3.gz ${OVERLAY_PATH}.gz
gunzip -f ${OVERLAY_PATH}.gz
singularity build --force ${SIF_PATH} ${DOCKER_URL}
EOF