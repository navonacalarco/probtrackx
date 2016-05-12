#!/bin/bash
DTIFIT_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/data/dtifit
BPX_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/tractography/bedpostx

for f in $(ls ${BPX_ROOT} | grep VRMD_CMH_ | grep -v .bedpostX); do
	echo "${f}"
	fbpx=${BPX_ROOT}/${f}.bedpostX
	if [ -d ${fbpx} ]
	then
		[[ ! -d ${f} ]] && mkdir -p ${f}/masks
		[[ ! -d ${f}/logs ]] && mkdir ${f}/logs
		ln -s ${fbpx} ./${f}/bedpostX
		ln -s ${DTIFIT_ROOT}/${f}/*_eddy_correct_dtifit_FA.nii.gz ./${f}/FA.nii.gz
		ln -s ${DTIFIT_ROOT}/${f}/*_eddy_correct_dtifit_MD.nii.gz ./${f}/MD.nii.gz
		echo "  Done."
	else
		echo "  Unable to find bedpostX."
	fi
done
