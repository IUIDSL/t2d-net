#!/bin/sh
#
set -x
#
DBH=cheminfov.informatics.indiana.edu
#DBH=localhost
DBP=5432
DBU=cicc3
DB=chord
SCHEMA=public
#
#	--data-only \
#
pg_dump \
	--schema=$SCHEMA \
	--table=$SCHEMA.c2b2r_biogrid \
	-v \
	-h $DBH -p $DBP -U $DBU $DB \
	|gzip -c \
	> $HOME/Download/c2b2r_biogrid_pgdump.sql.gz
#
