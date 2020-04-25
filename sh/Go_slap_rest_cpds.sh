#!/bin/sh
#
#
BASE_URI='http://cheminfov.informatics.indiana.edu/rest/Chem2Bio2RDF/slap'
#
#
CIDS="1989 2727 3476 3478 3488 4091 441314 5311309 4829 16132446 65981 77999 4369359 5503 5505 5991"
#
set -x
#
for CID in $CIDS ; do
	rest_request.py --uri "${BASE_URI}/cid=${CID}"
done
#
