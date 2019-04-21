// Node counts:
MATCH (n) RETURN "NODES (All): "+toString(COUNT(n)) ;

MATCH (n:Compound) RETURN "NODES (Compound): "+toString(COUNT(n)) ;
MATCH (n:Gene) RETURN "NODES (Gene): "+toString(COUNT(n)) ;

// Relationship counts:
MATCH ()-[r]-() RETURN "RELATIONSHIPS (All): "+toString(COUNT(r)) ;
MATCH ()-[r:chemogenomics]-() RETURN "RELATIONSHIPS (chemogenomics): "+toString(COUNT(r)) ;
MATCH ()-[r:SLAP]-() RETURN "RELATIONSHIPS (SLAP): "+toString(COUNT(r)) ;
