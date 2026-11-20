#!/bin/bash -l
#SBATCH --job-name=cavity-cpu
#SBATCH --partition=LocalQ
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=00:30:00
#SBATCH --output=cpu-%j.log
# CUBE Cavity_flow on 4 CPU cores (MPI ranks) of one LocalQ node.
# Submit from your copy of the example folder:   sbatch cpu.sbatch

module purge                        # start clean, even if you loaded other modules before sbatch
module load openmpi-5.0.6
export PKG_CONFIG_PATH=/storage/rahul-rcss/cube/develop-b6d6cf6a-gcc11-cpu/lib/pkgconfig
export OMP_NUM_THREADS=1

make clean > /dev/null
make || exit 1                      # builds ./CUBE_ICNS for the CPU
mkdir -p output                     # CUBE writes its result files here

# hoopoe does not lock a job to its own cores, so do not let mpirun pin ranks to cores 0,1,2,...
# (other jobs may be using them). --bind-to none lets Linux put each rank on a free core.

echo "Started on $(hostname) at $(date)"
mpirun -np $SLURM_NTASKS --bind-to none ./CUBE_ICNS > run.log 2>&1
echo "Finished with exit code $? at $(date)"
tail -3 run.log
