#!/bin/bash
#
cwd=$(pwd)
#
if [ "$(which cypher-shell)" ]; then
	CQLAPP="cypher-shell"
elif [ "$(which neo4j-client)" ]; then
	CQLAPP="neo4j-client"
else
	echo "ERROR: Neo4j/CQL client app not found."
	exit
fi
printf "CQLAPP = %s\n" "$CQLAPP"
#
$CQLAPP < cql/load_cytoscape_cyjs2tsv.cql
#
$CQLAPP < cql/load_extras.cql
#
$CQLAPP < cql/db_describe.cql
#
