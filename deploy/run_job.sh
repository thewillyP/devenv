#!/bin/bash
LOG_DIR=$1
SIF_PATH=$2
OVERLAY_PATH=$3
SSH_USER=$4
VARIANT=$5
DEPENDENCY=$6
DB_HOST=$7
POSTGRES_USER=$8
POSTGRES_PASSWORD=$9
POSTGRES_DB=${10}
PGPORT=${11}
IMAGE=${12}

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
#SBATCH --mail-type=BEGIN
#SBATCH --mail-user=${SSH_USER}@nyu.edu
${VARIANT == 'gpu' ? '#SBATCH --gres=gpu:0' : ''}
${DEPENDENCY}

singularity run ${VARIANT == 'gpu' ? '--nv' : ''} \\
  --containall --no-home --cleanenv \\
  --overlay ${OVERLAY_PATH}:rw \\
  --bind /home/${SSH_USER}/.ssh \\
  --bind /home/${SSH_USER}/dev \\
  --bind /scratch/${SSH_USER}/wandb:/wandb_data \\
  --bind /scratch/${SSH_USER}/space:/scratch \\
  ${DB_HOST:+--env POSTGRES_HOST=${DB_HOST}} \\
  ${POSTGRES_USER:+--env POSTGRES_USER=${POSTGRES_USER}} \\
  ${POSTGRES_PASSWORD:+--env POSTGRES_PASSWORD=${POSTGRES_PASSWORD}} \\
  ${POSTGRES_DB:+--env POSTGRES_DB=${POSTGRES_DB}} \\
  ${PGPORT:+--env PGPORT=${PGPORT}} \\
  ${SIF_PATH}
EOF