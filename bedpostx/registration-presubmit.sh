#!/bin/bash
DTIFIT_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/data/dtifit
#NII_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/data/nii
BPX_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/tractography/bedpostx
cd ${BPX_ROOT}

for f in $(ls | grep VRMD_CMH_ | grep -v .bedpostX); do
	#echo "${f}"
	fbpx="${BPX_ROOT}/${f}.bedpostX"
	echo "${fbpx}"

	if [ ! -e ${fbpx}/nodif_brain.nii.gz ]
	then
		echo "  Linking nodif_brain"
		if [ -e ${DTIFIT_ROOT}/${f}/*_b0_bet.nii.gz ]
		then
			ln -s ${DTIFIT_ROOT}/${f}/*_b0_bet.nii.gz ${fbpx}/nodif_brain.nii.gz
			echo "    Linked to Betted B0"
		else
			echo "    Unable to find Betted B0"
		fi
	else
		echo "  Already has nodif_brain"
	fi

	cp submitmeforreg_template.sh ${fbpx}/submitmeforreg.sh

	echo "  Generating linear xfms commands"
	echo "echo \"Generating linear xfms...\"" >>${fbpx}/submitmeforreg.sh
	echo "flirt -in ${fbpx}/nodif_brain -ref ${fbpx}/T1_bet.nii.gz -omat ${fbpx}/xfms/diff2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6 -cost corratio" >>${fbpx}/submitmeforreg.sh
	echo "convert_xfm -omat ${fbpx}/xfms/str2diff.mat -inverse ${fbpx}/xfms/diff2str.mat" >>${fbpx}/submitmeforreg.sh
	echo "flirt -in ${fbpx}/T1_bet.nii.gz -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -omat ${fbpx}/xfms/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio" >>${fbpx}/submitmeforreg.sh
	echo "convert_xfm -omat ${fbpx}/xfms/standard2str.mat -inverse ${fbpx}/xfms/str2standard.mat" >>${fbpx}/submitmeforreg.sh
	echo "convert_xfm -omat ${fbpx}/xfms/diff2standard.mat -concat ${fbpx}/xfms/str2standard.mat ${fbpx}/xfms/diff2str.mat" >>${fbpx}/submitmeforreg.sh
	echo "convert_xfm -omat ${fbpx}/xfms/standard2diff.mat -inverse ${fbpx}/xfms/diff2standard.mat" >>${fbpx}/submitmeforreg.sh
	echo "echo \"Done.\"" >>${fbpx}/submitmeforreg.sh
	
	echo "  Generating nonlinear xfms commands"
	echo "echo \"Generating nonlinear xfms...\"" >>${fbpx}/submitmeforreg.sh
	echo "fnirt --in=${fbpx}/T1.nii.gz --aff=${fbpx}/xfms/str2standard.mat --cout=${fbpx}/xfms/str2standard_warp --config=T1_2_MNI152_2mm" >>${fbpx}/submitmeforreg.sh
	echo "invwarp -w ${fbpx}/xfms/str2standard_warp -o ${fbpx}/xfms/standard2str_warp -r ${fbpx}/T1_bet.nii.gz" >>${fbpx}/submitmeforreg.sh
	echo "convertwarp -o ${fbpx}/xfms/diff2standard_warp -r ${FSLDIR}/data/standard/MNI152_T1_2mm -m ${fbpx}/xfms/diff2str.mat -w ${fbpx}/xfms/str2standard_warp" >>${fbpx}/submitmeforreg.sh
	echo "convertwarp -o ${fbpx}/xfms/standard2diff_warp -r ${fbpx}/nodif_brain_mask -w ${fbpx}/xfms/standard2str_warp --postmat=${fbpx}/xfms/str2diff.mat" >>${fbpx}/submitmeforreg.sh
	echo "echo \"Done.\"" >>${fbpx}/submitmeforreg.sh
	
	echo "  Done."

done
