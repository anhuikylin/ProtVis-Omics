#!/usr/bin/env Rscript
# GO and KEGG over-representation analyses for B73 vs Y12 DESeq2 results.
suppressPackageStartupMessages({library(readxl); library(clusterProfiler)})
a<-commandArgs(trailingOnly=TRUE)
if(length(a)<3) stop('Usage: Rscript 04_enrichment.R DESeq2_B73_vs_Y12.csv Enrichmentdb2.xlsx output_dir')
r<-read.csv(a[1],check.names=FALSE);stopifnot(all(c('GeneID','padj','log2FoldChange') %in% names(r)))
r<-r[!is.na(r$GeneID) & nzchar(r$GeneID) & is.finite(r$padj) & is.finite(r$log2FoldChange),]
if(anyDuplicated(r$GeneID)) stop('Duplicate gene IDs')
# The universe is the genes with an estimable adjusted P value, not all genes in the genome.
universe<-unique(as.character(r$GeneID));sets<-list(up=r$GeneID[r$padj<0.05 & r$log2FoldChange>1],down=r$GeneID[r$padj<0.05 & r$log2FoldChange< -1])
db<-list(GO=c(1,2),KEGG=c(3,4));dir.create(a[3],recursive=TRUE,showWarnings=FALSE)
for(n in names(db)){
 t2g<-as.data.frame(read_excel(a[2],sheet=db[[n]][1]));t2n<-as.data.frame(read_excel(a[2],sheet=db[[n]][2]));t2g<-t2g[,c('TERM','GENE')];t2n<-t2n[,c('TERM','NAME')];t2n<-t2n[!duplicated(t2n$TERM),]
 t2g$TERM<-as.character(t2g$TERM);t2g$GENE<-as.character(t2g$GENE);t2n$TERM<-as.character(t2n$TERM)
 for(s in names(sets)){
  if(length(sets[[s]])==0){message(n,' ',s,': no significant genes');next}
  e<-enricher(gene=sets[[s]],universe=universe,TERM2GENE=t2g,TERM2NAME=t2n,pvalueCutoff=1,qvalueCutoff=1,minGSSize=5,maxGSSize=500)
  if(is.null(e)){message(n,' ',s,': no matched terms');next}
  write.csv(as.data.frame(e),file.path(a[3],paste0(n,'_',s,'_ORA.csv')),row.names=FALSE)
 }
}
writeLines(capture.output(sessionInfo()),file.path(a[3],'sessionInfo_ORA.txt'))
