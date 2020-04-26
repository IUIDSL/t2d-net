#!/bin/bash
#############################################################################
### Go_drug_Lookup.sh - Learn about drugs via online APIs, from names, 
### PubChem CIDs, or other IDs.
#############################################################################

### Smifile format "SMI NAME CID"

cwd=$(pwd)
DATADIR="${cwd}/data"
OUTDIR="${cwd}/data/tmp"

if [ ! -e "$OUTDIR" ]; then
	mkdir $OUTDIR
fi

SMIFILE="$DATADIR/diabetes_drugs.smi"
NAMEFILE="$OUTDIR/diabetes_drugs.name"
CIDFILE="$OUTDIR/diabetes_drugs.cid"
RXCUIFILE="$OUTDIR/diabetes_drugs.rxcui"
OFILE="$OUTDIR/diabetes_drugs_rxnorm.tsv"
#
cat $SMIFILE |awk '{print $2}' >$NAMEFILE
cat $SMIFILE |awk '{print $3}' >$CIDFILE
#
echo "N_smi = $(cat $SMIFILE |wc -l)"
echo "N_cid = $(cat $CIDFILE |wc -l)"
#
python3 -m BioClients.rxnorm.Client get_name2rxcui \
	--i "$NAMEFILE" \
	|sed -e '1d' |awk -F '\t' '{print $2}' \
	|perl -ne 'print if /\S/' \
	>$RXCUIFILE
echo "N_rxcui = $(cat $RXCUIFILE |wc -l)"
#
python3 -m BioClients.rxnorm.Client get_rxcui_allproperties -v \
	--i $RXCUIFILE --o $OFILE
#
