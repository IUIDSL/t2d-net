#!/usr/bin/env python3
"""
	cytoscape_utils.py -- Tools for Cytoscape I/O.

	Cy2 code from 2011 quite obsolete.
	Now (2019) using Cy3 Python3 package py2cytoscape.

"""
import sys,os,argparse,json,re

import py2cytoscape
from py2cytoscape.data.cyrest_client import CyRestClient

#############################################################################
### Convert CYJS to TSVs.
def CyJS2TSV(fin, args, fout):
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
def XGMML_Header(title='',bgcolor='#CCCCFF'):
  """ Returns header for Cytoscape compatible XGMML (XML). """
  ts=time.strftime('%Y-%m-%d %H:%M:%S',time.localtime())
  xml='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
  xml+='<graph label="%s" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xlink="http://www.w3.org/1999/ xlink" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:cy="http://www.cytoscape.org" xmlns="http://www.cs.rpi.edu/XGMML" directed="1">'%title
  xml+='  <att name="documentVersion" value="1.1"/>\n'
  xml+='  <att name="networkMetadata">\n'
  xml+='    <rdf:RDF>\n'
  xml+='      <rdf:Description rdf:about="http://www.cytoscape.org/">\n'
  xml+='      <dc:type>%s</dc:type>\n'%title
  xml+='      <dc:description>N/A</dc:description>\n'
  xml+='      <dc:identifier>N/A</dc:identifier>\n'
  xml+='      <dc:date>%s</dc:date>\n'%ts
  xml+='      <dc:title>%s</dc:title>\n'%title
  xml+='      <dc:source>http://biocomp.health.unm.edu</dc:source>\n'
  xml+='      <dc:format>Cytoscape-XGMML</dc:format>\n'
  xml+='    </rdf:Description>\n'
  xml+='  </rdf:RDF>\n'
  xml+='  </att>\n'
  xml+='  <att type="string" name="backgroundColor" value="%s" />\n'%bgcolor
  return xml

#############################################################################
def XGMML_Footer():
  xml='</graph>\n'
  return xml

#############################################################################
def WriteLines(fout,lines,indent=''):
  """ Write lines to file, with indents and newlines. """
  for line in lines:
    fout.write('%s%s\n'%(indent,line))

#############################################################################
if __name__ == '__main__':

  parser = argparse.ArgumentParser(description='Cytoscape I/O utilities.')
  ops = ['cyjs2tsv', 'summary']
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

  if args.op=='summary':
    cy = CyRestClient()
    network = cy.network.create(name='My Network', collection='My network collection')
    print("Cytoscape current net_id: %d"%network.get_id())

  elif args.op=='cyjs2tsv':
    CyJS2TSV(fin, args, fout)

  else:
    parser.error('Unknown operation: %s'%args.op)

