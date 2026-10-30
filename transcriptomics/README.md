# B73 and Y12 transcriptomics

This directory contains analysis scripts and supporting data for the comparison of B73 and Y12 gene expression. The analyses explore differential gene expression and biological pathways, with particular attention to phenylpropanoid metabolism.

## Analysis overview

Gene expression matrices were used to compare B73 and Y12. Differentially expressed genes were examined through GO and KEGG enrichment analysis, while gene set enrichment analysis (GSEA) was used to assess expression patterns across pathways. Phenylpropanoid-related gene candidates were screened using functional annotations.

The corresponding scripts are:

| Script | Analysis |
| --- | --- |
| [01_differential_expression.R](scripts/01_differential_expression.R) | Compare B73 and Y12 gene expression using DESeq2. |
| [02_gsea.R](scripts/02_gsea.R) | Perform KEGG gene set enrichment analysis and extract the phenylpropanoid biosynthesis result. |
| [03_screen_phenylpropanoid.py](scripts/03_screen_phenylpropanoid.py) | Screen functional annotations for phenylpropanoid-related gene candidates. |
| [04_enrichment.R](scripts/04_enrichment.R) | Perform GO and KEGG enrichment analysis of differentially expressed genes. |

The candidate screen uses annotation-based rules and reports supporting information for each match. These assignments describe gene-family candidates and require further evaluation.

## Data and results

| File or directory | Contents |
| --- | --- |
| [data/expression_result.xlsx](data/expression_result.xlsx) | Archived gene count and TPM expression matrices. |
| [data/Enrichmentdb2.xlsx](data/Enrichmentdb2.xlsx) | GO and KEGG annotation tables used for enrichment analysis. |
| [data/map00940_annotation.xlsx](data/map00940_annotation.xlsx) | Archived phenylpropanoid pathway gene annotations. |
| `annotation.txt` | Project functional annotation table used for candidate screening; provide this file separately from the original project archive. |
| [results/](results/) | Archived differential expression, enrichment, and phenylpropanoid-related expression results. |

## Analysis notes

The expression workbook contains fractional count values; their origin should be checked before differential expression analysis. The screening script was prepared from the available annotation records rather than recovered as the original screening script. The Python screening script has been checked against the supplied files; the R scripts have not yet been run end-to-end in a compatible R environment.

Raw reads and complete upstream sequencing and quantification records are not included. Sample composition and reference annotation details should be checked against the original project records.
