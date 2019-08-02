#!/usr/bin/env python3
#############################################################################
### omim_query.py - Online Mendelian Inheritance in Man,
### "An Online Catalog of Human Genes and Genetic Disorders"
### 
#############################################################################
### See: http://omim.org/help/api
### The OMIM API URLs are organized in a very simple fashion:
###   /api/[handler]?[parameters]
###   /api/[handler]/[component]?[parameters]
###   /api/[handler]/[action]?[parameters]
### The handler refers to the data object, such as an entry or a clinical synopsis.
### The component is optional and refers to a specific data component within a data object for example
### references within an entry.
### The action is optional and refers to an action to be performed on a data object, such as a search for
### entries.
### For basic 'GET's, the component or action are usually optional.
### The parameters would include things such as MIM numbers, data retrieval options and data formatting options.
#############################################################################
### LIMITS:
### "Entries and clinical synopses are limited to 20 per request if any 'includes' are specified,
### otherwise there is no limit.
### Gene map entries are limited to 100 per request.
### The rate of requests is currently limited to 4 requests per second.
### Your client will be throttled if you exceed the maximum rate, a 409 http status will be returned. Note that
### repeated requests which get a 409 will lengthen the interval before your access is restored, and if more
### than thirty 409's are generated your client will be banned for six hours after which access will be
### restored.
#############################################################################
### Handlers:
###   entry
###   clinicalSynopsis
###   geneMap
###   search
###   html
###   apiKey	: "&apiKey=..."
###   dump
###  
### Generic parameters:
###   &format=json|xml|jsonp|html|python
###   &format=xml&style=true
###   &debug=true
###   &jsonp=callbackfunc
#############################################################################
### entry?mimNumber=100100&format=json&apiKey=...
#############################################################################
### https://omim.org/downloads/1kweo1_nTfuTCiVRnANNGQ
#############################################################################
### Jeremy Yang
#############################################################################
import sys,os,re,argparse,time
import urllib,urllib.parse
import json

import rest_utils
#
API_HOST='api.omim.org'	#US
#API_HOST='api.europe.omim.org'	#Europe
API_BASE_PATH='/api'
#API_KEY='3D6C690F7DD2473871AC906B6A415A6132D1C9F9'
API_KEY='1kweo1_nTfuTCiVRnANNGQ' #will expire on Nov. 19th, 2019.
#
##############################################################################
if __name__=='__main__':
  PROG=os.path.basename(sys.argv[0])
  FMT='json';

  epilog='''\
operations:
        entry ..................... entry resource, fetch records
        clinical .................. clinicalSynopsis resource, fetch records
        genemap ................... geneMap resource, fetch records
        search .................... search via defined syntax, some/all fields

example mim numbers:
	100100
	100200

example searches:
	"muscular AND dystrophy NOT duchenne"
	"(muscular AND dystrophy) OR (duchenne AND gene)"
	"Bombay syndrome"

include-able fields:
              text	text field sections
        existflags	'exists' flags (clinical synopsis, allelic variant, gene map & phenotype map).
allelicVariantList	allelic variant list
  clinicalSynopsis	clinical synopsis
           seeAlso	'see also' field
     referenceList	reference list
           geneMap	gene map/phenotype map data
     externalLinks	external links
      contributors	'contributors' field
      creationDate	'creation date' field
       editHistory	'edit history' field
             dates	dates data
               all	all
'''
  parser = argparse.ArgumentParser(
        description='OMIM client ("Online Mendelian Inheritance in Man")', epilog=epilog)
  ops = ['entry', 'clinical', 'genemap', 'search']
  parser.add_argument("op", choices=ops, help='operation')
  parser.add_argument("--o", dest="ofile", help="output (CSV|TSV)")
  parser.add_argument("--mims", help="MIM number[s], comma-separated")
  parser.add_argument("--query", help="search query")
  parser.add_argument("--rawquery", help="search rawquery")
  parser.add_argument("--inc_fields", help="specify fields, comma-separated, or 'all'")
  parser.add_argument("--fmt", default=FMT, choices=('json', 'xml', 'python'), help="output format")
  parser.add_argument("--api_host", default=API_HOST)
  parser.add_argument("--api_base_path", default=API_BASE_PATH)
  parser.add_argument("--api_key", default=API_KEY)
  parser.add_argument("-v", "--verbose", action="count")
  args = parser.parse_args()

  mim_vals=map(lambda n:int(n),re.split(',',args.mims))


  if ofile:
    fout=open(ofile,"w")
    if not fout: ErrorExit('ERROR: cannot open outfile: %s'%ofile)
  else:
    fout=sys.stdout

  t0=time.time()

  API_BASE_URL='https://'+args.api_host+args.api_base_path
  url=API_BASE_URL

  url_params=('&include=%s'%args.inc_fields if args.inc_fields else '')
  #url_params+=('&format=%s'%fmt)
  url_params+=('&apiKey=%s'%args.api_key)

  if args.op == 'entry':
    url=API_BASE_URL+'/entry?mimNumber=%s'%(','.join(map(lambda n:str(n), mim_vals)))+url_params
    rval=rest_utils.GetURL(url, parse_json=True, verbose=verbose)
    fout.write(json.dumps(rval, sort_keys=True, indent=2))

  elif args.op == 'genemap':
    url=API_BASE_URL+'/geneMap?mimNumber=%s'%(','.join(map(lambda n:str(n), mim_vals)))+url_params
    rval=rest_utils.GetURL(url, parse_json=True, verbose=verbose)
    fout.write(json.dumps(rval, sort_keys=True, indent=2))

  elif args.op == 'clinical':
    url=API_BASE_URL+'/clinicalSynopsis?mimNumber=%s'%(','.join(map(lambda n:str(n), mim_vals)))+url_params
    rval=rest_utils.GetURL(url, parse_json=True, verbose=verbose)
    fout.write(json.dumps(rval, sort_keys=True, indent=2))

  elif args.op == 'search':
    url=API_BASE_URL+'/entry/search?search=%s'%(urllib.parse.quote(query))+url_params
    rval=rest_utils.GetURL(url, parse_json=True, verbose=verbose)
    fout.write(json.dumps(rval, sort_keys=True, indent=2))

  elif args.op == 'rawquery':
    url=API_BASE_URL+rawquery
    rval=rest_utils.GetURL(url, parse_json=True, verbose=verbose)
    fout.write(json.dumps(rval, sort_keys=True, indent=2))

  else:
    parser.error('Unknown operation: %s'%args.op)

  if verbose:
    print(('%s: elapsed time: %s'%(PROG, time.strftime('%Hh:%Mm:%Ss',time.gmtime(time.time()-t0)))), file=sys.stderr)
