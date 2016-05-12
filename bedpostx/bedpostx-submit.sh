#!/bin/bash

for f in $(ls | grep ".bedpostX")
do
	cd ${f}
	#pwd -P
	if [[ -f "submitme.sh" ]]
	then
		qsub submitme.sh
		echo "Submitted ${f}/submitme.sh"
	fi
	cd ..
done
