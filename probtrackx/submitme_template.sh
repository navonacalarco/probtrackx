#!/bin/bash -l
#PBS -l nodes=1:ppn=12,walltime=8:00:00
#PBS -N fsl-ptx-par
#PBS -o logs/probtrackx-parallel.out
#PBS -e logs/probtrackx-parallel.err
cd $PBS_O_WORKDIR
pwd -P
module load FSL
module load GNU_PARALLEL
echo "FSL and GNU_PARALLEL loaded"
