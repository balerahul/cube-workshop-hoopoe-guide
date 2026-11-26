#!/bin/bash -l
#SBATCH --job-name=drone-cpu
#SBATCH --partition=LocalQ
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --time=00:45:00
#SBATCH --output=cpu-%j.log
# CUBE drone example on 12 CPU cores (MPI ranks) of one LocalQ node.
# Submit from your copy of the example folder:   sbatch cpu.sbatch
# Roll flight instead of the hover:              sbatch cpu.sbatch input_roll.toml

module purge                        # start clean, even if you loaded other modules before sbatch
module load openmpi-5.0.6
export OMP_NUM_THREADS=1
CUBE=/storage/rahul-rcss/cube/examples/drone/cube_drone
INPUT=${1:-input_hover.toml}        # the parameter file; input_hover.toml unless you name another one
mkdir -p output                     # CUBE writes the drone history and the flow fields here

# hoopoe does not lock a job to its own cores, so do not let mpirun pin ranks to cores 0,1,2,...
# (other jobs may be using them). --bind-to none lets Linux put each rank on a free core.

echo "Started on $(hostname) with $INPUT at $(date)"
mpirun -np $SLURM_NTASKS --bind-to none $CUBE -p $INPUT > run.log 2>&1
echo "Finished with exit code $? at $(date)"
tail -3 run.log
