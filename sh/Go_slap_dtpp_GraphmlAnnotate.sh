#!/bin/sh
#############################################################################
### Go_slap_dtpp_GraphmlAnnotate.sh
### Use names/IDs from input CSV files to annotate SLAP network
### (Graphml) files.
#############################################################################
PROG=$0
#
DATADIR="data"
ODIR="data/annotated"
#
CPDFILE="data/slap_dtp_cpds.csv"
TGTFILE="data/c2b2r_targets.csv"
#
printf "%s: compound file: %s\n" $PROG $CPDFILE
printf "%s: target file: %s\n" $PROG $TGTFILE
#
I=0
#
for ifile in `ls $DATADIR/*.graphml` ; do
	#
	I=`expr $I + 1`
	printf "%d. %s\n" $I $ifile
	ifile_basename=`basename $ifile |sed -e 's/\..*$//'`
	#
	python3 -m BioClients.chem2bio2rdf.slap.Utils dtp_annotate \
		--i_tgts $TGTFILE \
		--i_cpds $CPDFILE \
		--i_graphml $ifile \
		--o ${ODIR}/${ifile_basename}_annotated.graphml \
		-v
	#
done
#
### Merge ALL network files to one.
OFILE_GRAPHML_ALL="slap_dtp_merged.graphml"
#
python3 -m BioClients.chem2bio2rdf.slap.Utils dtp_annotate graphmls_merge \
	--i_graphml_dir ${ODIR} \
	--o ${OFILE_GRAPHML_ALL} \
	-v -v
#
printf "%s: done.\n" $PROG
