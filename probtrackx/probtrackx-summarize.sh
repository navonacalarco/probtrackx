#!/bin/bash
SMY_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/tractography/summary
PTX_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/tractography/probtrackx
cd ${PTX_ROOT}

#for each subject
for f in $(ls | grep VRMD_CMH_); do
	echo ${f}
	cd ${f}
	csvname=${f}-ptx-summary.csv
	rm -f ${csvname}
	echo "TractName,SeedVolume,TractVolume,Waytotal,MeanFA,MeanMD" >>${csvname}

	#Make a mask from FA values thresholded at FA>=0.2
	fslmaths FA.nii.gz -thr 0.2 FA_thr2.nii.gz
	fslmaths FA_thr2.nii.gz -bin FA_thr2_mask.nii.gz
	fslmaths MD.nii.gz -mas FA_thr2_mask.nii.gz MD_FAthr2.nii.gz

	echo `fslstats FA_thr2.nii.gz -M | tr -d " "` >${SMY_ROOT}/${f}-meanFA
	echo `fslstats MD_FAthr2.nii.gz -M | tr -d " "` >${SMY_ROOT}/${f}-meanMD

	rm FA_thr2_mask.nii.gz

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
		
		#Identifying the mask...
		#seedfile=../masks/`echo ${t} | cut -d "-" -f 1`_`echo $[t} | cut -d "_" -f 2`.nii.gz
		seedfile=../masks/`echo ${t} | cut -d "-" -f 1`_`echo ${t} | cut -d "_" -f 2`.nii.gz
		
		waytot=`cat waytotal | tr -d " "`

		#normalize, threshold, and binarize
		fslmaths fdt_paths.nii.gz -div ${waytot} -thr 0.03 -bin tract_norm_mask.nii.gz
		fslmaths tract_norm_mask.nii.gz -sub ${seedfile} -bin tract_norm_mask.nii.gz

		seedvol=(`fslstats ${seedfile} -V`)
		#use index 0 for voxels, 1 for volume in mm
		seedvol=${seedvol[1]}
		
		tractvol=(`fslstats tract_norm_mask.nii.gz -V`)
		#use index 0 for voxels, 1 for volume in mm
		tractvol=${tractvol[1]}

		#use FA and MD images after masking with FA>=0.2
		#fslmaths ../FA.nii.gz -mas tract_norm_mask.nii.gz maskedFA.nii.gz
		#fslmaths ../MD.nii.gz -mas tract_norm_mask.nii.gz maskedMD.nii.gz
		fslmaths ../FA_thr2.nii.gz -mas tract_norm_mask.nii.gz maskedFA.nii.gz
		fslmaths ../MD_FAthr2.nii.gz -mas tract_norm_mask.nii.gz maskedMD.nii.gz
		
		meanfa=`fslstats maskedFA.nii.gz -M | tr -d " "`
		meanmd=`fslstats maskedMD.nii.gz -M | tr -d " "`

		#TODO: comment these to keep the masked images
		rm maskedFA.nii.gz
		rm maskedMD.nii.gz
		rm tract_norm_mask.nii.gz

		#FIXME? trim any other whitespaces here?

		echo "${t},${seedvol},${tractvol},${waytot},${meanfa},${meanmd}" >>../${csvname}
		cd ..
	done

	rm FA_thr2.nii.gz
	rm MD_FAthr2.nii.gz
	
	#copy to summaries only folder
	cp ${csvname} ${SMY_ROOT}/${csvname}
	
	cd ..
	echo "  Done."
done
