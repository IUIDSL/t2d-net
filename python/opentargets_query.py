#!/usr/bin/env python3
#############################################################################
# OpenTargets REST API client, using the client Python package
#
# https://www.targetvalidation.org/documentation/api/
# http://opentargets.readthedocs.io/
#
# https://docs.targetvalidation.org/programmatic-access/rest-api
# https://platform-api.opentargets.io/v3/platform
# https://platform-api.opentargets.io/v3/platform/docs/swagger-ui
#############################################################################
import sys,os,argparse,json,logging
import csv #replace with pandas?
import opentargets as ot

#############################################################################
def Target2Associations(otc, ids, minscore, skip, nmax, fout):
  csvWriter = csv.writer(fout, delimiter='\t', quotechar='"', quoting=csv.QUOTE_NONNUMERIC)
  tags=None;
  i_tgt=0; n_assn=0; n_tgt_found=0;
  for tgtid in ids:
    i_tgt+=1
    if i_tgt<=skip: continue
    logging.debug('%s:'%tgtid)
    try:
      assns = otc.get_associations_for_target(tgtid)
    except Exception as e:
      if e.args:
        logging.error(str(e.args))
      assns=[]
    if assns:
      n_tgt_found+=1
    for assn in assns:
      logging.debug(json.dumps(assn, sort_keys=True, indent=2))
      if not tags:
        tags=["id","is_direct","target_id","gene_name","gene_symbol",
	"disease_id","disease_efo_label","score_overall"]
        tags_assn_score_sources=list(assn['association_score']['datasources'].keys())
        tags_assn_score_types=list(assn['association_score']['datatypes'].keys())
        tags_evidence_count_sources=list(assn['evidence_count']['datasources'].keys())
        tags_evidence_count_types=list(assn['evidence_count']['datatypes'].keys())
        csvWriter.writerow(tags+
		list(map(lambda t:'assn_score_source:%s'%t,tags_assn_score_sources))+
		list(map(lambda t:'assn_score_type:%s'%t,tags_assn_score_types))+
		list(map(lambda t:'evidence_count_source:%s'%t,tags_evidence_count_sources))+
		list(map(lambda t:'evidence_count_type:%s'%t,tags_evidence_count_types)))
      assn_id = assn['id'] if 'id' in assn else ''
      is_direct = assn['is_direct'] if 'is_direct' in assn else ''
      target_id = assn['target']['id'] if 'target' in assn and 'id' in assn['target'] else ''
      gene_name = assn['target']['gene_info']['name'] if 'target' in assn and 'gene_info' in assn['target'] and 'name' in assn['target']['gene_info'] else ''
      gene_symbol = assn['target']['gene_info']['symbol'] if 'target' in assn and 'gene_info' in assn['target'] and 'symbol' in assn['target']['gene_info'] else ''
      disease_id = assn['disease']['id'] if 'disease' in assn and 'id' in assn['disease'] else ''
      disease_efo_label = assn['disease']['efo_info']['label'] if 'disease' in assn and 'efo_info' in assn['disease'] and 'label' in assn['disease']['efo_info'] else ''
      score_overall = assn['association_score']['overall'] if 'association_score' in assn and 'overall' in assn['association_score'] else ''
      vals=[assn_id, is_direct, target_id, gene_name, gene_symbol,
	disease_id, disease_efo_label, score_overall]
      for tag in tags_assn_score_sources:
        vals.append(assn['association_score']['datasources'][tag] if tag in assn['association_score']['datasources'] else '')
      for tag in tags_assn_score_types:
        vals.append(assn['association_score']['datatypes'][tag] if tag in assn['association_score']['datatypes'] else '')
      for tag in tags_evidence_count_sources:
        vals.append(assn['evidence_count']['datasources'][tag] if tag in assn['evidence_count']['datasources'] else '')
      for tag in tags_evidence_count_types:
        vals.append(assn['evidence_count']['datatypes'][tag] if tag in assn['evidence_count']['datatypes'] else '')

      for i in range(len(vals)):
        if type(vals[i]) is float:
          vals[i]=round(vals[i],5)
      csvWriter.writerow(vals)

      n_assn+=1
    logging.debug('i_tgt=%d ; skip=%d ; nmax=%d'%(i_tgt, skip, nmax))
    if nmax and i_tgt-skip>=nmax: break
    if i_tgt%1000==0:
      logging.info('i_tgt=%d ; n_tgt = %d ; n_tgt_found = %d ; n_assn = %d'%(i_tgt, i_tgt-skip, n_tgt_found, n_assn))
  logging.info('n_tgt = %d ; n_tgt_found = %d ; n_assn = %d'%(i_tgt-skip, n_tgt_found, n_assn))

#############################################################################
if __name__=='__main__':
  parser = argparse.ArgumentParser(description='OpenTargets REST API client utility, using opentargets package')
  ops = ['tgt2assns', 'getEvidence']
  parser.add_argument("op", choices=ops, help='operation')

  parser.add_argument("--i", dest="ifile", help="input file, target IDs")
  parser.add_argument("--tids", help="target IDs, gene symbol or ENSEMBL, comma-separated")
  parser.add_argument("--did", help="disease ID, EFO symbol")
  parser.add_argument("--minscore", type=float, help="minimum overall association score")
  parser.add_argument("--nmax", type=int, help="max results")
  parser.add_argument("--skip", type=int, help="skip results", default=0)
  parser.add_argument("--o", dest="ofile", help="output (TSV)")
  parser.add_argument("-v", "--verbose", dest="verbose", action="count", default=0)

  args = parser.parse_args()

  logging.basicConfig(format='%(levelname)s:%(message)s', level=(logging.DEBUG if args.verbose>1 else logging.INFO))

  if args.ofile:
    fout=open(args.ofile,"w+")
    if not fout: parser.error('Cannot open: %s'%args.ofile)
  else:
    fout=sys.stdout

  tids=[];
  if args.ifile:
    fin=open(args.ifile)
    if not fin: parser.error('Cannot open: %s'%args.ifile)
    while True:
      line=fin.readline()
      if not line: break
      id_this=line.rstrip()
      if id_this: tids.append(id_this)
    logging.info('input queries: %d'%(len(tids)))
    fin.close()
  elif args.tids:
    tids = re.split('[, ]+', args.tids.strip())

  otc = ot.OpenTargetsClient()

  logging.debug(otc.get_stats().info)

  if args.op=='tgt2assns':
    if not tids:
      parser.error('--i or --tids required.')
    Target2Associations(otc, tids, args.minscore, args.skip, args.nmax, fout)

  elif args.op=='getEvidence':
    if not tids and args.did:
      parser.error('--i or --tids required.')
    #Target2Disease_Evidence(otc, tid, args.did, fout)

  else:
    parser.print_help("Invalid operation: %s"%args.op)

