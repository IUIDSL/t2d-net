// See https://neo4j.com/docs/getting-started/current/cypher-intro/load-csv/
// cypher-shell "MATCH (n) DELETE n" deletes all nodes.
// cypher-shell "MATCH (n) DETACH DELETE n" deletes all nodes and relationships.
// CALL dbms.security.createUser('jjyang', 'assword')
// In Community Edition, all users have admin role.

// Loads custom T2D-NET files, not the Cytoscape-exported node and edge CSVs.

// Compounds:

// From PubChem API SDF, and ChemAxon convert to TSV.
LOAD CSV WITH HEADERS
FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes_pubchem.tsv" FIELDTERMINATOR '\t' AS row WITH row
CREATE (c:Compound { CID:trim(row.PUBCHEM_COMPOUND_CID), name:row.PUBCHEM_IUPAC_TRADITIONAL_NAME, smiles:row.PUBCHEM_OPENEYE_CAN_SMILES}) ;

// Proteins:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/protein_list.csv" AS row CREATE (p:Protein { UniprotID:row.protein_accession, name:row.name}) ;

// Diabetes Drugs:
LOAD CSV FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/diabetes_drugs.smi" AS row CREATE (d:Drug { smiles:row[0], name:row[1], CID:row[2]}) ;

// SLAP Compound-Target Associations:
//USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/t2d_dtp_links.csv" AS row MATCH (c:Compound {CID:row.CID}), (p:Protein {UniprotID:row.TID}) CREATE (c)-[:SLAP { score_type: row.score_type, score_note: row.score_note, score: toFloat(row.score)}]->(p) ;

