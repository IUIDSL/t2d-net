// See https://neo4j.com/docs/getting-started/current/cypher-intro/load-csv/
// cypher-shell "MATCH (n) DELETE n" deletes all nodes.
// cypher-shell "MATCH (n) DETACH DELETE n" deletes all nodes and relationships.
// CALL dbms.security.createUser('jjyang', 'assword')
// In Community Edition, all users have admin role.


// NODES

// chebi
// class
// gene (Gene)
// gene_family
// GO (GO)
// kegg_pathway
// omim_disease
// pubchem_compound
// sider
// substructure
// tissue

// Compounds:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes_compounds.tsv" AS row FIELDTERMINATOR '\t' CREATE (c:Compound { CID:trim(row.PUBCHEM_COMPOUND_CID), name:row.PUBCHEM_IUPAC_TRADITIONAL_NAME, smiles:row.PUBCHEM_OPENEYE_CAN_SMILES}) ;

// OMIM Diseases (from all-nodes file):
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row WHERE row.class = 'omim_disease' CREATE (d:Disease { OMIM_ID:row.label }) ;

// KEGG Pathways (from all-nodes file):
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row WHERE row.class = 'kegg_pathway' CREATE (p:Pathway { KEGG_ID:row.label }) ;

// GO terms (from all-nodes file):
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row WHERE row.class = 'GO' CREATE (g:GO { GO_ID:row.label }) ;

// Gene families (from all-nodes file):
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row WHERE row.class = 'gene_family' CREATE (g:GeneFam { HGNC_GeneFam:row.label }) ;

// CHEBI chemicals (from all-nodes file):
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row WHERE row.class = 'chebi' CREATE (g:Chebi { CHEBI_ID:row.label }) ;

// Substructures (from all-nodes file):
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row WHERE row.class = 'substructure' CREATE (s:Substructure { name:row.label }) ;

// Tissues (from all-nodes file):
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv" AS row WITH row WHERE row.class = 'tissue' CREATE (t:Tissue { name:row.label }) ;


// Genes:
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes_genes.tsv" AS row FIELDTERMINATOR '\t' CREATE (g:Gene { gene_symbol: row.Gene }) ;

// EDGES

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
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_edges.tsv" AS row FIELDTERMINATOR '\t' WITH row MATCH (c:Compound {CID:row.CID}), (g:Gene {gene_symbol:row.Gene}) WHERE row.label = 'chemogenomics' CREATE (c)-[:chemogenomics {name:row.name, evidence:row.evidence, weight:toFloat(row.weight)}]->(g) ;

// Proteins:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/protein_list.csv" AS row CREATE (p:Protein { UniprotID:row.protein_accession, name:row.name}) ;


// Diabetes Drugs:
LOAD CSV FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/diabetes_drugs.smi" AS row CREATE (d:Drug { smiles:row[0], name:row[1], CID:row[2]}) ;

// SLAP Compound-Target Associations:
//USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/t2d_dtp_links.csv" AS row MATCH (c:Compound {CID:row.CID}), (p:Protein {UniprotID:row.TID}) CREATE (c)-[:SLAP { score_type: row.score_type, score_note: row.score_note, score: toFloat(row.score)}]->(p) ;

