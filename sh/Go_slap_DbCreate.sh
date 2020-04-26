#!/bin/sh
###
#
DATADIR="`pwd`/data"
#
cat "${DATADIR}/diabetes_drugs.smi" \
	|perl -pe 's/^([^\s]*)\s+([^\s]*)\s+(.*)$/$1\t$2\t$3/' \
	>"${DATADIR}/diabetes_drugs.tmp"
#
pandas_utils.py set_header --tsv \
	--i "${DATADIR}/diabetes_drugs.tmp" \
	--coltags "smiles,name,cid" \
	--o "${DATADIR}/diabetes_drugs.tsv"
#
pandas_utils.py set_header --tsv \
	--i "${DATADIR}/t2dm_dtp_slap_out.txt" \
	--coltags "cid,tid,ascore,pvalue,result" \
	--o "${DATADIR}/t2dm_dtp_slap_out.tsv"
#
tsvfiles="${DATADIR}/diabetes_drugs.tsv \
${DATADIR}/c2b2r_targets.tsv  \
${DATADIR}/t2dm_dtp.tsv \
${DATADIR}/t2dm_dtp_slap_out.tsv"
#
DBNAME="slap"
#
PSQLOPTS="-q"
#
createdb $DBNAME
psql -d $DBNAME -c "COMMENT ON DATABASE $DBNAME IS 'SLAP Studies: (1) T2DM (Type 2 Diabetes Melitis)"
#
#############################################################################
#
for tsvfile in $tsvfiles ; do
	csv2sql.py --dbsystem "postgres" --tsv \
		--i $tsvfile --fixtags --create \
		|psql $PSQLOPTS $DBNAME
	#
	csv2sql.py --dbsystem "postgres" --tsv \
		--i $tsvfile --fixtags --nullify --insert \
		|psql $PSQLOPTS $DBNAME
	#
done
#
psql $PSQLOPTS -d $DBNAME -c "UPDATE t2dm_dtp SET score = NULL where score = ''"
psql $PSQLOPTS -d $DBNAME -c "UPDATE t2dm_dtp SET error = NULL where error = ''"
#
