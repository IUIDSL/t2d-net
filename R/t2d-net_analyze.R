#!/usr/bin/env Rscript
###
library(readr)
library(data.table, quietly=T)
library(plotly, quietly=T)

# Targets associated with T2D by SLAP
tgts <- read_csv("data/protein_list.csv", col_types = cols_only(protein_accession = col_character(), name = col_character()))
setDT(tgts)
writeLines(sprintf("Total T2D-NET targets: %d", nrow(tgts)))

# IDG TCRD
# https://pharos.nih.gov/
tcrd <- read_csv("data/tcrd_targets.csv", col_types = cols_only(protein.uniprot = col_character(), protein.sym = col_character(),  target.name = col_character(), target.tdl = col_character(), protein.chr = col_character(), protein.geneid = col_character(), protein.stringid = col_character()))
setDT(tcrd)

tgts <- merge(tgts, tcrd, by.x="protein_accession", by.y="protein.uniprot", all.x=T)
# TDLs defined: https://druggablegenome.net/ProteinFam
tdl_counts <- table(tgts$target.tdl, useNA="ifany")

for (tdl in c("Tclin", "Tchem", "Tbio", "Tdark")) {
  writeLines(sprintf("IDG Target Development Level (TDL): %s; N = %d", tdl, tdl_counts[tdl]))
}
writeLines(sprintf("Total targets associated with drug MoA: %d", nrow(tgts[target.tdl == "Tclin", ])))
writeLines(sprintf("Total targets NOT associated with drug MoA: %d", nrow(tgts[target.tdl != "Tclin", ])))

# IDG TIN-X
# See https://newdrugtargets.org?disease=3482
# Definitions: https://academic.oup.com/bioinformatics/article/33/16/2601/3111842
tinx <- read_csv("data/TINX_diabetes_mellitus.csv", col_types = cols_only(uniprot = col_character(), name = col_character(), importance_score = col_double(), novelty_score = col_double()))
setDT(tinx)
tinx <- tinx[order(-importance_score), ]
#
qtl <- quantile(log10(tinx$importance_score), seq(0, 1, .1))
writeLines(sprintf("log10(importance) quantile %4s: %7.3f", names(qtl), qtl))
#
tgts <- merge(tgts, tinx[, .(uniprot, importance_score, novelty_score)], by.x="protein_accession", by.y="uniprot", all.x=T)
#
p1 <- subplot(nrows=2, margin=0.1, shareX=T, shareY=T,
              plot_ly(name="TINX-Diabetes", type="histogram", x = log10(tinx$importance_score)),
              plot_ly(name="T2D-NET", type="histogram", x=log10(tgts$importance_score))) %>%
  layout(title="TIN-X Importance scores: Diabetes",
         xaxis=list(title="log10(importance)"), yaxis=list(title="N"),
         showlegend=T,
         margin=list(t=100,l=80,b=80,r=80),
         font=list(family="Arial",size=16),titlefont=list(size=22))
p1
