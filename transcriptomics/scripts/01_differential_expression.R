#!/usr/bin/env Rscript
# Archived analysis design; fractional counts require explicit opt-in to historical ceiling.
suppressPackageStartupMessages({library(readxl); library(DESeq2); library(writexl)})
a <- commandArgs(trailingOnly=TRUE)
if (length(a) < 2) stop('Usage: Rscript 01_differential_expression.R expression_result.xlsx output_dir [--historical-ceiling]')
x <- read_excel(a[1], sheet='count'); tpm <- read_excel(a[1], sheet='tpm')
samples <- c(paste0('B73_',1:3),paste0('Y12_',1:3))
stopifnot(all(c('GeneID',samples) %in% names(x)), all(c('GeneID',samples) %in% names(tpm)), !anyDuplicated(x$GeneID))
m <- as.matrix(x[,samples]); storage.mode(m) <- 'double'
if(any(!is.finite(m)) || any(m<0)) stop('Counts contain missing, non-finite or negative values')
if(any(m != floor(m))) {
 if (!('--historical-ceiling' %in% a)) stop('Fractional counts: verify source or explicitly opt in to --historical-ceiling')
 warning('Applying historical ceiling; validate count provenance before interpretation');m <- ceiling(m)
}
if(any(m > .Machine$integer.max)) stop('Count exceeds R integer range')
storage.mode(m) <- 'integer'; rownames(m) <- x$GeneID
coldata <- data.frame(group=factor(rep(c('B73','Y12'),each=3),levels=c('B73','Y12')), row.names=samples)
dds <- DESeq(DESeqDataSetFromMatrix(countData=m,colData=coldata,design=~group))
r <- as.data.frame(results(dds,contrast=c('group','B73','Y12'))); r$GeneID <- rownames(r)
idx <- match(r$GeneID,tpm$GeneID);r$B73_TPM_mean <- rowMeans(as.matrix(tpm[idx,samples[1:3]]));r$Y12_TPM_mean <- rowMeans(as.matrix(tpm[idx,samples[4:6]]))
r$regular <- ifelse(is.na(r$padj),'not_tested',ifelse(r$padj<0.05 & r$log2FoldChange>1,'up',ifelse(r$padj<0.05 & r$log2FoldChange< -1,'down','not_sig')))
dir.create(a[2],recursive=TRUE,showWarnings=FALSE);write.csv(r,file.path(a[2],'DESeq2_B73_vs_Y12.csv'),row.names=FALSE);saveRDS(dds,file.path(a[2],'dds.rds'));writeLines(capture.output(sessionInfo()),file.path(a[2],'sessionInfo.txt'))
