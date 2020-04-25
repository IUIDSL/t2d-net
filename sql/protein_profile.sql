--
--	description,
--	gene_names,
--	synonyms,
--	keywords,
--	protein_sequence,
--	protein_md5sum,
--	tax_id,
--	tissue,
--	strain,
--	db_version,
--	cell_line,
--	ec_number,
--	chembl_id,
--
SELECT DISTINCT
	db_source,
	count(protein_accession)
FROM
	public.c2b2r_chembl_08_target_dictionary
WHERE
	target_type = 'PROTEIN'
	AND organism = 'Homo sapiens'
GROUP BY
	db_source
	;
--
SELECT DISTINCT
	organism,
	count(protein_accession) AS pcount
FROM
	public.c2b2r_chembl_08_target_dictionary
WHERE
	target_type = 'PROTEIN'
	AND db_source = 'SWISS-PROT'
GROUP BY
	organism
ORDER BY
	pcount DESC
LIMIT 20
	;
--
