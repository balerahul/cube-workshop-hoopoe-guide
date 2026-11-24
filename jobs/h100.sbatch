#!/bin/bash
#SBATCH --job-name=cylinder-h100
#SBATCH --partition=hgpuq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=00:30:00
#SBATCH --output=h100-%j.log
# CUBE cylinder case on 1 H100 GPU (node10).
# Submit from your copy of the example folder:   sbatch h100.sbatch
# Compressible solver instead (CNS):             sbatch h100.sbatch input_cns.toml

# node10 has no "module" command, so load the compiler with this file instead.
source /storage/rahul-rcss/nvhpc/nvhpc-hpcx-cuda12-26.11.sh
export OMP_TARGET_OFFLOAD=MANDATORY
export OMP_NUM_THREADS=1
ulimit -s unlimited
CUBE=/storage/rahul-rcss/cube/develop-b6d6cf6a-nvhpc26.11-gpu/bin/cube
INPUT=${1:-input_icns.toml}

echo "Started on $(hostname) with GPU $CUDA_VISIBLE_DEVICES and $INPUT at $(date)"
nvidia-smi --query-gpu=name --format=csv,noheader -i $CUDA_VISIBLE_DEVICES
mpirun -np 1 --bind-to none $CUBE -p $INPUT > run.log 2>&1
echo "Finished with exit code $? at $(date)"
tail -3 run.log
