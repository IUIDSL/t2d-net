#!/bin/sh
#############################################################################
### Go_CpdAnalysis.sh
###
### In project context, analysis of compounds found via SLAP, for research
### interest.  However, can be applied to any compound list with PubChem
### CIDs.
###
### Input CSV file contains: CID, SIDs, and synonyms.  Synonyms from PubChem
### and should be ordered by human-readability.
#############################################################################
set -x
set -e
#
CIDFILE="data/slap_dtp_merged.cid"
SMIFILE="data/slap_dtp_cpds.smi"
SDFFILE="data/slap_dtp_cpds.sdf"
CSVFILE="data/slap_dtp_cpds.csv"
NAMEFILE="data/slap_dtp_cpds.name"
SMINAMEDFILE="data/slap_dtp_cpds_named.smi"
#
#
python3 -m BioClients.pubchem.Client get_cid2smi \
	--i $CIDFILE \
	--o $SMIFILE
#
#SDF has properties:
python3 -m BioClients.pubchem.Client get_cid2sdf \
	--i $CIDFILE \
	--o $SDFFILE
#(Slow)
if [ ! -e $CSVFILE ]; then
	python3 -m BioClients.pubchem.Client get_cid2synonyms \
		--i $CIDFILE \
		--o $CSVFILE \
		-v
else
	printf "Exists; not overwriting: %s (%d lines)\n" $CSVFILE `cat $CSVFILE |wc -l`
fi
#
cat $CSVFILE \
	|awk -F ',' '{print $3}' \
	|sed -e '1d' \
	|sed -e 's/;.*$//' \
	|sed -e 's/"//g' \
	>$NAMEFILE
#
n_cid=`cat $CIDFILE |wc -l`
n_smi=`cat $SMIFILE |wc -l`
n_nam=`cat $NAMEFILE |wc -l`
#
printf "n_cid: %d\n" $n_cid
printf "n_smi: %d\n" $n_smi
printf "n_nam: %d\n" $n_nam
#
if [ $n_smi -eq $n_nam ]; then
	paste -d ":" $SMIFILE $NAMEFILE \
	>$SMINAMEDFILE
else
	printf "ERROR: n_smi!=n_nam: %d!=%d\n" $n_smi $n_nam
	exit
fi
#
#############################################################################
#QED (drug-likeness):
QEDFILE="data/slap_dtp_cpds_qed.smi"
qed.sh \
	-v \
	-i $SMINAMEDFILE \
	|sed -e '1d' \
	|awk '{print $1 " " $2 " " $20}' \
	|sort -n -k 3 -r \
	|perl -ne '@_=split(); printf "%s %s %.2f\n", $_[0],$_[1],$_[2]' \
	>$QEDFILE
#
cat $QEDFILE \
	|moltopdf \
	-cols 5 -rows 8 \
	-border \
	-pagesize US_Letter \
	-pagetitle "SLAP T2DM analysis compounds (sorted by QED score)" \
	-linewidth 1.0 \
	-in .smi \
	-out ${QEDFILE}.pdf
#
#############################################################################
#Drugbank xref:
CIDFILE_DRUG="data/slap_dtp_cpds_indrugbank.cid"
SDFFILE_DRUG="data/slap_dtp_cpds_indrugbank.sdf"
SMIFILE_DRUG="data/slap_dtp_cpds_indrugbank.smi"
CSVFILE_DRUG="data/slap_dtp_cpds_indrugbank.csv"
NAMEFILE_DRUG="data/slap_dtp_cpds_indrugbank.name"
SMINAMEDFILE_DRUG="data/slap_dtp_cpds_indrugbank_named.smi"
#
setman.py \
	--iA $CIDFILE \
	--iB ~/projects/DrugBank/data/drug_links.cid \
	--AandB \
	--o $CIDFILE_DRUG
#
python3 -m BioClients.pubchem.Client get_cid2smi \
	--i $CIDFILE_DRUG \
	--o $SMIFILE_DRUG
#
python3 -m BioClients.pubchem.Client get_cid2sdf \
	--i $CIDFILE_DRUG \
	--o $SDFFILE_DRUG
#
if [ ! -e $CSVFILE_DRUG ]; then
	python3 -m BioClients.pubchem.Client get_cid2synonyms \
		--i $CIDFILE_DRUG \
		--o $CSVFILE_DRUG \
		-v
else
	printf "Exists; not overwriting: %s (%d lines)\n" $CSVFILE_DRUG `cat $CSVFILE_DRUG |wc -l`
fi
#
cat $CSVFILE_DRUG \
	|awk -F ',' '{print $3}' \
	|sed -e '1d' \
	|sed -e 's/;.*$//' \
	|sed -e 's/"//g' \
	>$NAMEFILE_DRUG
#
n_cid=`cat $CIDFILE_DRUG |wc -l`
n_smi=`cat $SMIFILE_DRUG |wc -l`
n_nam=`cat $NAMEFILE_DRUG |wc -l`
#
printf "n_cid: %d\n" $n_cid
printf "n_smi: %d\n" $n_smi
printf "n_nam: %d\n" $n_nam
#
if [ $n_smi -eq $n_nam ]; then
	paste -d ":" $SMIFILE_DRUG $NAMEFILE_DRUG \
	>$SMINAMEDFILE_DRUG
else
	printf "ERROR: n_smi!=n_nam: %d!=%d\n" $n_smi $n_nam
fi
#
cat $SMINAMEDFILE_DRUG \
	|moltopdf \
	-cols 5 -rows 8 \
	-border \
	-pagesize US_Letter \
	-pagetitle "SLAP T2DM analysis compounds (also in DrugBank-approved)" \
	-linewidth 1.0 \
	-in .smi \
	-out ${SMINAMEDFILE_DRUG}.pdf
#
#############################################################################
