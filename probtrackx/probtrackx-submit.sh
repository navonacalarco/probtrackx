#!/bin/bash

for f in $(ls | grep "VRMD_CMH_")
do
	cd ${f}
	#pwd -P
	if [[ -f "submitme.sh" && -f "ptx-commands.txt" ]]
	then
		qsub submitme.sh
		echo "Submitted ${f}/submitme.sh"
	fi
	cd ..
done
