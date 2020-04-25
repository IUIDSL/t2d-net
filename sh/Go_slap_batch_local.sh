#!/bin/sh
#############################################################################
### Go_slap_batch_local.sh
### Currently must be run on cheminfov.informatics.indiana.edu
#############################################################################
#
HOST=`hostname`
if [ "$HOST" != "cheminfov.informatics.indiana.edu" ]; then
	echo "ERROR: Host not cheminfov."
	exit
fi
#
cwd=`pwd`
#
ifile=$cwd/data/t2dm_dtp_slap_in.txt
#
cat $cwd/data/t2dm_dtp_links.csv \
	|sed '1d' \
	|awk -F ',' '{print $1 "\t" $2}' \
	|sed -e 's/"//g' \
	>$ifile
#
ofile=$cwd/data/t2dm_dtp_slap_out.txt
#
printf "input: %d" `cat $ifile |wc -l`
#
ppPairPrediction_local.py \
	$ifile \
	$ofile
#
printf "output: %d" `cat $ofile |wc -l`
#
