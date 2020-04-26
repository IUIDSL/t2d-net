#!/bin/sh
#
set -x
#
DBHOST="cheminfov.informatics.indiana.edu"
DBUSR="cicc3"
DBNAME="chord"
DBSCHEMA="public"
#
pg_dump -v \
	--schema=$DBSCHEMA \
	--table=$DBSCHEMA.c2b2r_biogrid \
	-h $DBHOST -U $DBUSR $DBNAME \
	|gzip -c \
	> $HOME/Downloads/c2b2r_biogrid_pgdump.sql.gz
#
