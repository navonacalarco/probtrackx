#!/bin/bash
DTIFIT_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/data/dtifit

[ -f SubjectsList.txt ] && rm SubjectsList.txt
ls ${DTIFIT_ROOT} | grep VRMD_CMH_ >SubjectsList.txt

for f in $(<SubjectsList.txt); do
	echo "${f}"
	if [ -f ${DTIFIT_ROOT}/${f}/*.bval ]
	then
		[[ ! -d ${f} ]] && mkdir ${f}
		ln -s ${DTIFIT_ROOT}/${f}/*.bval ./${f}/bvals
		ln -s ${DTIFIT_ROOT}/${f}/*.bvec ./${f}/bvecs
		ln -s ${DTIFIT_ROOT}/${f}/*_eddy_correct.nii.gz ./${f}/data.nii.gz
		ln -s ${DTIFIT_ROOT}/${f}/*_mask.nii.gz ./${f}/nodif_brain_mask.nii.gz
		bedpostx_datacheck ./${f} 1>./${f}/datacheck.out 2>./${f}/datacheck.err
		if [[ -s ./${f}/datacheck.err ]]
		then	
			echo "  Error - check logs" 
		else
			echo " OK"
		fi
	else
		echo "  No data"
	fi

done
