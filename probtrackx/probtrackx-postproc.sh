#!/bin/bash -l
#PBS -l nodes=1:ppn=1,walltime=10:00:00
#PBS -N ptx-postproc
#PBS -o probtrackx-postproc.out
#PBS -e probtrackx-postproc.err

#cd $PBS_O_WORKDIR
#pwd -P
module load FSL
echo "FSL loaded"

PTX_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/tractography/probtrackx
cd ${PTX_ROOT}
pwd -P

refMNI=/quarantine/FSL/fsl_5.0.3/fsl/data/standard/MNI152_T1_2mm

#for each subject
for f in $(ls | grep VRMD_CMH_); do
	echo "${f}"
	cd ${f}
	warpimg=`pwd -P`/bedpostX/xfms/diff2standard_warp.nii.gz
	if [[ ! -e ${warpimg} ]]; then
		echo "  Cannot find warp ${warpimg}"
		continue
	fi

	#for each tract
	for t in $(ls | grep "_L$\|_R$"); do
		if [[ ! -d ${t} ]]; then
			echo "  No directory ${f}/${t}"
			continue
		fi
		cd ${t}
		if [[ ! -e fdt_paths.nii.gz ]]; then
			echo "  Cannot find fdt_paths in ${f}/${t}"
			continue
		elif [[ ! -e waytotal ]]; then
			echo "  Cannot find waytotal in ${f}/${t}"
			continue
		fi
		
		fslmaths fdt_paths.nii.gz -div `cat waytotal` tract_norm.nii.gz
		applywarp -i tract_norm.nii.gz -r ${refMNI} -w ${warpimg} -o tract_norm_MNI.nii.gz

		fslmaths tract_norm.nii.gz -thr 0.01 -bin tract_norm_thr01_mask.nii.gz
		applywarp -i tract_norm_thr01_mask.nii.gz -r ${refMNI} -w ${warpimg} -o tract_norm_thr01_mask_MNI.nii.gz
		fslmaths tract_norm_thr01_mask_MNI.nii.gz -thr 0.5 -bin tract_norm_thr01_mask_MNI.nii.gz

		fslmaths tract_norm.nii.gz -thr 0.03 -bin tract_norm_thr03_mask.nii.gz
		applywarp -i tract_norm_thr03_mask.nii.gz -r ${refMNI} -w ${warpimg} -o tract_norm_thr03_mask_MNI.nii.gz
		fslmaths tract_norm_thr03_mask_MNI.nii.gz -thr 0.5 -bin tract_norm_thr03_mask_MNI.nii.gz
		
		fslmaths tract_norm.nii.gz -thr 0.05 -bin tract_norm_thr05_mask.nii.gz
		applywarp -i tract_norm_thr05_mask.nii.gz -r ${refMNI} -w ${warpimg} -o tract_norm_thr05_mask_MNI.nii.gz
		fslmaths tract_norm_thr05_mask_MNI.nii.gz -thr 0.5 -bin tract_norm_thr05_mask_MNI.nii.gz
		
		cd ..
	done
	
	cd ..
	echo "  Done."
done
