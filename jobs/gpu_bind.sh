#!/bin/bash
# Give each MPI rank on a node its own GPU from the list that Slurm assigned.
# Rank r gets GPU number (r mod number-of-GPUs).
IFS=, read -ra GPUS <<< "$CUDA_VISIBLE_DEVICES"
export CUDA_VISIBLE_DEVICES=${GPUS[$(( OMPI_COMM_WORLD_LOCAL_RANK % ${#GPUS[@]} ))]}
exec "$@"
