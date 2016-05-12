#!/bin/bash -l
#PBS -l nodes=1:ppn=1,walltime=5:00:00
#PBS -N fsl-fdt-reg
#PBS -o logs/registration.out
#PBS -e logs/registration.err
cd $PBS_O_WORKDIR
pwd -P
module load FSL
echo "FSL loaded"
