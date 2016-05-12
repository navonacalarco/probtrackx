#!/bin/bash -l
#PBS -l nodes=1:ppn=1,walltime=1:00:00
#PBS -N ptx-mergetracts
#PBS -o probtrackx-mergetracts.out
#PBS -e probtrackx-mergetracts.err

#cd $PBS_O_WORKDIR
#pwd -P
#module load FSL
#echo "FSL loaded"

PTX_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/tractography/probtrackx
cd ${PTX_ROOT}/group-tracts
pwd -P

#refMNI=/quarantine/FSL/fsl_5.0.3/fsl/data/standard/MNI152_T1_2mm

THRTYPE="_thr05_mask_MNI"
#_MNI
#_thr01_mask_MNI
#_thr03_mask_MNI
#_thr05_mask_MNI

#for each tract in wanted list
for t in $(<tractslist.txt); do
	echo "${t}"
	COMMAND="fslmaths "
	FINDEX=0
	#find tract in each participant
	for f in $(find ${PTX_ROOT} -wholename *VRMD_CMH_*/${t}/tract_norm${THRTYPE}.nii.gz); do
		let FINDEX=FINDEX+1
		#echo "  ${FINDEX}: ${f}"
		if [[ ${FINDEX} == 1 ]]; then
			COMMAND="${COMMAND} ${f} "
		else
			COMMAND="${COMMAND} -add ${f} "
		fi
	done
	COMMAND="${COMMAND} -div ${FINDEX} ${t}_group${THRTYPE}.nii.gz"
	echo "  Summing ..."
	echo "  ${COMMAND}"
	${COMMAND}
	echo "  Done."
done

