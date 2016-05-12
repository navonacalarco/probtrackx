#!/bin/bash

for f in $(ls | grep "VRMD_CMH_" | grep -v ".bedpostX")
do
	echo "./bedpostx-VRMD ${f} --nf=2 --fudge=1  --bi=1000"
	if [[ ! -d ${f}.bedpostX ]] 
	then
		./bedpostx-VRMD ${f} --nf=2 --fudge=1  --bi=1000
	fi
done
