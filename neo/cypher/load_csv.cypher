-- See https://neo4j.com/docs/getting-started/current/cypher-intro/load-csv/
-- Note: "MATCH (n) DELETE n" deletes all nodes.
-- Load SLAP results linking drugs and targets from Google Sheets.


-- Diabetes Drugs:
LOAD CSV FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/diabetes_drugs.smi" AS csvLine CREATE (d:Drug {smiles: csvLine[0], name: csvLine[1], CID: csvLine[2]})

-- Compounds:

-- Proteins:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/protein_list.csv" AS csvLine CREATE (p:Protein {UniprotID: csvLine.protein_accession, name: csvLine.name})

-- Compound-Target Associations:
USING PERIODIC COMMIT 500 LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/t2dm_dtp_links.csv" AS csvLine MATCH (c:Compound {CID: csvLine.CID}), (p:Protein {UniprotID: csvLine.TID}) CREATE (c)-[:SLAP {score_type: csvLine.score_type, score_note: csvLine.score_note, score: toFloat(csvLine.score)}]->(p)

