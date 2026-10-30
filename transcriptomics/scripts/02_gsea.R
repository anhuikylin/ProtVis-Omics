#!/usr/bin/env Rscript
# GSEA uses B73-versus-Y12 log2 fold changes, following archived RNAseq.R.
suppressPackageStartupMessages({library(readxl); library(clusterProfiler)})
a <- commandArgs(trailingOnly=TRUE)
if(length(a)<3) stop('Usage: Rscript 02_gsea.R DESeq2_B73_vs_Y12.csv Enrichmentdb2.xlsx output_dir')
r<-read.csv(a[1],check.names=FALSE); stopifnot(all(c('GeneID','log2FoldChange') %in% names(r)))
r<-r[is.finite(r$log2FoldChange) & !is.na(r$GeneID) & nzchar(r$GeneID),]
if(anyDuplicated(r$GeneID)) stop('Duplicate gene identifiers in ranking')
ranks<-setNames(r$log2FoldChange,r$GeneID);ranks<-sort(ranks,decreasing=TRUE)
t2g<-as.data.frame(read_excel(a[2],sheet=3));t2n<-as.data.frame(read_excel(a[2],sheet=4));t2g$TERM<-as.character(t2g$TERM);t2n$TERM<-as.character(t2n$TERM);t2n<-t2n[!duplicated(t2n$TERM),]
set.seed(20261030);g<-GSEA(geneList=ranks,minGSSize=5,maxGSSize=500,pvalueCutoff=1,TERM2GENE=t2g,TERM2NAME=t2n,verbose=FALSE)
dir.create(a[3],recursive=TRUE,showWarnings=FALSE);write.csv(as.data.frame(g),file.path(a[3],'GSEA_all.csv'),row.names=FALSE)
z<-as.data.frame(g);z<-z[z$ID %in% c('00940','map00940'),,drop=FALSE];write.csv(z,file.path(a[3],'GSEA_phenylpropanoid_00940.csv'),row.names=FALSE)
saveRDS(g,file.path(a[3],'GSEA_result.rds'));writeLines(capture.output(sessionInfo()),file.path(a[3],'sessionInfo_GSEA.txt'))
