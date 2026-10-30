# B73–Y12 metabolomics workflow

This directory contains the archived B73/Y12 metabolomics feature tables, selected intermediate R objects, MetMiner reference source modules, and a script to extract the archived phenylpropanoid-related feature list. The archived metadata covers leaf and root samples at the recorded stages.

The project used **tidyMass for raw metabolomics data conversion**, as confirmed by the project owner. The repository starts from an **already generated feature table**. Raw MS1 instrument files, the original peak-picking run record, and the complete project-specific processing scripts are not available here.

## Analysis at a glance

1. Convert the raw metabolomics data with tidyMass.
2. Import the converted mass-spectrometry data and sample information into MetMiner; perform peak extraction.
3. Review the feature data, remove noisy features and outliers, impute missing values, and normalize each ion mode.
4. Annotate and filter features, then integrate positive- and negative-mode results.
5. Extract the archived phenylpropanoid-related features for leaf and root.

This workflow order follows the project owner's description. The archived feature-table import check documents a table-import operation as well; the available files do not establish how that operation relates to the earlier converted-data import. Peak-picking parameters and software versions still need to be recovered.

## Inputs and archived files

| File or directory | Role |
| --- | --- |
| [data/raw_feature_matrix.csv](data/raw_feature_matrix.csv) | Original `expmat.csv` feature table, including m/z, retention time, ion mode, QC and sample columns. It is not raw instrument data. |
| [data/sample_metadata.csv](data/sample_metadata.csv) | Sample ID, injection order, class, group, batch, species, tissue and stage. |
| [data/normalized_abundance.csv](data/normalized_abundance.csv) | CSV conversion of archived `Norm_expmat.xlsx`, sheet 1. |
| [data/curated_annotations.csv](data/curated_annotations.csv) | CSV conversion of `anno_bi_final.xlsx`, sheet 1. |
| [data/phenylpropanoid_feature_ids.csv](data/phenylpropanoid_feature_ids.csv) | Seven archived feature IDs from `phe_key_id.xlsx`. |
| [data/original_phenylpropanoid_leaf.csv](data/original_phenylpropanoid_leaf.csv) and [root CSV](data/original_phenylpropanoid_root.csv) | Conversions of the two `phe_key_mat.xlsx` sheets. The root sheet had no feature-ID column; its row order was checked against the leaf sheet. |
| [archived_objects/](archived_objects/) | 29 byte-verified `.rda` files, preserving `01.mrm_selection` and `02.TQMSDataProcessing`, polarities and original stage names. |
| [reference/MetMiner/](reference/MetMiner/) | Selected unmodified MetMiner source modules and their [MIT license](reference/MetMiner/LICENSE); this is not the complete application. |
| [results/](results/) | Candidate extraction tables, audit and selected archived processing metadata. |

CSV files converted from workbooks retain the values read from the specified sheets, not Excel formatting. The archived MS2 MGF files, other database files and figures are not included here. See [WORKFLOW.md](WORKFLOW.md) for source-to-output evidence.

## Upstream — raw data conversion

The project used tidyMass for raw metabolomics data conversion. The converted data and sample information were then imported into MetMiner. Original instrument files and the conversion script are not included; the precise input/output formats, command and tidyMass version require the original records.

## Step 1 — import the converted data and extract peaks

Use the full [MetMiner application](https://github.com/ShawnWx2019/MetMiner) and its [official cookbook](https://shawnwx2019.github.io/metminer-cookbook/). Set a working directory and import the sample information, checking sample IDs, experimental groups, QC labels, batch and injection order. Import the converted mass-spectrometry data and any applicable MS/MS data, check the positive- and negative-mode inputs, and perform peak extraction in MetMiner.

Review the resulting feature data and verify that sample IDs match the metadata. The archived [feature matrix](data/raw_feature_matrix.csv) contains feature identifiers, m/z, retention time, ion mode and abundance columns; it is an extracted table, not instrument raw data. A separate archived `3.4.tblImport_expmat_check.csv` also matches a MetMiner feature-table import check. The relationship between that table import and the earlier converted-data import remains to be confirmed.

The original peak-extraction settings, MetMiner version and conversion command have not been recovered. The copied [MetMiner modules](reference/MetMiner/) are reference source, not a complete application or a verified copy of the original project run.

## Step 2 — review and clean the data

Follow MetMiner's overview, noisy-feature and outlier review steps for each ion mode. The archive includes intermediate `object_*_mv.rda` and `object_*_outlier.rda` files. The recorded filters reference QC and sample missingness thresholds, but their numerical values and any excluded samples have not been established.

The stored positive and negative `process_info` records show KNN imputation:

```text
method = knn; rowmax = 0.5; colmax = 0.8
maxp = 1500; rng.seed = 362436069
```

These are recorded arguments in the archived objects, not proof that every upstream setting has been recovered.

## Step 3 — normalize

The positive and negative stored objects record `normalize_data(method = "svr", keep_scale = TRUE, multiple = 1, threads = 1)`. Review QC and sample distributions before and after normalization, and retain the settings and output objects. These records support SVR for the stored objects; they do not demonstrate an additional PQN step.

## Step 4 — annotate, filter and integrate

Select appropriate databases and document their versions, then annotate and filter candidate matches in MetMiner. Stored annotation histories include `ms1.match.ppm = 35`, `ms2.match.ppm = 35`, `mz.ppm.thr = 400`, `ms2.match.tol = 0.5`, `rt.match.tol = 30`, `total.score.tol = 0.5`, and `candidate.num = 3`. The selected [processing record](results/archived_process_info.json) contains additional weights and source-object checksums.

The archive also contains `object_merge.rda` and a `table_merge.xlsx` export. Database identities, versions, and the complete historical annotation decision record still require verification. Multiple candidate names do not establish a unique metabolite identity.

## Step 5 — extract the archived phenylpropanoid feature list

[01_extract_phenylpropanoids.py](scripts/01_extract_phenylpropanoids.py) is a new reconstruction of the downstream table extraction; it is not the original selection script. It joins the seven archived IDs to the curated annotations and normalized matrix, checks identifier uniqueness and sample columns, and exports annotated leaf and root tables.

Run from `metabolomics/`:

```bash
python -m pip install -r requirements.txt
python scripts/01_extract_phenylpropanoids.py
```

The script writes and **overwrites** [results/feature_audit.csv](results/feature_audit.csv), `results/phenylpropanoid_leaf.csv`, and `results/phenylpropanoid_root.csv`. Five features occur in both required tables. `M165T197_POS` is missing from the curated annotation table, and `M195T267_POS` is missing from the normalized matrix; both remain in the audit and are excluded from extracted abundance tables. The five reconstructed leaf/root abundance values match the archived tables after accounting for the original root sheet's row order.

## Reproducibility and source

The extraction script has been run against the supplied tables. Peak extraction and MetMiner preprocessing have not been rerun here. Exact software/database versions, raw MS1 inputs, peak-picking settings, missingness thresholds and sample exclusions require the original records.

The reference modules are copied from [ShawnWx2019/MetMiner](https://github.com/ShawnWx2019/MetMiner) at commit [`6585bbccccd0fa82b18a4ead0086f94cf4fe9d3f`](https://github.com/ShawnWx2019/MetMiner/tree/6585bbccccd0fa82b18a4ead0086f94cf4fe9d3f), copyright 2024 Shawn Wang, under the accompanying MIT license. Cite MetMiner according to its documentation: [doi:10.1111/jipb.13774](https://doi.org/10.1111/jipb.13774).
