#!/bin/bash
PTX_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/tractography/probtrackx
cd ${PTX_ROOT}

for f in $(ls | grep VRMD_CMH_); do
	echo "${f}"
	bpx=${f}/bedpostX

	for m in $(ls masks-standard | grep ".nii.gz"); do
		echo "  ${m}"
		fslstats ./masks-standard/${m} -M -V
		applywarp -i ./masks-standard/${m} -r ${bpx}/nodif_brain_mask.nii.gz -w ${bpx}/xfms/standard2diff_warp.nii.gz -o ${f}/masks/${m}
		fslmaths ${f}/masks/${m} -thr 0.9 -bin ${f}/masks/${m}
		fslstats ${f}/masks/${m} -M -V
	done
	echo "  Done."
done
