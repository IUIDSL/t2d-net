#!/bin/sh
#
set -x
#
DBH=cheminfov.informatics.indiana.edu
DBP=5432
DBU=cicc3
DB=chord
SCHEMA=public
#
#
$HOME/utils/c2b2r_query.py \
	--gettargets \
	--o data/c2b2r_targets.csv \
	--v
#
$HOME/utils/c2b2r_query.py \
	--getgenes \
	--o data/c2b2r_genes.csv \
	--v
#
