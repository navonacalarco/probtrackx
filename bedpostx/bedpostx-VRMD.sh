#!/bin/sh

#   Copyright (C) 2004 University of Oxford
#
#   Part of FSL - FMRIB's Software Library
#   http://www.fmrib.ox.ac.uk/fsl
#   fsl@fmrib.ox.ac.uk
#   
#   Developed at FMRIB (Oxford Centre for Functional Magnetic Resonance
#   Imaging of the Brain), Department of Clinical Neurology, Oxford
#   University, Oxford, UK
#   
#   
#   LICENCE
#   
#   FMRIB Software Library, Release 5.0 (c) 2012, The University of
#   Oxford (the "Software")
#   
#   The Software remains the property of the University of Oxford ("the
#   University").
#   
#   The Software is distributed "AS IS" under this Licence solely for
#   non-commercial use in the hope that it will be useful, but in order
#   that the University as a charitable foundation protects its assets for
#   the benefit of its educational and research purposes, the University
#   makes clear that no condition is made or to be implied, nor is any
#   warranty given or to be implied, as to the accuracy of the Software,
#   or that it will be suitable for any particular purpose or for use
#   under any specific conditions. Furthermore, the University disclaims
#   all responsibility for the use which is made of the Software. It
#   further disclaims any liability for the outcomes arising from using
#   the Software.
#   
#   The Licensee agrees to indemnify the University and hold the
#   University harmless from and against any and all claims, damages and
#   liabilities asserted by third parties (including claims for
#   negligence) which arise directly or indirectly from the use of the
#   Software or the sale of any products based on the Software.
#   
#   No part of the Software may be reproduced, modified, transmitted or
#   transferred in any form or by any means, electronic or mechanical,
#   without the express permission of the University. The permission of
#   the University is not required if the said reproduction, modification,
#   transmission or transference is done without financial return, the
#   conditions of this Licence are imposed upon the receiver of the
#   product, and all original and amended source code is included in any
#   transmitted product. You may be held legally responsible for any
#   copyright infringement that is caused or encouraged by your failure to
#   abide by these terms and conditions.
#   
#   You are not permitted under this Licence to use this Software
#   commercially. Use for which any financial return is received shall be
#   defined as commercial use, and includes (1) integration of all or part
#   of the source code or the Software into a product for sale or license
#   by or on behalf of Licensee to third parties or (2) use of the
#   Software or any derivative of it for research with the final aim of
#   developing software products for sale or license to a third party or
#   (3) use of the Software or any derivative of it for research with the
#   final aim of developing non-software products for sale or license to a
#   third party, or (4) use of the Software to provide any service to an
#   external organisation for which payment is received. If you are
#   interested in using the Software commercially, please contact Isis
#   Innovation Limited ("Isis"), the technology transfer company of the
#   University, to negotiate a licence. Contact details are:
#   innovation@isis.ox.ac.uk quoting reference DE/9564.


Usage() {
    echo ""
    echo "Usage: bedpostx <subject directory> [options]"
    echo ""
    echo "expects to find bvals and bvecs in subject directory"
    echo "expects to find data and nodif_brain_mask in subject directory"
#   echo "expects to find grad_dev in subject directory, if -g is set"
    echo "options (old syntax)"
    echo "-n (number of fibres per voxel, default 2)"
    echo "-w (ARD weight, more weight means less secondary fibres per voxel, default 1)"
    echo "-b (burnin period, default 1000)"
    echo "-j (number of jumps, default 1250)"
    echo "-s (sample every, default 25)"
    echo "-model (1 for monoexponential, 2 for multiexponential, default 1)"
#   echo "-g (consider gradient nonlinearities, default off)"
    echo ""
    echo ""
    echo "ALTERNATIVELY: you can pass on xfibres options onto directly bedpostx"
    echo " For example:  bedpostx <subject directory> --noard --cnonlinear"
    echo " Type 'xfibres --help' for a list of available options "
    echo " Default options will be bedpostx default (see above), and not xfibres default."
    echo ""
    echo "Note: Use EITHER old OR new syntax."
    exit 1
}

make_absolute(){
    dir=$1;
    if [ -d ${dir} ]; then
	OLDWD=`pwd`
	cd ${dir}
	dir_all=`pwd`
	cd $OLDWD
    else
	dir_all=${dir}
    fi
    echo ${dir_all}
}

[ "$1" = "" ] && Usage

subjdir=`make_absolute $1`
subjdir=`echo $subjdir | sed 's/\/$/$/g'`

echo subjectdir is $subjdir

#parse option arguments
nfibres=2
fudge=1
burnin=1000
njumps=1250
sampleevery=25
model=1
gflag=0

