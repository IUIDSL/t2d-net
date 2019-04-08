// Loads T2D-NET Cytoscape-exported node and edge CSVs.

// See https://neo4j.com/docs/getting-started/current/cypher-intro/load-csv/
// CALL dbms.security.createUser('jjyang', 'assword')
// In Community Edition, all users have admin role.

// Exported by Cytoscape: slap_dtp_merged.graphml.cyjs
// cytoscape_utils.py cyjs2tsv
// data/slap_dtp_merged.graphml.cyjs.tsv

// NODES (slap_dtp_merged_nodes_compounds.tsv)

// chebi (Chebi)
// gene (Gene)
// gene_family
// GO (GO)
// kegg_pathway
// omim_disease
// pubchem_compound (Compound)
// sider
// substructure
// tissue

// Compounds:
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.tsv" AS row WITH row
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

// CHEBI chemicals (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row
WHERE row.class = 'chebi'
CREATE (g:Chebi { name:row.name, CHEBI_ID:row.label }) ;

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

// chebi
// chemogenomics (Compound)-(Gene)
// cid
// drug
// expression
// Gene_Family_Name
// GO_ID
// hprd
// label
// protein
// substructure
// tissue

// Compound-Genes (chemogenomic) edges:
//USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_edges.csv" FIELDTERMINATOR ',' AS row WITH row
MATCH
	(c:Compound {name:row.CID}),
	(g:Gene {name:row.Gene})
WHERE row.label = 'chemogenomics'
CREATE (c)-[:chemogenomics {name:row.name, evidence:row.evidence, weight:toFloat(row.weight)}]->(g) ;

