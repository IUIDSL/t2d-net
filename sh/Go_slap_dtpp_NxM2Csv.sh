#!/bin/sh
#
# SLAP mode: drug target pair prediction
#
BASE_URI='http://cheminfov.informatics.indiana.edu/rest/Chem2Bio2RDF/slap'
#
#
CIDFILE="data/diabetes_drugs.cid"
TIDFILE="data/protein_list.id"
#
OFILE="data/t2dm_dtp.csv"
#
set -x
#
###OBSOLETE:#################################################################
#for CID in $CIDS ; do
#	for GENE in $GENES ; do
#		ofile=data/${CID}_${GENE}.out
#		gfile=data/${CID}_${GENE}.graphml
#		echo "CID=${CID}, GENE=${GENE}, ofile: ${ofile}"
#		rest_request.py --uri "${BASE_URI}/${CID}:${GENE}" >$ofile
#		cat ${ofile} \
#			| sed -n -e '/<graphml/,/<\/graphml>/p' \
#			> ${gfile}
#	done
#done
#############################################################################
#
# For 16 cpds, 2228 tgts (35648 queries) this took 2.5 days.
#
$HOME/utils/slap_query.py \
	--dtp \
	--cidfile $CIDFILE \
	--tidfile $TIDFILE \
	--o $OFILE \
	--vv
#
