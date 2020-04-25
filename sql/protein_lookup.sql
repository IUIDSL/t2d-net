--
--
SELECT DISTINCT
	protein_accession,
	db_source,
	'"'||pref_name||'"' AS name
FROM
	public.c2b2r_chembl_08_target_dictionary
WHERE
	target_type = 'PROTEIN'
	AND organism = 'Homo sapiens'
	AND db_source = 'SWISS-PROT'
	AND protein_accession IN (
		'O15438',
		'O43451',
		'O60706',
		'O75469',
		'O95342',
		'P04278',
		'P05067',
		'P05093',
		'P05177',
		'P05423',
		'P06213',
		'P06732',
		'P07101',
		'P08069',
		'P08183',
		'P10632',
		'P10635',
		'P13569',
		'P14410',
		'P15090',
		'P20813',
		'P20815',
		'P24941',
		'P27487',
		'P30536',
		'P33261',
		'P35354',
		'P35916',
		'P37231',
		'P38936',
		'P47901',
		'Q01959',
		'Q07869',
		'Q14654',
		'Q14994',
		'Q15842',
		'Q92731',
		'Q92887',
		'Q9Y478'
	)
ORDER BY
	protein_accession ASC
	;
--
