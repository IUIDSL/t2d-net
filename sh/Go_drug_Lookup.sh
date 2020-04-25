#!/bin/sh
#############################################################################
### Go_drug_Lookup.sh - Learn about drugs via online APIs, from names, 
### PubChem CIDs, or other IDs.
### 
### Jeremy Yang
###  8 Jul 2014
#############################################################################

### Smifile format "SMI NAME CID"

SMIFILE="data/diabetes_drugs.smi"
CIDFILE="data/diabetes_drugs.cid"

N=`cat $SMIFILE |wc -l`
echo "N = $N"


i=0
while [ $i -lt $N ]; do
	i=`expr $i + 1`
	name=`cat $SMIFILE |sed -n ${i}p |awk '{print $2}'`
	if [ ! "$name" ]; then
		break
	fi
	#
	rxnorm_query.py --v --name "$name" --name2rxcuis --get_classes_atc
	rxnorm_query.py --v --name "$name" --name2rxcuis --get_classes_mesh
	rxnorm_query.py --v --name "$name" --name2rxcuis --get_classes_ndfrt --ndfrt_type MOA
	rxnorm_query.py --v --name "$name" --name2rxcuis --get_classes_ndfrt --ndfrt_type PE
	#
done
