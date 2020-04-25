--
SELECT DISTINCT
	tid,
	gene_symbol,
	organism,
	protein_accession,
	target_type,
	db_source,
	db_version,
	pref_name
FROM
	public.c2b2r_chembl_08_target_dictionary
WHERE
	UPPER(gene_symbol) = UPPER('ABAT')
	;
--
