--
--	description,
--	gene_names,
--	synonyms,
--	keywords,
--	protein_sequence,
--	protein_md5sum,
--	tax_id,
--	organism,
--	tissue,
--	strain,
--	db_version,
--	cell_line,
--	protein_accession,
--	ec_number,
--
SELECT DISTINCT
	tid,
	protein_accession,
	chembl_id,
	tax_id,
	target_type,
	organism,
	db_source,
	gene_symbol,
	pref_name
FROM
	public.c2b2r_chembl_08_target_dictionary
WHERE
	target_type = 'PROTEIN'
ORDER BY
	gene_symbol ASC
	;
--
