# ProtVis-Omics

Analysis code and supporting data for the B73 and Y12 transcriptomics and metabolomics study, associated with [ProtVis](https://github.com/anhuikylin/ProtVis). This repository organizes the available project files from `02.MaizeTeosintePro.zip`.

The two workflows share a focus on phenylpropanoid metabolism. They are documented separately because the available transcriptomics and metabolomics data have different sample structures and processing histories.

## Repository overview

| Directory | Contents |
| --- | --- |
| [transcriptomics/](transcriptomics/) | Expression matrices, differential expression, GSEA, GO/KEGG enrichment, and candidate gene screening. |
| [metabolomics/](metabolomics/) | Feature matrices, sample metadata, archived R objects, MetMiner reference modules, and phenylpropanoid feature extraction. |

```text
ProtVis-Omics/
├── transcriptomics/
│   ├── scripts/            Differential expression, GSEA, gene screening, enrichment
│   ├── data/               Count/TPM and annotation workbooks
│   └── results/            Archived transcriptomics result workbooks
└── metabolomics/
    ├── scripts/            Phenylpropanoid feature extraction
    ├── data/               Feature matrices, metadata, annotation and candidate IDs
    ├── results/            Feature audit, extracted tables and processing records
    ├── archived_objects/   Original R objects, grouped by project and ion mode
    └── reference/          Selected MetMiner source modules and license
```

## Transcriptomics workflow

The archived expression workbook contains count and TPM sheets for three B73 and three Y12 samples. The exact sample tissue composition, upstream read-processing method and reference annotation version should be checked against the original sample and sequencing records.

1. **Prepare input.** Use [expression_result.xlsx](transcriptomics/data/expression_result.xlsx) and [Enrichmentdb2.xlsx](transcriptomics/data/Enrichmentdb2.xlsx). Supply the project's `annotation.txt` separately for candidate screening; it is not included in this repository.
2. **Differential expression.** [01_differential_expression.R](transcriptomics/scripts/01_differential_expression.R) compares B73 with Y12 using DESeq2. The selection uses adjusted P < 0.05 and |log2 fold change| > 1; positive values indicate higher expression in B73.
3. **GSEA.** [02_gsea.R](transcriptomics/scripts/02_gsea.R) ranks genes by B73-versus-Y12 log2 fold change and reports the full KEGG result and pathway 00940, phenylpropanoid biosynthesis.
4. **Functional enrichment.** [04_enrichment.R](transcriptomics/scripts/04_enrichment.R) performs GO and KEGG over-representation analysis separately for up- and down-regulated genes. Its universe comprises genes with estimable adjusted P values.
5. **Candidate gene screening.** [03_screen_phenylpropanoid.py](transcriptomics/scripts/03_screen_phenylpropanoid.py) searches `annotation.txt` using explicit KO and description rules and reports RNA-matrix membership. Matches are candidates requiring further annotation and validation.

The archived count sheet contains fractional entries. The differential expression script stops on these values by default; `--historical-ceiling` explicitly repeats the archived upward rounding only after count provenance has been checked. The newly organized R scripts have **not** been run end-to-end in an R environment. The original standalone screening script was not found; the annotation-only screen is a new, narrower reconstruction.

See the [transcriptomics README](transcriptomics/README.md) for input requirements, commands, and interpretation.

## Metabolomics workflow

1. **Input and import.** The available [feature matrix](metabolomics/data/raw_feature_matrix.csv) contains feature identifiers, m/z, retention time, polarity and abundance values; [sample metadata](metabolomics/data/sample_metadata.csv) records sample and QC information. This matrix is already downstream of peak detection and is not raw instrument data.
2. **Data cleaning.** MetMiner output paths and archived processing records support a workflow involving noise and outlier review, missing-value imputation and normalization. The recorded objects indicate KNN imputation and SVR normalization for both ion modes.
3. **Annotation and integration.** MetMiner reference modules cover feature annotation and filtering, followed by integration of positive and negative modes. Some matching parameters are retained in the [processing record](metabolomics/results/archived_process_info.json); database identities and versions require confirmation.
4. **Phenylpropanoid-related features.** [01_extract_phenylpropanoids.py](metabolomics/scripts/01_extract_phenylpropanoids.py) audits the seven archived feature IDs and extracts those present in both the curated annotation and normalized matrix. Five features are retained; the two missing matches are documented in [feature_audit.csv](metabolomics/results/feature_audit.csv).

The [29 archived R objects](metabolomics/archived_objects/) preserve the two original project directories and positive/negative processing stages. The [MetMiner source modules](metabolomics/reference/MetMiner/) are an attributed reference snapshot, not a standalone installation or proof of the exact version originally used.

See the [metabolomics README](metabolomics/README.md) and [workflow guide](metabolomics/WORKFLOW.md) for recorded parameters, input details and the MetMiner operation guide.

## Running the available scripts

For transcriptomics, install R packages `readxl`, `writexl`, `DESeq2`, and `clusterProfiler`, plus Python packages `pandas` and `openpyxl`. Run the scripts from the `transcriptomics/` directory as described in its README; the count provenance must be reviewed before opting into historical rounding.

For the metabolomics candidate extraction:

```bash
cd metabolomics
python -m pip install -r requirements.txt
python scripts/01_extract_phenylpropanoids.py
```

Use the complete upstream [MetMiner](https://github.com/ShawnWx2019/MetMiner) application and its [cookbook](https://shawnwx2019.github.io/metminer-cookbook/) for interactive preprocessing and annotation. The copied reference modules do not independently reproduce the historical run.

## Reproducibility and provenance

Raw sequencing reads and raw MS1 instrument files are not included. Original peak-picking settings, some quality-control and differential-analysis parameters, database versions and the exact historical project scripts remain unavailable. Historical result workbooks are provided as archived outputs; the new scripts should be evaluated separately before being claimed to reproduce them.

Metabolite names and gene-family annotations are candidate assignments and should not be interpreted as experimentally confirmed identities or functions. When using the copied MetMiner source, retain its [MIT license](metabolomics/reference/MetMiner/LICENSE) and cite the upstream software as described in the [workflow guide](metabolomics/WORKFLOW.md).
