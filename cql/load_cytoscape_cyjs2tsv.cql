// Loads T2D-NET from Cytoscape-exported network CYJS (slap_dtp_merged.cyjs),
// converted to TSV (slap_dtp_merged.cyjs.tsv) by cytoscape_utils.py.
////
// See https://neo4j.com/docs/getting-started/current/cypher-intro/load-csv/
// CALL dbms.security.createUser('jjyang', 'assword')
// In Community Edition, all users have admin privileges.
////
// Property "name" visible by default in Neo4j browser?
////
// Note that OMIM IDs and URLs e.g.
// http://chem2bio2rdf.org/omim/resource/omim_disease/773
// refer to Chem2Bio2RDF "DIsease_ID"s, e.g.
// chord=> SELECT * FROM "OMIM_raw" WHERE "Disease_ID" IN (427, 773) ;
// Disease_ID=773 maps to multiple T2D OMIM diseases.
////


////
// NODES
// pubchem_compound
// gene (Gene)
// omim_disease (C2B2R_Disease)
// kegg_pathway
// GO
// chebi
// gene_family
// sider
// substructure
// tissue

// Compounds:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
WHERE row.node_or_edge = 'node' AND row.class = 'pubchem_compound'
CREATE (c:Compound {SUID:row.SUID, uri:row.name, name:trim(row.label)}) ;

// Genes:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
WHERE row.node_or_edge = 'node' AND row.class = 'gene'
CREATE (g:Gene { SUID:row.SUID, uri:row.name, name:trim(row.label)}) ;

// Diseases:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
WHERE row.node_or_edge = 'node' AND row.class = 'omim_disease'
CREATE (d:C2B2R_Disease { SUID:row.SUID, name:row.name, uri:row.name, ID:trim(row.label)}) ;

// KEGG Pathways:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
WHERE row.node_or_edge = 'node' AND row.class = 'kegg_pathway'
CREATE (p:Pathway { SUID:row.SUID, uri:row.name, name:trim(row.label)}) ;

// GO terms:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
WHERE row.node_or_edge = 'node' AND row.class = 'GO'
CREATE (g:GO { SUID:row.SUID, uri:row.name, name:trim(row.label)}) ;

// Gene families:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
WHERE row.node_or_edge = 'node' AND row.class = 'gene_family'
CREATE (g:GeneFamily { SUID:row.SUID, uri:row.name, name:trim(row.label)}) ;

// Substructures:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
WHERE row.node_or_edge = 'node' AND row.class = 'substructure'
CREATE (s:Substructure { SUID:row.SUID, uri:row.name, name:trim(row.label)}) ;

// Tissues:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
WHERE row.node_or_edge = 'node' AND row.class = 'tissue'
CREATE (t:Tissue { SUID:row.SUID, uri:row.name, name:trim(row.label)}) ;

////
// EDGES ("relationships")
// chemogenomics
// expression
// Gene_Family_Name
// GO_ID
// hprd
// protein
// substructure
// tissue
// drug (USEFUL?)

////
// ISSUE: Can we load all relationships in one command? Can we use row.label to
// define the relationship type? Apparently "CREATE (s)-[:row.label " not ok.
////
//USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (s {SUID:row.source}), (t {SUID:row.target})
WHERE row.node_or_edge = 'edge' AND row.label = 'chemogenomics'
CREATE (s)-[:chemogenomics {SUID:row.SUID, evidence:row.evidence, name:row.name}]->(t) ;

LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (s {SUID:row.source}), (t {SUID:row.target})
WHERE row.node_or_edge = 'edge' AND row.label = 'GO_ID'
CREATE (s)-[:GO {SUID:row.SUID, evidence:row.evidence, name:row.name}]->(t) ;

LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (s {SUID:row.source}), (t {SUID:row.target})
WHERE row.node_or_edge = 'edge' AND row.label = 'hprd'
CREATE (s)-[:hprd {SUID:row.SUID, evidence:row.evidence, name:row.name}]->(t) ;

LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (s {SUID:row.source}), (t {SUID:row.target})
WHERE row.node_or_edge = 'edge' AND row.label = 'Gene_Family_Name'
CREATE (s)-[:GeneFamily {SUID:row.SUID, evidence:row.evidence, name:row.name}]->(t) ;

LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (s {SUID:row.source}), (t {SUID:row.target})
WHERE row.node_or_edge = 'edge' AND row.label = 'substructure'
CREATE (s)-[:substructure {SUID:row.SUID, evidence:row.evidence, name:row.name}]->(t) ;

LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (s {SUID:row.source}), (t {SUID:row.target})
WHERE row.node_or_edge = 'edge' AND row.label = 'expression'
CREATE (s)-[:expression {SUID:row.SUID, evidence:row.evidence, name:row.name}]->(t) ;

LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (s {SUID:row.source}), (t {SUID:row.target})
WHERE row.node_or_edge = 'edge' AND row.label = 'tissue'
CREATE (s)-[:tissue {SUID:row.SUID, evidence:row.evidence, name:row.name}]->(t) ;

LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged.cyjs.tsv"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (s {SUID:row.source}), (t {SUID:row.target})
WHERE row.node_or_edge = 'edge' AND row.label = 'drug'
CREATE (s)-[:drug {SUID:row.SUID, evidence:row.evidence, name:row.name}]->(t) ;

// Report node and relationship counts:
MATCH (n) RETURN COUNT(n) AS NODES ;
MATCH ()-[r]-() RETURN COUNT(r) AS RELATIONSHIPS ;
