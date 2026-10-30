# B73–Y12 transcriptomics workflow

This directory contains B73 and Y12 expression tables, archived results, and scripts for differential expression, KEGG GSEA, GO/KEGG over-representation analysis, and annotation-based phenylpropanoid candidate screening. The scripts were organized from the available archive; they are not a complete RNA-seq pipeline from raw reads or the missing historical standalone scripts.

## Analysis at a glance

```text
Archived count + TPM matrices
           │
           ├── DESeq2: B73 versus Y12
           │      ├── ranked KEGG GSEA → pathway 00940
           │      └── up/down genes → GO and KEGG enrichment
           │
annotation.txt ── candidate gene-family screening
                         │
                    RNA matrix membership
```

Candidate screening is independent of the differential-expression results. A gene appearing in the expression matrix is not necessarily expressed, differentially expressed, or functionally validated.

## Inputs and files

| File | Role |
| --- | --- |
| [data/expression_result.xlsx](data/expression_result.xlsx) | Archived `count` and `tpm` sheets, each with 54,845 gene rows and six samples: `B73_1–3` and `Y12_1–3`. |
| [data/Enrichmentdb2.xlsx](data/Enrichmentdb2.xlsx) | GO term-to-gene and term-to-name tables in sheets 1–2; KEGG tables in sheets 3–4. |
| [data/map00940_annotation.xlsx](data/map00940_annotation.xlsx) | Historical project annotation for pathway 00940; not used by the annotation-only candidate script. |
| `annotation.txt` | Original eggNOG-style annotation table from `02.MaizeTeosintePro/02.data/Database/`. **Not included** here; provide its local path for candidate screening. |
| [results/](results/) | Historical `DEG.xlsx`, `KEGGenrich.xlsx` and `phe_expmat.xlsx`; these are archived results, not outputs from the scripts below. |

The six samples' tissue composition, count-generation method, reference genome and annotation versions should be confirmed from the original records. Raw reads are not supplied.

## Environment

The R scripts require `readxl`, `writexl`, `DESeq2`, and `clusterProfiler`. The screening script requires Python 3, `pandas`, and `openpyxl`. Install compatible R/Bioconductor versions and record them for any new run; original package versions are unavailable.

```r
install.packages(c("readxl", "writexl"))
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install(c("DESeq2", "clusterProfiler"))
```

```bash
python -m pip install pandas openpyxl
```

## Step 1 — differential expression

[01_differential_expression.R](scripts/01_differential_expression.R) reads the count and TPM sheets, checks the six sample columns and gene identifiers, fits `~ group` with DESeq2, and computes **B73 minus Y12**. It also reports group mean TPM values. Gene labels use adjusted P < 0.05 with log2FC > 1 for B73-up and log2FC < −1 for B73-down. Genes without adjusted P values are marked `not_tested`.

The supplied count sheet has **55,856 fractional entries**. The script refuses fractional counts by default. The archived script used `ceiling()`; the optional flag below repeats that choice but does not establish its statistical validity. Check how counts were generated and whether a suitable quantifier-specific import is needed before interpreting DESeq2 results.

Run from `transcriptomics/` after reviewing the input:

```bash
# Include the flag only when deliberately reproducing the archived rounding choice.
Rscript scripts/01_differential_expression.R data/expression_result.xlsx output --historical-ceiling
```

Outputs: `output/DESeq2_B73_vs_Y12.csv`, `output/dds.rds`, and `output/sessionInfo.txt`. The archived DEG workbook reports 4,559 up and 6,126 down entries; those are historical labels, not a verified rerun.

## Step 2 — KEGG GSEA

[02_gsea.R](scripts/02_gsea.R) ranks genes with finite B73-versus-Y12 log2FC, uses the KEGG term tables from `Enrichmentdb2.xlsx`, and runs `clusterProfiler::GSEA` with gene-set sizes 5–500, `pvalueCutoff = 1`, and seed `20261030`. It exports pathway 00940 by identifier; the pathway-specific CSV can be empty if that term is absent from the GSEA result.

```bash
Rscript scripts/02_gsea.R output/DESeq2_B73_vs_Y12.csv data/Enrichmentdb2.xlsx output/gsea
```

Outputs: `GSEA_all.csv`, `GSEA_phenylpropanoid_00940.csv`, `GSEA_result.rds`, and `sessionInfo_GSEA.txt`. The historical plotting script selected result row 6 while labeling the figure phenylpropanoid; row 6 in the archived GSEA table is mismatch repair. The new script selects the pathway by ID and does not produce that historical plot.

## Step 3 — GO and KEGG over-representation analysis

[04_enrichment.R](scripts/04_enrichment.R) separates the DE genes into up and down sets using the same thresholds. The universe consists of genes with finite adjusted P values and finite log2FC in the input result; actual term matching depends on the supplied database. GO and KEGG are evaluated separately with gene-set sizes 5–500. The script requests results at `pvalueCutoff = 1` and `qvalueCutoff = 1`; evaluate the reported adjusted P values when interpreting terms.

```bash
Rscript scripts/04_enrichment.R output/DESeq2_B73_vs_Y12.csv data/Enrichmentdb2.xlsx output/enrichment
```

Outputs are `GO_up_ORA.csv`, `GO_down_ORA.csv`, `KEGG_up_ORA.csv`, and `KEGG_down_ORA.csv` when matching results exist, plus `sessionInfo_ORA.txt`. The historical script used an implicit default universe, so the new results need not match the archived workbook.

## Step 4 — screen phenylpropanoid-related genes

[03_screen_phenylpropanoid.py](scripts/03_screen_phenylpropanoid.py) reads only `annotation.txt` for functional assignments. It matches explicit KO codes and specific description phrases listed in the script and records the matching evidence, annotation fields and whether each ID occurs in the count sheet. Generic P450, UGT and peroxidase descriptions are not automatically assigned to specific enzymes.

```bash
python scripts/03_screen_phenylpropanoid.py /path/to/annotation.txt data/expression_result.xlsx output/phenylpropanoid_candidates.csv
```

Output rows are **gene–family matches**, so a gene can appear more than once. The check on the supplied files yielded 190 records and 187 unique genes; all 187 IDs occur in the RNA count table. A previously available workbook contains 227 unique candidates and also used a project map00940 table: 187 overlap, leaving 40 older candidates outside the narrower rules. The script is a new transparent screen, not the missing original screening code; its rules are not exhaustive and all matches require manual and experimental validation.

## Validation and provenance

The Python screening script was executed against the supplied inputs. The three R scripts have **not** been executed end-to-end in the current environment; verify dependencies and results in a compatible R/Bioconductor installation. Numerical reproduction, sample composition and upstream quantification remain to be checked. Script outputs in `output/` are separate from historical files in `results/`.
