#!/bin/bash
###
# The Pg port has been closed to outside IU.
# So now requires different instance/credentials.
#
set -x
#
DBHOST="cheminfov.informatics.indiana.edu"
DBSCHEMA="public"
DBNAME="chord"
DBUSR="==REPLACE_WITH_USERNAME=="
#
cwd="$(pwd)"
OUTDIR="${cwd}/tmp"
#
if [ ! -e "${OUTDIR}" ]; then
	mkdir ${OUTDIR}
fi
#
python3 -m BioClients.chem2bio2rdf.Client list_targets -v \
	--dbhost $DBHOST --dbschema $DBSCHEMA --dbname $DBNAME --dbusr $DBUSR \
	--o $OUTDIR/c2b2r_targets.tsv

#
python3 -m BioClients.chem2bio2rdf.Client list_genes -v \
	--dbhost $DBHOST --dbschema $DBSCHEMA --dbname $DBNAME --dbusr $DBUSR \
	--o $OUTDIR/c2b2r_genes.tsv
#
