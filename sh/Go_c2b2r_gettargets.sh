#!/bin/sh
#
set -x
#
DBHOST="cheminfov.informatics.indiana.edu"
DBSCHEMA="public"
DBNAME="chord"
DBUSR="cicc3"
#
#
python3 -m BioClients.chem2bio2rdf.Client gettargets -v \
	--dbhost $DBHOST --dbschema $DBSCHEMA --dbname $DBNAME --dbusr $DBUSR \
	--o data/c2b2r_targets.tsv

#
python3 -m BioClients.chem2bio2rdf.Client gettargets getgenes -v \
	--dbhost $DBHOST --dbschema $DBSCHEMA --dbname $DBNAME --dbusr $DBUSR \
	--o data/c2b2r_genes.tsv
#
