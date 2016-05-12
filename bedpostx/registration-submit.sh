#!/bin/bash

for f in $(ls | grep ".bedpostX")
do
	cd ${f}
	#pwd -P
	if [[ -f "submitmeforreg.sh" ]]
	then
		qsub submitmeforreg.sh
		echo "Submitted ${f}/submitmeforreg.sh"
	fi
	cd ..
done
