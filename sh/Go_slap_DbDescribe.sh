#!/bin/sh
#
DB="scratch"
SCHEMA="slap"
#
tables=`psql -q -d $DB -tAc "SELECT table_name FROM information_schema.tables WHERE table_schema='$SCHEMA'"`
#
for table in $tables ; do
	if [ `echo "$table" |egrep '(^diabetes|^t2dm|^c2b2r)'` ]; then
		echo $table
		psql -P pager=off -q -d $DB -c "SELECT column_name,data_type FROM information_schema.columns WHERE table_schema='$SCHEMA' AND table_name = '$table'"
		psql -q -d $DB -c "SELECT count(*) AS \"${table}_count\" FROM $SCHEMA.$table"
	fi
done
