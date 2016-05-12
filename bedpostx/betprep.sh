#!/bin/bash
#DTIFIT_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/data/dtifit
NII_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/data/nii

#if [ ! -f SubjectsList.txt ]
#then
#	ls ${NII_ROOT} | grep VRMD_CMH_ >SubjectsList.txt
#fi

for f in $(ls | grep VRMD_CMH_ | grep -v .bedpostX); do
	echo "${f}"
	if [ ${f} = "VRMD_CMH_RR524_01" ]
	then
		echo "  Known issue: Has two T1 sessions, both with motion"
		echo "  Link this one manually"
		continue
	fi
	if [ -f ${NII_ROOT}/${f}/*T1-BRAVO.nii.gz ]
	then
		if [ -d ${f}.bedpostX ]
		then
			ln -s ${NII_ROOT}/${f}/*T1-BRAVO.nii.gz ./${f}.bedpostX/T1.nii.gz
			echo " OK"
		else
			echo "  No .bedpostX directory"
		fi
	else
		echo "  No T1 data"
	fi

done
