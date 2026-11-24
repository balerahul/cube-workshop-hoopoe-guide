#!/bin/bash -l
#SBATCH --job-name=cylinder-a100
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=00:30:00
#SBATCH --output=a100-%j.log
# CUBE cylinder case on 1 A100 GPU (node01).
# Submit from your copy of the example folder:   sbatch a100.sbatch
# Compressible solver instead (CNS):             sbatch a100.sbatch input_cns.toml

module purge                         # start clean, even if you loaded other modules before sbatch
module use /storage/rahul-rcss/nvhpc/modulefiles
module load nvhpc-hpcx-cuda12/26.11
export OMP_TARGET_OFFLOAD=MANDATORY  # stop with an error if the GPU cannot be used
export OMP_NUM_THREADS=1
ulimit -s unlimited                  # the GPU build needs a large stack
CUBE=/storage/rahul-rcss/cube/develop-b6d6cf6a-nvhpc26.11-gpu/bin/cube
INPUT=${1:-input_icns.toml}          # the parameter file; input_icns.toml unless you name another one

echo "Started on $(hostname) with GPU $CUDA_VISIBLE_DEVICES and $INPUT at $(date)"
nvidia-smi --query-gpu=name --format=csv,noheader -i $CUDA_VISIBLE_DEVICES
mpirun -np 1 --bind-to none $CUBE -p $INPUT > run.log 2>&1
echo "Finished with exit code $? at $(date)"
tail -3 run.log
