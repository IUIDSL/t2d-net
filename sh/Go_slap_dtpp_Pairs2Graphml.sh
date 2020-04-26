#!/bin/sh
#############################################################################
### Go_slap_dtpp_Pairs2Graphml.sh
### SLAP mode: Pairwise drug target pair prediction
### For specific cpd-tgt pairs, generate network (Graphml) files.
#############################################################################
PROG=$0
#
IFILE="data/t2dm_dtp_links.csv"
#
ODIR="data"
#
N=`cat $IFILE |wc -l`
N=`expr $N - 1`
#
date
#
printf "%s: input file: %s (N=%d)\n" $PROG $IFILE $N
#
I=0
#
while [ $I -lt $N ]; do
	#
	I=`expr $I + 1`
	#
	line=`cat $IFILE |sed -e "1,${I}d" |head -1`
	CID=`echo "$line" |sed -e 's/,.*$//'`
	TID=`echo "$line" |sed -e 's/[0-9][0-9]*,"\([A-Z0-9][A-Z0-9]*\)".*$/\1/'`
	#
	printf "%d.  CID: %s  TID: %s\n" $I $CID $TID
	#
	python3 -m BioClients.chem2bio2rdf.slap.Client DTP \
		--cids $CID \
		--tids $TID \
		--odir ${ODIR} \
		-v -v
	#
done
#
printf "%s: done.\n" $PROG
date
#
