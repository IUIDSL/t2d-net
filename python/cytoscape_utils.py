#!/usr/bin/env python3
"""
	cytoscape_utils.py -- Tools for Cytoscape I/O.

	Cy2 code from 2011 quite obsolete.
	Now (2019) using Cy3 Python3 package py2cytoscape.
	See: https://github.com/cytoscape/py2cytoscape

"""
import sys,os,argparse,json,re

import py2cytoscape
from py2cytoscape.data.cyrest_client import CyRestClient

#############################################################################
def CyJS2TSV(fin, args, fout):
  '''Convert CyJS to TSV. For Neo4j import, etc.'''
  tags=['SUID','label','name','class','nodesize','Degree','source','target','interaction','evidence','uri'] #node or edge
  fout.write('\t'.join(['node_or_edge']+tags)+'\n')
  cyjs = json.load(fin)
  if args.verbose:
    for key in ('format_version', 'generated_by', 'target_cytoscapejs_version'):
      print('%18s: %s'%(key, cyjs[key]))
    #for key in cyjs['data']:
    #  print("data['%s']: %18s"%(key, cyjs['data'][key]))
    print('nodes: %d'%(len(cyjs['elements']['nodes'])))
    print('edges: %d'%(len(cyjs['elements']['edges'])))
  n_node=0; n_edge=0;
  for node in cyjs['elements']['nodes']:
    n_node+=1
    vals=['node']
    for tag in tags:
      vals.append(str(node['data'][tag]) if tag in node['data'] else '')
    fout.write('\t'.join(vals)+'\n')
  for edge in cyjs['elements']['edges']:
    n_edge+=1
    vals=['edge']
    for tag in tags:
      vals.append(str(edge['data'][tag]) if tag in edge['data'] else '')
    fout.write('\t'.join(vals)+'\n')
  print('Output: nodes: %d ; edges: %d'%(n_node, n_edge), file=sys.stderr)

#############################################################################
if __name__ == '__main__':

  parser = argparse.ArgumentParser(description='Cytoscape I/O utilities.')
  ops = ['cyjs2tsv', 'ping']
  parser.add_argument("op", choices=ops, help='operation')
  parser.add_argument("--i", dest="ifile", help="input (CSV|TSV)")
  parser.add_argument("--o", dest="ofile", help="output (CSV|TSV)")
  parser.add_argument("-v", "--verbose", action="count")
  args = parser.parse_args()

  if args.ifile:
    fin=open(args.ifile)
  else:
    fin=sys.stdin

  if args.ofile:
    fout=open(args.ofile, "w")
  else:
    fout=sys.stdout

  if args.op=='ping':
    try:
      cy = CyRestClient(ip='127.0.0.1', port=1234)
    except Exception as e:
      print("Cytoscape connection failed: %s"%e, file=sys.stderr)
      exit()

    network = cy.network.create(name='My Network', collection='My network collection')
    print("Cytoscape current net_id: %d"%network.get_id())

  elif args.op=='cyjs2tsv':
    CyJS2TSV(fin, args, fout)

  else:
    parser.error('Unknown operation: %s'%args.op)

