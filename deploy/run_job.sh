#!/bin/bash
LOG_DIR=$1
SIF_PATH=$2
OVERLAY_PATH=$3
SSH_USER=$4
VARIANT=$5
BUILD_JOB_ID=$6
DB_HOST=$7
POSTGRES_USER=$8
POSTGRES_PASSWORD=$9
POSTGRES_DB=${10}
PGPORT=${11}
IMAGE=${12}
TMP_DIR=${13}

# GPU options
if [ "$VARIANT" = "gpu" ]; then
    GPU_SLURM="#SBATCH --gres=gpu:1"
    GPU_SINGULARITY="--nv"
else
    GPU_SLURM=""
    GPU_SINGULARITY=""
fi

# Dependency
if [ -n "$BUILD_JOB_ID" ]; then
    SLURM_DEPENDENCY="#SBATCH --dependency=afterok:$BUILD_JOB_ID"
else
    SLURM_DEPENDENCY=""
fi

# Submit SLURM job
sbatch <<EOF
#!/bin/bash
#SBATCH --job-name=run_${IMAGE}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=14G
#SBATCH --time=06:00:00
#SBATCH --cpus-per-task=4
#SBATCH --output=${LOG_DIR}/run-${IMAGE}-%j.log
#SBATCH --error=${LOG_DIR}/run-${IMAGE}-%j.err
${GPU_SLURM}
${SLURM_DEPENDENCY}

singularity run ${GPU_SINGULARITY} \\
  --containall --no-home --cleanenv \\
  --overlay ${OVERLAY_PATH}:rw \\
  --bind /home/${SSH_USER}/.ssh \\
  --bind /home/${SSH_USER}/dev \\
  --bind /scratch/${SSH_USER}/wandb:/wandb_data \\
  --bind /scratch/${SSH_USER}/space:/scratch \\
  --bind ${TMP_DIR}:/tmp \\
  ${DB_HOST:+--env DB_HOST=$DB_HOST} \\
  ${POSTGRES_USER:+--env POSTGRES_USER=$POSTGRES_USER} \\
  ${POSTGRES_PASSWORD:+--env POSTGRES_PASSWORD=$POSTGRES_PASSWORD} \\
  ${POSTGRES_DB:+--env POSTGRES_DB=$POSTGRES_DB} \\
  ${PGPORT:+--env PGPORT=$PGPORT} \\
  ${SIF_PATH}
EOF
