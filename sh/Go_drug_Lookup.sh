#!/bin/bash
#############################################################################
### Go_drug_Lookup.sh - Learn about drugs via online APIs, from names, 
### PubChem CIDs, or other IDs.
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
	rxcui=$(python3 -m BioClients.rxnorm.Client get_name2rxcui --ids "$name"|sed -e '1d' |awk -F '\t' '{print $2}')
	printf "NAME:\"%s\" -> RxCUI:%s\n" "${name}" "${rxcui}"
	python3 -m BioClients.rxnorm.Client get_classes_atc --ids "$rxcui"
	python3 -m BioClients.rxnorm.Client get_classes_mesh --ids "$rxcui"
	python3 -m BioClients.rxnorm.Client get_classes_ndfrt --ndfrt_type MOA --ids "$rxcui"
	python3 -m BioClients.rxnorm.Client get_classes_ndfrt --ndfrt_type PE --ids "$rxcui"
	#
done
