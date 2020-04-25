#!/bin/sh
#
DB="scratch"
SCHEMA="slap"
#
psql -d ${DB} -c "DROP SCHEMA ${SCHEMA} CASCADE"
#
#tables=`psql -q -d $DB -tAc "SELECT table_name FROM information_schema.tables WHERE table_schema='$SCHEMA'"`
#for table in $tables ; do
#	sql="DROP TABLE ${SCHEMA}.${table} CASCADE"
#	echo "$sql"
#	psql ${DB} -c "$sql"
#done
#
