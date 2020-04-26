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
	BioClients.chem2bio2rdf.slap.Utils graphml2cids \
		--i_graphml $ifile \
		--o ${DATADIR}/${ifile_basename}_graphml.cid \
		-v
	#
done
#
cat ${DATADIR}/*_graphml.cid \
	|sort -nu \
	>$CIDFILE
printf "unique cids: %d\n" `cat $CIDFILE |wc -l`
#
#
python3 -m BioClients.pubchem.Client get_cid2synonyms \
	--i $CIDFILE \
	--o $CPDFILE \
	-v
#
#
