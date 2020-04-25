#!/bin/sh
#
### For now, no synonyms.  Only generation of a de-duplicated target ID list.
#
DATADIR="data"
TIDFILE="data/slap_dtp_merged.tid"
#
#
I=0
#
#Targets:
#
for ifile in `ls $DATADIR/*.graphml` ; do
	#
	I=`expr $I + 1`
	printf "%d. %s\n" $I $ifile
	ifile_basename=`basename $ifile |sed -e 's/\..*$//'`
	#
	$HOME/utils/slap_utils.py \
		--graphml2tids \
		--igraphml $ifile \
		--o ${DATADIR}/${ifile_basename}_graphml.tid \
		--v
	#
done
#
cat ${DATADIR}/*_graphml.tid \
	|sort -u \
	>$TIDFILE
printf "unique tids: %d\n" `cat $TIDFILE |wc -l`
#
#
