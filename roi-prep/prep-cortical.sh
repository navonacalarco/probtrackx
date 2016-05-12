#!/bin/bash
bilatIn=$1
unilatOut=$2
tempImg="prep-temp.nii.gz"

#Subtract cortical white matter
#FIXME?: Better to do each hemi separately after split?
fslmaths ${bilatIn} -sub ../BilatCerebralWhiteMatter.nii.gz -bin ${tempImg}

#Apply hemi masks to split
fslmaths ${tempImg} -mas ../LeftHemisphere.nii.gz -bin "${unilatOut}_L"
fslmaths ${tempImg} -mas ../RightHemisphere.nii.gz -bin "${unilatOut}_R"

#delete the temp image
rm ${tempImg}
