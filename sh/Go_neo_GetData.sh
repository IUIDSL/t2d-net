#!/bin/bash
#
cwd=$(pwd)
#
cat ${cwd}/data/slap_dtp_merged_nodes_compounds.tsv \
	|perl -pe 's/\r\n*/\n/g;' \
	|awk -F '\t' '{print $6}' \
	|sed -e '1d' |grep -v '^ *$'|sort -nu \
	>${cwd}/data/slap_dtp_merged_nodes_compounds.cid
#
printf "CIDS: %d\n" $(cat ${cwd}/data/slap_dtp_merged_nodes_compounds.cid |wc -l)
#
pubchem_query.py \
	--i ${cwd}/data/slap_dtp_merged_nodes_compounds.cid \
	--o ${cwd}/data/slap_dtp_merged_nodes_compounds.sdf \
	--cids2sdf
#
molconvert 'smiles:T*' \
	${cwd}data/slap_dtp_merged_nodes_compounds.sdf \
	|sed -e 's/^#//' \
	>${cwd}data/slap_dtp_merged_nodes_compounds.tsv 
#
