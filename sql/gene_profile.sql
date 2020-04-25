--
SELECT 
	organism,
	count(protein_accession) AS prot_count
FROM
	public.c2b2r_chembl_08_target_dictionary
GROUP BY
	organism
ORDER BY
	prot_count DESC
LIMIT
	20
	;
--
SELECT 
	target_type,
	count(tid) AS ttype_count
FROM
	public.c2b2r_chembl_08_target_dictionary
GROUP BY
	target_type
ORDER BY
	ttype_count DESC
	;
--
