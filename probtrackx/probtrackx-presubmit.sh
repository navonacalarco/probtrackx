#!/bin/bash
#DTIFIT_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/data/dtifit
#NII_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/data/nii
#BPX_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/tractography/bedpostx

PTX_ROOT=/imaging/scratch/VR_Lab/isiddiqui/VRMD/tractography/probtrackx
cd ${PTX_ROOT}

#subject loop
for f in $(ls | grep VRMD_CMH_); do
	echo "${f}"
	#fbpx="${BPX_ROOT}/${f}.bedpostX"
	#echo "${fbpx}"
	cp submitme_template.sh ./${f}/submitme.sh
	[[ -e ./${f}/ptx-commands.txt ]] && rm ./${f}/ptx-commands.txt
	
	#seeds loop
	for sd in "Accumbens" "Caudate" "Putamen"; do
		#hemisphere loop
		for hs in "L" "R"; do
			seed=${PTX_ROOT}/${f}/masks/${sd}_${hs}.nii.gz
			if [ ! -e ${seed} ]; then
				echo "  ERROR: Unable to locate ${seed}"
				continue
			fi
			echo "  Seed: ${seed}"

			[ ${hs} == "L" ] && excl=${PTX_ROOT}/${f}/masks/RightHemisphere.nii.gz
			[ ${hs} == "R" ] && excl=${PTX_ROOT}/${f}/masks/LeftHemisphere.nii.gz
			if [ ! -e ${excl} ]; then
				echo "  ERROR: Unable to locate ${excl}"
				continue
			fi
			echo "  Excl: ${excl}"

			#target loop
			for tg in "SMA" "DLPFC" "VLPFC" "OFC"; do
				trgt=${PTX_ROOT}/${f}/masks/${tg}_${hs}.nii.gz
				#wypt=
				if [ ! -e ${trgt} ]; then
					echo "  ERROR: Unable to locate ${trgt}"
					continue
				fi
				echo "  Trgt: ${trgt}"
				
				#create directory for this tract
				echo "rm -rf ${PTX_ROOT}/${f}/${sd}-${tg}_${hs}" >>./${f}/submitme.sh
				echo "mkdir ${PTX_ROOT}/${f}/${sd}-${tg}_${hs}" >>./${f}/submitme.sh
				
				echo "probtrackx2  -x ${seed}  -l --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --avoid=${excl} --stop=${trgt} --forcedir --opd -s ${PTX_ROOT}/${f}/bedpostX/merged -m ${PTX_ROOT}/${f}/bedpostX/nodif_brain_mask  --dir=${PTX_ROOT}/${f}/${sd}-${tg}_${hs} --waypoints=${trgt}  --waycond=AND" >>${PTX_ROOT}/${f}/ptx-commands.txt
			
			done
		done
	done

	echo "echo \"Starting parallel Probtrackx runs for ${f}\"" >>./${f}/submitme.sh
	echo "parallel --joblog ${PTX_ROOT}/${f}/logs/joblog.log < ${PTX_ROOT}/${f}/ptx-commands.txt" >>./${f}/submitme.sh
	echo "echo \"All done for ${f}\"" >>./${f}/submitme.sh
done
