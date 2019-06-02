#!/usr/bin/env python3
"""
Utility app for the PubChem PUG REST API.
"""
import sys,os,re,argparse
#
import pubchem_utils
#
PROG=os.path.basename(sys.argv[0])
#
API_HOST='pubchem.ncbi.nlm.nih.gov'
API_BASE_PATH='/rest/pug'
#
##############################################################################
if __name__=='__main__':
  PROG=os.path.basename(sys.argv[0])
  epilog=''
  parser = argparse.ArgumentParser(description='PubChem REST API client utility', epilog=epilog)
  ops = [ 'describe_assay', 'cpd_smi2id=', 'aid2name', 'assaydescriptions', 'assayresults',
	'sids2cids', 'cids2props', 'cids2smi', 'cids2sdf', 'sids2sdf', 'name2sids', 'name2cids',
	'cids2sids','cids2ism',
	'cids2inchi', 'cids2assaysummary', 'sids2assaysummary', 'cid2synonyms', 'cids2synonyms', 'list_assaysources', 'list_substancesources' ]
  parser.add_argument("op", choices=ops, help='operation')
  parser.add_argument("--i", dest="ifile", help="input IDs")
  parser.add_argument("--iaid", dest="ifile_aid", help="input AIDs")
  parser.add_argument("--id", type=int, help="ID, e.g. CID or SID")
  parser.add_argument("--aid", type=int, help="AID, assay ID")
  parser.add_argument("--api_host", default=API_HOST)
  parser.add_argument("--api_base_path", default=API_BASE_PATH)
  parser.add_argument("--nmax", type=int, help="max results")
  parser.add_argument("--skip", type=int, help="skip results", default=0)
  parser.add_argument("--o", dest="ofile", help="output (CSV)")
  parser.add_argument("-v", "--verbose", dest="verbose", action="count", default=0)

  args = parser.parse_args()

  BASE_URI='https://'+args.api_host+args.api_base_path

  if args.ofile:
    fout=open(args.ofile,"w+")
    if not fout: parser.error('ERROR: cannot open outfile: %s'%args.ofile)
  else:
    fout=sys.stdout

  ids=[]
  if args.ifile:
    fin=open(args.ifile)
    if not fin: ErrorExit('ERROR: cannot open ifile: %s'%args.ifile)
    while True:
      line=fin.readline()
      if not line: break
      try:
        ids.append(int(line.rstrip()))
      except:
        print('ERROR: bad input ID: %s'%line, file=sys.stderr)
        continue
    if args.verbose:
      print('%s: input IDs: %d'%(PROG,len(ids)), file=sys.stderr)
    fin.close()
  elif args.id:
    ids=[args.id]

  aids=[]
  if args.ifile_aid:
    fin=open(args.ifile_aid)
    if not fin: ErrorExit('ERROR: cannot open ifile: %s'%args.ifile_aid)
    while True:
      line=fin.readline()
      if not line: break
      try:
        aids.append(int(line.rstrip()))
      except:
        print('ERROR: bad input AID: %s'%line, file=sys.stderr)
        continue
    if args.verbose:
      print('%s: input AIDs: %d'%(PROG,len(aids)), file=sys.stderr)
    fin.close()
  elif args.aid:
    aids=[args.aid]

  if args.op=='describe_assay':
    pubchem_utils.DescribeAssay(BASE_URI,aids,verbose)

  elif args.op=='list_assaysources':
    pubchem_utils.ListAssaySources(BASE_URI,fout,verbose)

  elif args.op=='list_substancesources':
    pubchem_utils.ListSubstanceSources(BASE_URI,fout,verbose)

  elif args.op=='cids2synonyms':
    if not ifile: ErrorExit('ERROR: CID[s] required\n'+usage)
    pubchem_utils.Cids2Synonyms(BASE_URI,ids,fout,skip,nmax,verbose)

  elif args.op=='cpd_smi2id':
    print(pubchem_utils.Smi2Cid(BASE_URI,cpd_smi2id,verbose))

  elif args.op=='sids2cids':
    #sids=map(lambda x:int(x),re.split(r'\s*,\s*',sids2cids))
    pubchem_utils.Sids2CidsCSV(BASE_URI,ids,fout,verbose)

  elif args.op=='cids2props':
    #cids=map(lambda x:int(x),re.split(r'\s*,\s*',cids2props))
    pubchem_utils.Cids2Properties(BASE_URI,ids,fout,verbose)

  elif args.op=='cids2inchi':
    #cids=map(lambda x:int(x),re.split(r'\s*,\s*',cids2props))
    pubchem_utils.Cids2Inchi(BASE_URI,ids,fout,verbose)

  elif args.op=='cids2sids':
    pubchem_utils.Cids2SidsCSV(BASE_URI,ids,fout,verbose)

  elif args.op=='name2sids':
    if not name_query: ErrorExit('ERROR: name required\n'+usage)
    sids=pubchem_utils.Name2Sids(BASE_URI,name_query,verbose)
    for sid in sids: print('%d'%sid)

  elif args.op=='name2cids':
    if not name_query: ErrorExit('ERROR: name required\n'+usage)
    cids=pubchem_utils.Name2Cids(BASE_URI,name_query,verbose)
    for cid in cids: print('%d'%cid)

  elif args.op=='aid2name':
    if not aids: ErrorExit('ERROR: AID[s] required\n'+usage)
    xmlstr=pubchem_utils.Aid2DescriptionXML(BASE_URI,aids,verbose)
    name,source = pubchem_utils.AssayXML2NameAndSource(xmlstr)
    print('%d:\n\tName: %s\n\tSource: %s'%(aid2name,name,source))

  elif args.op=='assaydescriptions':
    if not aids: ErrorExit('ERROR: AID[s] required\n'+usage)
    pubchem_utils.GetAssayDescriptions(BASE_URI,aids,fout,skip,nmax,verbose)

  elif args.op=='assayresults':
    if not (aids and ids): parser.error('%s requires AID[s] and SID[s]'%args.op)
    #n_in,n_out = pubchem_utils.GetAssayResults_Screening(BASE_URI,aids,ids,fout,skip,nmax,verbose)
    #print('%s,%s: aids in: %d ; results out: %d'%(ifile,ofile,n_in,n_out), file=sys.stderr)

    pubchem_utils.GetAssayResults_Screening2(BASE_URI,aids,ids,fout,skip,nmax,verbose)

  elif args.op=='cids2sdf':
    if not ids: ErrorExit('ERROR: CID[s] required\n'+usage)
    pubchem_utils.Cids2Sdf(BASE_URI, ids, fout, args.verbose)

  elif args.op=='cids2assaysummary':
    if not ids: ErrorExit('ERROR: CID[s] required\n'+usage)
    pubchem_utils.Cids2Assaysummary(BASE_URI,ids,fout,verbose)

  elif args.op=='sids2assaysummary':
    if not ids: ErrorExit('ERROR: SID[s] required\n'+usage)
    pubchem_utils.Sids2Assaysummary(BASE_URI,ids,fout,verbose)

  elif args.op=='cids2smi':
    if not ids: ErrorExit('ERROR: CID[s] required\n'+usage)
    pubchem_utils.Cids2Smiles(BASE_URI,ids,False,fout,verbose)

  elif args.op=='cids2ism':
    if not ids: ErrorExit('ERROR: CID[s] required\n'+usage)
    pubchem_utils.Cids2Smiles(BASE_URI,ids,True,fout,verbose)

  elif args.op=='sids2sdf':
    n_sid_in,n_sdf_out = pubchem_utils.Sids2Sdf(BASE_URI,ids,fout,skip,nmax,verbose)
    print('%s,%s: sids in: %d ; sdfs out: %d'%(ifile,ofile,n_sid_in,n_sdf_out), file=sys.stderr)

  else:
    parser.print_help()

