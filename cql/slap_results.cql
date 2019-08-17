MATCH (c:Compound)-[r:SLAP]-(g:Gene)
RETURN LABELS(c), KEYS(c),
	c.CID, c.name, c.smiles, c.is_drug,
	type(r), r.score,
	LABELS(g), KEYS(g), g.UniprotID, g.geneid, g.name
ORDER BY r.score DESC
	;
