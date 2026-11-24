#!/bin/bash
#SBATCH --job-name=cylinder-2gpu
#SBATCH --partition=hgpuq
#SBATCH --nodes=1
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:2
#SBATCH --time=00:30:00
#SBATCH --output=multigpu-%j.log
# CUBE cylinder case with 2 MPI ranks on 2 H100 GPUs (node10): one rank per GPU.
# To use 4 GPUs, change BOTH --ntasks and --gres to 4.
# Submit from your copy of the example folder:   sbatch multigpu.sbatch

source /storage/rahul-rcss/nvhpc/nvhpc-hpcx-cuda12-26.11.sh
export OMP_TARGET_OFFLOAD=MANDATORY
export OMP_NUM_THREADS=1
ulimit -s unlimited
CUBE=/storage/rahul-rcss/cube/develop-b6d6cf6a-nvhpc26.11-gpu/bin/cube
INPUT=${1:-input_icns.toml}

# CUBE does not choose a GPU for each rank, so gpu_bind.sh gives rank 0 the first GPU,
# rank 1 the second GPU, and so on.
BIND=/storage/rahul-rcss/cube/examples/cylinder/gpu_bind.sh
echo "Started on $(hostname) with GPUs $CUDA_VISIBLE_DEVICES and $INPUT at $(date)"
mpirun -np $SLURM_NTASKS --bind-to none $BIND $CUBE -p $INPUT > run.log 2>&1
echo "Finished with exit code $? at $(date)"
tail -3 run.log
