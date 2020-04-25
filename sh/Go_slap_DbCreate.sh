#!/bin/sh
### "CREATE SCHEMA IF NOT EXISTS" requires Postgresql v9.3+.
#
DATADIR="`pwd`/data"
#
cat "${DATADIR}/diabetes_drugs.smi" \
	| perl -pe 's/^([^\s]*)\s+([^\s]*)\s+(.*)$/"$1","$2","$3"/' \
	>"${DATADIR}/diabetes_drugs.csv"
#
csv_utils.py --i "${DATADIR}/diabetes_drugs.csv" \
	--addheader "smiles,name,cid" \
	--overwrite_input_file
#
csv_utils.py --i "${DATADIR}/t2dm_dtp_slap_out.txt" \
	--tsv2csv \
	--o "${DATADIR}/t2dm_dtp_slap_out.csv"
#
csv_utils.py --i "${DATADIR}/t2dm_dtp_slap_out.csv" \
	--addheader "cid,tid,ascore,pvalue,result" \
	--overwrite_input_file
#
csvfiles="${DATADIR}/diabetes_drugs.csv \
${DATADIR}/c2b2r_targets.csv  \
${DATADIR}/t2dm_dtp.csv \
${DATADIR}/t2dm_dtp_slap_out.csv"
#
for csvfile in $csvfiles ; do
	printf "%s:\n" "${csvfile}"
	csv_utils.py --i "${csvfile}"
done
#
DB="scratch"
SCHEMA="slap"
#
PSQLOPTS="-q"
#
psql $DB <<__EOF__
CREATE SCHEMA $SCHEMA ;
COMMENT ON SCHEMA $SCHEMA IS 'SLAP Studies: (1) T2DM (Type 2 Diabetes Melitis)' ;
__EOF__
#############################################################################
#
for csvfile in $csvfiles ; do
	csv2sql.py \
		--i $csvfile \
		--schema "$SCHEMA" \
		--fixtags \
		--create \
		--o ${csvfile}_create.sql
	#
	psql $PSQLOPTS $DB -f ${csvfile}_create.sql
	#
	csv2sql.py \
		--i $csvfile \
		--schema "$SCHEMA" \
		--fixtags \
		--nullify \
		--insert \
		--o ${csvfile}_insert.sql
	#
	psql $PSQLOPTS $DB -f ${csvfile}_insert.sql
	#
done
#
psql $PSQLOPTS -d $DB -c "UPDATE $SCHEMA.t2dm_dtp SET score = NULL where score = ''"
psql $PSQLOPTS -d $DB -c "UPDATE $SCHEMA.t2dm_dtp SET error = NULL where error = ''"
#
