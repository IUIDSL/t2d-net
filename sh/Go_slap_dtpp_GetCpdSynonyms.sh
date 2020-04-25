#!/bin/sh
#
#
#
#
DATADIR="data"
CIDFILE="data/slap_dtp_merged.cid"
CPDFILE="data/slap_dtp_cpds.csv"
#
#
I=0
#
#Compounds:
#
for ifile in `ls $DATADIR/*.graphml` ; do
	#
	I=`expr $I + 1`
	printf "%d. %s\n" $I $ifile
	ifile_basename=`basename $ifile |sed -e 's/\..*$//'`
	#
	$HOME/utils/slap_utils.py \
		--graphml2cids \
		--igraphml $ifile \
		--o ${DATADIR}/${ifile_basename}_graphml.cid \
		--v
	#
done
#
cat ${DATADIR}/*_graphml.cid \
	|sort -nu \
	>$CIDFILE
printf "unique cids: %d\n" `cat $CIDFILE |wc -l`
#
#
pug_rest_query.py \
	--cpds2synonyms \
	--i $CIDFILE \
	--o $CPDFILE \
	--v
#
#
