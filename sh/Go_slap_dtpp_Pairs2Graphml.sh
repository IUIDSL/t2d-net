#!/bin/sh
#############################################################################
### Go_slap_dtpp_Pairs2Graphml.sh
### SLAP mode: Pairwise drug target pair prediction
### For specific cpd-tgt pairs, generate network (Graphml) files.
###
### Jeremy Yang
### 12 Feb 2014
#############################################################################
PROG=$0
#
BASE_URI='http://cheminfov.informatics.indiana.edu/rest/Chem2Bio2RDF/slap'
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
	slap_query.py \
		--dtp \
		--cid $CID \
		--tid $TID \
		--odir ${ODIR} \
		--vv
	#
done
#
printf "%s: done.\n" $PROG
date
#
