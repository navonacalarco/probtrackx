#!/bin/bash -l
#PBS -l nodes=1:ppn=16,walltime=5:00:00
#PBS -N fsl-bpx-par
#PBS -o logs/bedpostx-parallel.out
#PBS -e logs/bedpostx-parallel.err
cd $PBS_O_WORKDIR
pwd -P
module load FSL
module load GNU_PARALLEL
echo "FSL and GNU_PARALLEL loaded"
