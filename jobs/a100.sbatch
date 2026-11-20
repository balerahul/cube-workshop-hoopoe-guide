#!/bin/bash -l
#SBATCH --job-name=cavity-a100
#SBATCH --partition=gpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1
#SBATCH --time=00:30:00
#SBATCH --output=a100-%j.log
# CUBE Cavity_flow on 1 A100 GPU (node01).
# Submit from your copy of the example folder:   sbatch a100.sbatch

module purge                         # start clean, even if you loaded other modules before sbatch
module use /storage/rahul-rcss/nvhpc/modulefiles
module load nvhpc-hpcx-cuda12/26.11
export PKG_CONFIG_PATH=/storage/rahul-rcss/cube/develop-b6d6cf6a-nvhpc26.11-gpu/lib/pkgconfig
export OMP_TARGET_OFFLOAD=MANDATORY  # stop with an error if the GPU cannot be used
export OMP_NUM_THREADS=1
ulimit -s unlimited                  # the GPU build needs a large stack

make clean > /dev/null
make || exit 1                       # builds ./CUBE_ICNS for the GPU
mkdir -p output

echo "Started on $(hostname) with GPU $CUDA_VISIBLE_DEVICES at $(date)"
nvidia-smi --query-gpu=name --format=csv,noheader -i $CUDA_VISIBLE_DEVICES
mpirun -np 1 --bind-to none ./CUBE_ICNS > run.log 2>&1
echo "Finished with exit code $? at $(date)"
tail -3 run.log
