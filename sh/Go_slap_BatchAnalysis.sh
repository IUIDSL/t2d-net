#!/bin/sh
#############################################################################
### Go_slap_BatchAnalysis.sh
### Analyze results of SLAP drug-target predictions, as generated
### to CSV file by slap_query.py, SLAP REST API client.
###
### Jeremy Yang
### 12 Feb 2014
#############################################################################
PROG=$0
#
DATADIR=data
IFILE=$DATADIR/t2dm_dtp.csv
#
ifile_base=`basename $IFILE |sed -e 's/\..*$//'`
#
printf "%s: input file: %s (%d lines)\n" $PROG $IFILE `cat $IFILE |wc -l`
#
### Compounds, unique count:
printf "%s: total cids: %d\n" $PROG `cat $IFILE \
	|sed -e '1d' \
	|awk -F ',' '{print $1}' \
	|sort -u \
	|wc -l`
#
### Targets, unique count:
printf "%s: total tids: %d\n" $PROG `cat $IFILE \
	|sed -e '1d' \
	|awk -F ',' '{print $2}' \
	|sed -e 's/"//g' \
	|sort -u \
	|wc -l`
#
### Write file of all links:
linksfile=$DATADIR/${ifile_base}_links.csv
cat $IFILE |grep -v ",," >$linksfile
n_link=`cat ${linksfile} |wc -l`
printf "%s: links: %d\n" $PROG $n_link
#
### Write file of all linked compounds (CIDs):
link_cidfile=$DATADIR/${ifile_base}_links.cid
cat ${linksfile} \
	|sed -e '1d' \
	|awk -F ',' '{print $1}' \
	|sort -nu \
	>$link_cidfile
n_link_cid=`cat $link_cidfile |wc -l`
printf "%s: cids: %d\n" $PROG $n_link_cid
#
### Write file of all linked targets (TIDs):
link_tidfile=$DATADIR/${ifile_base}_links.tid
cat ${linksfile} \
	|sed -e '1d' \
	|awk -F ',' '{print $2}' \
	|sed -e 's/"//g' \
	|sort -u \
	>$link_tidfile
n_link_tid=`cat $link_tidfile |wc -l`
printf "%s: tids: %d\n" $PROG $n_link_tid
#
### Query targets not found by SLAP:
tidfile_notfound=$DATADIR/${ifile_base}_links_notfound.tid
cat ${IFILE} \
	|sed -e '1d' \
	|grep 'target was not found' \
	|awk -F ',' '{print $2}' \
	|sed -e 's/"//g' \
	|sort -u \
	>$tidfile_notfound
n_tid_notfound=`cat $tidfile_notfound |wc -l`
printf "%s: tids_notfound: %d\n" $PROG $n_tid_notfound
#
