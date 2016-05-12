#!/bin/bash

for f in $(ls | grep ".bedpostX")
do
	echo "${f}"
	if [[ -e ${f}/T1.nii.gz ]] 
	then
		# Bet T1 for non-linear reg
		# -f value is NOT bet default, but the one suggested in dm-proc-dtifit.py
		echo "  bet ${f}/T1.nii.gz ${f}/T1_bet.nii.gz -m -f 0.3 -R"
		bet ${f}/T1.nii.gz ${f}/T1_bet.nii.gz -m -f 0.3 -R
		echo "  Done."
	else
		echo "  No T1 link."
	fi
done
