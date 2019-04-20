// Loads T2D-NET from Cytoscape-exported network CYJS, converted to
// a single TSV by cytoscape_utils.py.

// See https://neo4j.com/docs/getting-started/current/cypher-intro/load-csv/
// CALL dbms.security.createUser('jjyang', 'assword')
// In Community Edition, all users have admin role.

// Exported by Cytoscape: slap_dtp_merged.cyjs
// cytoscape_utils.py cyjs2tsv
// data/slap_dtp_merged.cyjs.tsv

// NODES

// pubchem_compound
// gene (Gene)
// omim_disease
// kegg_pathway
// GO
// chebi
// gene_family
// sider
// substructure
// tissue

// Compounds:
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row
WHERE row.class = 'pubchem_compound'
CREATE (c:Compound { name:row.name, PUBCHEM_CID:trim(row.label)}) ;

// Genes:
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row
CREATE (g:Gene { name:row.name, gene_symbol:row.label }) ;

// OMIM Diseases (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row
WHERE row.class = 'omim_disease'
CREATE (d:Disease { name:row.name, OMIM_ID:row.label }) ;

// KEGG Pathways (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row
WHERE row.class = 'kegg_pathway'
CREATE (p:Pathway { name:row.name, KEGG_ID:row.label }) ;

// GO terms (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row
WHERE row.class = 'GO'
CREATE (g:GO { name:row.name, GO_ID:row.label }) ;

// Gene families (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row
WHERE row.class = 'gene_family'
CREATE (g:GeneFam { name:row.name, HGNC_GeneFam:row.label }) ;

// CHEBI chemicals (from all-nodes file): (NO, NOT USEFUL)
//LOAD CSV WITH HEADERS
//FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row
//WHERE row.class = 'chebi'
//CREATE (g:Chebi { name:row.name, CHEBI_ID:row.label }) ;

// Substructures (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row
WHERE row.class = 'substructure'
CREATE (s:Substructure { name:row.name, name:row.label }) ;

// Tissues (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row
WHERE row.class = 'tissue'
CREATE (t:Tissue { name:row.name, tissue_name:row.label }) ;

// EDGES (slap_dtp_merged_edges.tsv)
// Manual step needed to parse CIDs and Genesymbols from Cy export CSV.

// chemogenomics (Compound)-(Gene)
// chebi (NOT USEFUL)
// cid (NOT USEFUL)
// drug (USEFUL?)
// expression
// Gene_Family_Name
// GO_ID
// hprd
// protein
// substructure
// tissue

// Compound-Genes (chemogenomic) edges:
//USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_edges.tsv" AS row FIELDTERMINATOR '\t' WITH row
MATCH
	(c:Compound {PUBCHEM_CID:row.CID}),
	(g:Gene {gene_symbol:row.Gene})
WHERE row.label = 'chemogenomics'
CREATE (c)-[:chemogenomics {name:row.name, evidence:row.evidence, weight:toFloat(row.weight)}]->(g) ;


// Report node and relationship counts:
MATCH (n) RETURN "NODES: "+toString(COUNT(n)) ;
MATCH ()-[r]-() RETURN "RELATIONSHIPS: "+toString(COUNT(r)) ;
