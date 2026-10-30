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

See the [transcriptomics README](transcriptomics/README.md) for setup and running instructions.

## Metabolomics workflow

1. **Raw-data conversion.** The project used tidyMass for raw metabolomics data conversion. The exact formats, conversion command and software version still require confirmation.
2. **MetMiner import and peak extraction.** The converted mass-spectrometry data and [sample metadata](metabolomics/data/sample_metadata.csv) were imported into MetMiner, where peak extraction was performed. The original peak-picking parameters are not available in this repository. The archived [feature matrix](metabolomics/data/raw_feature_matrix.csv) is already downstream of peak extraction.
3. **Quality control and normalization.** MetMiner was used for noisy-feature and outlier review, missing-value imputation and normalization. Stored objects record KNN imputation and SVR normalization in both ion modes.
4. **Annotation and integration.** MetMiner was used for feature annotation and filtering, followed by integration of positive and negative modes. Some matching parameters are retained in the [processing record](metabolomics/results/archived_process_info.json); database identities and versions require confirmation.
5. **Phenylpropanoid-related features.** [01_extract_phenylpropanoids.py](metabolomics/scripts/01_extract_phenylpropanoids.py) audits seven archived feature IDs and extracts the five found in both the curated annotation and normalized matrix. See [feature_audit.csv](metabolomics/results/feature_audit.csv).

The [29 archived R objects](metabolomics/archived_objects/) preserve the two original project directories and positive/negative processing stages. The [MetMiner source modules](metabolomics/reference/MetMiner/) are an attributed reference snapshot, not a standalone installation or proof of the exact version originally used.

See the [metabolomics README](metabolomics/README.md) for setup and running instructions, and the [workflow guide](metabolomics/WORKFLOW.md) for processing details.

## Reproducibility and provenance

Raw sequencing reads and raw MS1 instrument files are not included. Original peak-picking settings, some quality-control and differential-analysis parameters, database versions and the exact historical project scripts remain unavailable. Historical result workbooks are provided as archived outputs; the new scripts should be evaluated separately before being claimed to reproduce them.

Metabolite names and gene-family annotations are candidate assignments and should not be interpreted as experimentally confirmed identities or functions. When using the copied MetMiner source, retain its [MIT license](metabolomics/reference/MetMiner/LICENSE) and cite the upstream software as described in the [workflow guide](metabolomics/WORKFLOW.md).
