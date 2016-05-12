#!/bin/bash
rm *.nii.gz
PREP_DIR=/imaging/scratch/VR_Lab/isiddiqui/VRMD/tractography/roi-prep/ready
ln -s ${PREP_DIR}/* .
