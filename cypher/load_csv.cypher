// See https://neo4j.com/docs/getting-started/current/cypher-intro/load-csv/
// cypher-shell "MATCH (n) DELETE n" deletes all nodes.
// cypher-shell "MATCH (n) DETACH DELETE n" deletes all nodes and relationships.
// CALL dbms.security.createUser('jjyang', 'assword')
// In Community Edition, all users have admin role.


// Compounds:
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes_compounds.tsv"
	AS csvLine
	FIELDTERMINATOR '\t'
CREATE
	(c:Compound {
		CID:trim(csvLine.PUBCHEM_COMPOUND_CID),
		name:csvLine.PUBCHEM_IUPAC_TRADITIONAL_NAME,
		smiles:csvLine.PUBCHEM_OPENEYE_CAN_SMILES})
	;

// OMIM Diseases (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv"
	AS csvLine
CREATE
	(d:Disease { OMIM_ID:csvLine.label })
WHERE
	csvLine.class = 'omim_disease' ;

// KEGG Pathways (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv"
	AS csvLine
CREATE
	(p:Pathway { KEGG_ID:csvLine.label })
WHERE
	csvLine.class = 'kegg_pathway' ;

// GO terms (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv"
	AS csvLine
CREATE
	(g:GO { GO_ID:csvLine.label })
WHERE
	csvLine.class = 'GO' ;

// Gene families (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv"
	AS csvLine
CREATE
	(g:GeneFam { HGNC_GeneFam:csvLine.label })
WHERE
	csvLine.class = 'gene_family' ;

// CHEBI chemicals (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv"
	AS csvLine
CREATE
	(g:Chebi { CHEBI_ID:csvLine.label })
WHERE
	csvLine.class = 'chebi' ;

// Substructures (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv"
	AS csvLine
CREATE
	(s:Substructure { name:csvLine.label })
WHERE
	csvLine.class = 'substructure' ;

// Tissues (from all-nodes file):
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes.csv"
	AS csvLine
CREATE
	(t:Tissue { name:csvLine.label })
WHERE
	csvLine.class = 'tissue' ;


// Genes:
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes_genes.tsv"
	AS csvLine
	FIELDTERMINATOR '\t'
CREATE
	(g:Gene {
		gene_symbol: csvLine.Gene
		})
	;

// Compound-Genes (chemogenomic) edges:
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_edges.tsv" AS csvLine 
	FIELDTERMINATOR '\t'
MATCH
	(c:Compound {CID:csvLine.CID}), (g:Gene {gene_symbol:csvLine.Gene})
WHERE csvLine.label = 'chemogenomics'
CREATE (c)-[:chemogenomics
		{name:csvLine.name, evidence:csvLine.evidence, weight:toFloat(csvLine.weight)}
	]->(g) ;

// Proteins:
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/protein_list.csv"
	AS csvLine
CREATE
	(p:Protein {
		UniprotID:csvLine.protein_accession,
		name:csvLine.name}) ;


// Diabetes Drugs:
LOAD CSV
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/diabetes_drugs.smi"
	AS csvLine
CREATE
	(d:Drug {
		smiles:csvLine[0],
		name:csvLine[1],
		CID:csvLine[2]}) ;

// SLAP Compound-Target Associations:
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/t2d_dtp_links.csv" 
	AS csvLine 
MATCH
	(c:Compound {CID:csvLine.CID}),
	(p:Protein {UniprotID:csvLine.TID})
CREATE (c)-[:SLAP {
		score_type: csvLine.score_type,
		score_note: csvLine.score_note,
		score: toFloat(csvLine.score)}
	]->(p) ;

