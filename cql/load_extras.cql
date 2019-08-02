// Loads custom T2D-NET files, see load_cytoscape_cyjs2tsv.cypher which loads
// Cytoscape-exported data.
////
// Add new properties to existing nodes.

// Compounds:

// From PubChem API SDF, and ChemAxon convert to TSV.
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/slap_dtp_merged_nodes_compounds.tsv"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (c:Compound {uri:'http://chem2bio2rdf.org/pubchem/resource/pubchem_compound/'+row.PUBCHEM_COMPOUND_CID})
SET c += {CID:trim(row.PUBCHEM_COMPOUND_CID), name:row.PUBCHEM_IUPAC_TRADITIONAL_NAME, smiles:row.PUBCHEM_OPENEYE_CAN_SMILES }
RETURN COUNT(c);

// Proteins:
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/protein_list_annotated.tsv"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (g:Gene {uri:'http://chem2bio2rdf.org/uniprot/resource/gene/'+row.sym})
SET g += {UniprotID:row.protein_accession, name:row.name, ensp:row.stringid, geneid:row.geneid, family:row.fam}
RETURN COUNT(g);

// SLAP Compound-Target Associations:
////
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/t2d_dtp_links.csv"
AS row
MATCH (c:Compound {CID:row.CID}), (g:Gene {UniprotID:row.TID})
CREATE (c)-[:SLAP {score_type:row.score_type, score_note:row.score_note, score:toFloat(row.score)}]->(g)
RETURN COUNT(c);

// C2B2R to OMIM disease IDs
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/c2b2r_OMIM_raw_selected.tsv"
AS row FIELDTERMINATOR '\t' WITH row
CREATE (dmim:OMIM_Disease {name:row.Disorder_name, OMIM_ID:row.OMIM_Disease_ID, url:'https://omim.org/entry/'+toString(row.OMIM_Disease_ID)})
RETURN COUNT(dmim) ;
//
LOAD CSV WITH HEADERS FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/c2b2r_OMIM_raw_selected.tsv"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (d:C2B2R_Disease {ID:row.Disease_ID}), (dmim:OMIM_Disease {OMIM_ID:row.OMIM_Disease_ID})
CREATE (d)-[:OMIM {class:'C2B2R_diseasegroup_OMIM_member'}]->(dmim)
RETURN COUNT (dmim);

// Diabetes Drugs:
LOAD CSV FROM "https://raw.githubusercontent.com/IUIDSL/t2d-net/master/data/diabetes_drugs.smi"
AS row FIELDTERMINATOR '\t' WITH row
MATCH (c:Compound {CID:row[2]})
SET c += {smiles:row[0], name:row[1], is_drug:'TRUE'}
RETURN COUNT(c);

