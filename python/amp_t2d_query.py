#!/usr/bin/env python3
##############################################################################
### utility app for the AMP T2D REST API.
### http://www.type2diabetesgenetics.org/
### http://www.kp4cd.org/apis/t2d
### http://52.54.103.84/kpn-kb-openapi/
##############################################################################
### DEPICT software (Pers, TH, et al., 2015)
##############################################################################
import sys,os,re,json,argparse,time,logging
#
import rest_utils
#
API_HOST='public.type2diabeteskb.org'
API_BASE_PATH='/dccservices'
#
#############################################################################
def ListTissues(base_url, fout):
  rval=rest_utils.GetURL(base_url+'/graph/tissue/list/object', parse_json=True)
  #logging.debug(json.dumps(rval, indent=2))
  tissues = rval["data"] if "data" in rval else []
  tags = None; n_out=0;
  for tissue in tissues:
    if not tags:
      tags = tissue.keys()
      fout.write('\t'.join(tags)+'\n')
    vals = [str(tissue[tag]) if tag in tissue else '' for tag in tags]
    fout.write('\t'.join(vals)+'\n')
    n_out += 1
  logging.info("n_out: %d"%(n_out))

#############################################################################
def ListPhenotypes(base_url, fout):
  rval=rest_utils.GetURL(base_url+'/graph/phenotype/list/object', parse_json=True)
  #logging.debug(json.dumps(rval, indent=2))
  phenotypes = rval["data"] if "data" in rval else []
  tags = None; n_out=0;
  for phenotype in phenotypes:
    if not tags:
      tags = phenotype.keys()
      fout.write('\t'.join(tags)+'\n')
    vals = [str(phenotype[tag]) if tag in phenotype else '' for tag in tags]
    fout.write('\t'.join(vals)+'\n')
    n_out += 1
  logging.info("n_out: %d"%(n_out))

##############################################################################
def DepictGenePathway(base_url, gene, phenotype, max_pval, fout):
  url = base_url+('/testcalls/depict/genepathway/object?gene=%s&phenotype=%s&lt_value=%f'%(gene, phenotype, max_pval))
  rval = rest_utils.GetURL(url, parse_json=True)
  #logging.debug(json.dumps(rval, indent=2))
  pathways = rval["data"] if "data" in rval else []
  tags = None; n_out=0;
  for pathway in pathways:
    if not tags:
      tags = pathway.keys()
      fout.write('\t'.join(tags)+'\n')
    vals = [str(pathway[tag]) if tag in pathway else '' for tag in tags]
    fout.write('\t'.join(vals)+'\n')
    n_out += 1
  logging.info("n_out: %d"%(n_out))

##############################################################################
if __name__=='__main__':
  ops = ["list_tissues", "list_phenotypes",
	"depict_genepathway"
        ]
  parser = argparse.ArgumentParser(description="AMP T2D REST client")
  parser.add_argument("op",choices=ops,help='operation')
  parser.add_argument("--i", dest="ifile", help="input IDs file")
  parser.add_argument("--ids", help="input IDs, comma-separated")
  parser.add_argument("--gene", help="query gene (e.g. SLC30A8)")
  parser.add_argument("--phenotype", default="T2D")
  parser.add_argument("--max_pval", type=float, default=.0005)
  parser.add_argument("--api_host", default=API_HOST)
  parser.add_argument("--api_base_path", default=API_BASE_PATH)
  parser.add_argument("--skip", type=int, default=0)
  parser.add_argument("--nmax", type=int, default=0)
  parser.add_argument("--o", dest="ofile", help="output (TSV)")
  parser.add_argument("-v", "--verbose", default=0, action="count")
  args = parser.parse_args()

  logging.basicConfig(format='%(levelname)s:%(message)s', level=(
	logging.DEBUG if args.verbose>1 else logging.INFO))

  BASE_URL = 'http://'+args.api_host+args.api_base_path

  if args.ofile:
    fout = open(args.ofile, "w")
  else:
    fout = sys.stdout

  if args.ifile:
    fin = open(args.ifile)
    if not fin: parser.error('Cannot open: %s'%args.ifile)
    ids=[]
    while True:
      line = fin.readline()
      if not line: break
      ids.append(line.strip())
    logging.info('input IDs: %d'%(len(ids)))
    fin.close()
  elif args.ids:
    ids = re.split('[, ]+', args.ids.strip())

  t0=time.time()

  if args.op == 'list_tissues':
    ListTissues(BASE_URL, fout)

  elif args.op == 'list_phenotypes':
    ListPhenotypes(BASE_URL, fout)

  elif args.op == 'depict_genepathway':
    DepictGenePathway(BASE_URL, args.gene, args.phenotype, args.max_pval, fout)

  else:
    parser.error('Invalid operation: %s'%args.op)

  logging.info('elapsed time: %s'%(time.strftime('%Hh:%Mm:%Ss', time.gmtime(time.time()-t0))))