shift
while [ ! -z "$1" ]
do
  case "$1" in
      -n) nfibres=$2;shift;;
      -w) fudge=$2;shift;;
      -b) burnin=$2;shift;;
      -j) njumps=$2;shift;;
      -s) sampleevery=$2;shift;;
      -model) model=$2;shift;;
      -g) gflag=1;; 
      *) break;;
  esac
  shift
done
opts="--nf=$nfibres --fudge=$fudge --bi=$burnin --nj=$njumps --se=$sampleevery --model=$model"
defopts="--cnonlinear"
opts="$opts $defopts $*"

#check that all required files exist

if [ ! -d $subjdir ]; then
	echo "subject directory $1 not found"
	exit 1
fi

if [ ! -e ${subjdir}/bvecs ]; then
	echo "${subjdir}/bvecs not found"
	exit 1
fi

if [ ! -e ${subjdir}/bvals ]; then
	echo "${subjdir}/bvals not found"
	exit 1
fi

if [ `${FSLDIR}/bin/imtest ${subjdir}/data` -eq 0 ]; then
	echo "${subjdir}/data not found"
	exit 1
fi

if [ ${gflag} -eq 1 ]; then
    if [ `${FSLDIR}/bin/imtest ${subjdir}/grad_dev` -eq 0 ]; then
	echo "${subjdir}/grad_dev not found"
	exit 1
    fi
fi

if [ `${FSLDIR}/bin/imtest ${subjdir}/nodif_brain_mask` -eq 0 ]; then
	echo "${subjdir}/nodif_brain_mask not found"
	exit 1
fi

echo Making bedpostx directory structure

mkdir -p ${subjdir}.bedpostX/
mkdir -p ${subjdir}.bedpostX/diff_slices
mkdir -p ${subjdir}.bedpostX/logs
mkdir -p ${subjdir}.bedpostX/logs/pid_${$}
mkdir -p ${subjdir}.bedpostX/xfms

#copy SCC queue submission template for subject
cp /imaging/scratch/VR_Lab/isiddiqui/VRMD/tractography/bedpostx/submitme_template.sh ${subjdir}.bedpostX/submitme.sh

#mailto=`whoami`@fmrib.ox.ac.uk
#echo Queuing preprocessing stages
echo Running preprocessing command
#preprocid=`${FSLDIR}/bin/fsl_sub -T 60 -m as -N bpx_preproc -l ${subjdir}.bedpostX/logs ${FSLDIR}/bin/bedpostx_preproc.sh ${subjdir} ${gflag}`
#echo "${FSLDIR}/bin/bedpostx_preproc.sh ${subjdir} ${gflag}" >> ${subjdir}.bedpostX/submitme.sh
${FSLDIR}/bin/bedpostx_preproc.sh ${subjdir} ${gflag}

#echo Queuing parallel processing stage
echo Preparing parallel processing commands
nslices=`${FSLDIR}/bin/fslval ${subjdir}/data dim3`
[ -f ${subjdir}.bedpostX/commands.txt ] && rm ${subjdir}.bedpostX/commands.txt

slice=0
while [ $slice -lt $nslices ]
do
    slicezp=`$FSLDIR/bin/zeropad $slice 4`
    if [ `$FSLDIR/bin/imtest ${subjdir}.bedpostX/diff_slices/data_slice_$slicezp/dyads1` -eq 1 ];then
	echo "slice $slice has already been processed"
    else
	if [ ${gflag} -eq 1 ]; then
	    gopts="$opts --gradnonlin=${subjdir}/grad_dev_slice_${slicezp}"
	else
	    gopts=$opts
	fi    
	echo "${FSLDIR}/bin/bedpostx_single_slice.sh ${subjdir} ${slice} $gopts" \
	    >> ${subjdir}.bedpostX/commands.txt
    fi
    slice=$(($slice + 1))
done

echo "parallel < ${subjdir}.bedpostX/commands.txt" >> ${subjdir}.bedpostX/submitme.sh
echo "echo \"BedpostX completed\"" >> ${subjdir}.bedpostX/submitme.sh

#bedpostid=`${FSLDIR}/bin/fsl_sub -j $preprocid -l ${subjdir}.bedpostX/logs -M $mailto -N bedpostx -t ${subjdir}.bedpostX/commands.txt`

#echo Queuing post processing stage
echo Preparing post processing command
#mergeid=`${FSLDIR}/bin/fsl_sub -j $bedpostid -T 60 -m as -N bpx_postproc -l ${subjdir}.bedpostX/logs ${FSLDIR}/bin/bedpostx_postproc.sh $subjdir`
echo "${FSLDIR}/bin/bedpostx_postproc.sh $subjdir" >> ${subjdir}.bedpostX/submitme.sh
echo "echo \"Post processing completed\"" >> ${subjdir}.bedpostX/submitme.sh

echo "Done."
