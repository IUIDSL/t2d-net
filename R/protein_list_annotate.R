library(readr)
library(data.table)

proteins <- read_delim("data/protein_list.csv", ",")
setDT(proteins)
tcrd <- read_delim("data/tcrd_targets.csv", ",", col_types = cols(.default=col_character()))
setDT(tcrd)
tcrd <- tcrd[, .(protein.stringid, protein.sym, protein.geneid, protein.uniprot, target.fam)]
setnames(tcrd, sub('^.*\\.', '', names(tcrd)))

proteins <- merge(proteins, tcrd, by.x="protein_accession", by.y="uniprot", all.x=T, all.y=F)

write_delim(proteins, "data/protein_list_annotated.tsv", "\t")