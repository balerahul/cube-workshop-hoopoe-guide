#!/bin/bash -l
#SBATCH --job-name=cylinder-cpu
#SBATCH --partition=LocalQ
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --time=00:30:00
#SBATCH --output=cpu-%j.log
# CUBE cylinder case on 12 CPU cores (MPI ranks) of one LocalQ node.
# Submit from your copy of the example folder:   sbatch cpu.sbatch
# Compressible solver instead (CNS):             sbatch cpu.sbatch input_cns.toml

module purge                        # start clean, even if you loaded other modules before sbatch
module load openmpi-5.0.6
export OMP_NUM_THREADS=1
CUBE=/storage/rahul-rcss/cube/develop-b6d6cf6a-gcc11-cpu/bin/cube
INPUT=${1:-input_icns.toml}         # the parameter file; input_icns.toml unless you name another one

# hoopoe does not lock a job to its own cores, so do not let mpirun pin ranks to cores 0,1,2,...
# (other jobs may be using them). --bind-to none lets Linux put each rank on a free core.

echo "Started on $(hostname) with $INPUT at $(date)"
mpirun -np $SLURM_NTASKS --bind-to none $CUBE -p $INPUT > run.log 2>&1
echo "Finished with exit code $? at $(date)"
tail -3 run.log
