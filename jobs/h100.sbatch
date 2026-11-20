#!/bin/bash
#SBATCH --job-name=cavity-h100
#SBATCH --partition=hgpuq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=00:30:00
#SBATCH --output=h100-%j.log
# CUBE Cavity_flow on 1 H100 GPU (node10).
# Submit from your copy of the example folder:   sbatch h100.sbatch

# node10 has no "module" command, so load the compiler with this file instead.
source /storage/rahul-rcss/nvhpc/nvhpc-hpcx-cuda12-26.11.sh
export PKG_CONFIG_PATH=/storage/rahul-rcss/cube/develop-b6d6cf6a-nvhpc26.11-gpu/lib/pkgconfig
export OMP_TARGET_OFFLOAD=MANDATORY
export OMP_NUM_THREADS=1
ulimit -s unlimited

make clean > /dev/null
make || exit 1
mkdir -p output

echo "Started on $(hostname) with GPU $CUDA_VISIBLE_DEVICES at $(date)"
nvidia-smi --query-gpu=name --format=csv,noheader -i $CUDA_VISIBLE_DEVICES
mpirun -np 1 --bind-to none ./CUBE_ICNS > run.log 2>&1
echo "Finished with exit code $? at $(date)"
tail -3 run.log
