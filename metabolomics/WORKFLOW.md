# Metabolomics workflow: evidence and reproduction

This guide distinguishes the archived B73/Y12 results from the public MetMiner source code. The archived `02.MaizeTeosintePro.zip` contains a feature matrix and downstream output, not the complete original run record. The source files copied here are an unmodified reference snapshot; they do not establish the exact version or settings used for this project.

## Stages

| Stage | Archived evidence | Reference source | What can be concluded |
| --- | --- | --- | --- |
| Raw data conversion and MS1 processing | The project owner confirmed tidyMass for raw-data conversion; `expmat.csv` is already a feature table and MS2 MGF files are present in the archive. | [data_import_raw.R](reference/MetMiner/R/data_import_raw.R) documents a MetMiner raw-input option; it is reference code, not a confirmed original run script. | Raw MS1 files and a peak-picking run record were not identified. Exact file formats, conversion command, tidyMass version and peak-picking settings remain unverified. |
| Feature table import | `expmat.csv`, `sample_info.csv`, and `Tables_StepbyStep/3.4.tblImport_expmat_check.csv`. | [data_import_tbl.R](reference/MetMiner/R/data_import_tbl.R) creates an import check using the same output name. | Strong evidence that MetMiner's table import was used for this output; source alone does not prove settings or version. |
| Noise and sample review | `3.6.2.NoisyinNegMod.csv` and `object_*_mv.rda`, `object_*_outlier.rda` appear in the archive. | [data_rm_noise.R](reference/MetMiner/R/data_rm_noise.R), [data_rm_outlier.R](reference/MetMiner/R/data_rm_outlier.R), [save_massobj.R](reference/MetMiner/R/save_massobj.R). | Output names are consistent with these stages. Thresholds and excluded samples are not established. |
| Missing-value handling | `object_*_impute.rda`. | [data_mv_impute.R](reference/MetMiner/R/data_mv_impute.R). | Archived process records show KNN, rowmax 0.5, colmax 0.8, maxp 1500, and rng.seed 362436069 for both ion modes. |
| Normalization | `object_*_norm.rda` and `Norm_expmat.xlsx`. | [data_normalization.R](reference/MetMiner/R/data_normalization.R). | Archived process records show method svr, keep_scale TRUE, multiple 1, and threads 1 for both ion modes. |
| Annotation and filtering | `object_*_anno.rda`, `object_*_af.rda`, `Result/Database/auto_saved.dblist`, and annotation tables. | [annotation.R](reference/MetMiner/R/annotation.R), [annotation_filtering.R](reference/MetMiner/R/annotation_filtering.R). | Names match the software. The archived process records include matching parameters, but database identities and versions require verification. |
| Merge and export | `Result/Data_Export/object_merge.rda`, `table_merge.xlsx`, and MetDNA exports. | [data_merge.R](reference/MetMiner/R/data_merge.R). | The matching names support MetMiner export; they do not imply confirmed metabolite identities. |
| Differential analysis | `Result/DAM/*/DAM_analysis.xlsx` and `opls-da.png` are present in the archive. | [dam_result.R](reference/MetMiner/R/dam_result.R). | The output naming matches MetMiner; individual contrasts, test direction, thresholds and adjustment method require verification. |
| Candidate extraction | `phe_key_id.xlsx` and `phe_key_mat.xlsx`. | [01_extract_phenylpropanoids.py](scripts/01_extract_phenylpropanoids.py), written for this repository. | Reproduces the five stored annotated abundance rows; it does not recover the original biological selection criteria. |

## MetMiner operation guide

The output paths and object histories strongly support MetMiner for the archived table-processing stages. Follow the [official project setup](https://shawnwx2019.github.io/metminer-cookbook/content/Project_init.html), [data import and cleaning](https://shawnwx2019.github.io/metminer-cookbook/content/Import_data.html), [feature annotation](https://shawnwx2019.github.io/metminer-cookbook/content/feature_anno.html), and [DAM analysis](https://shawnwx2019.github.io/metminer-cookbook/content/dam.html) instructions:

1. Set the working directory and upload the sample information CSV. Verify sample identifiers, classes, groups, batches and injection order.
2. Import the feature table and MS/MS data when available, then check the imported sample and feature information. An existing feature table starts downstream of peak detection.
3. Review the data, remove noisy features and outliers, impute missing values, and normalize. Save the processing settings and inspect quality-control plots.
4. Select annotation databases, set matching parameters, run annotation and filtering, then merge positive and negative modes.
5. Configure the comparison groups and DAM test parameters, check the comparisons and run the analysis. Export the results and record the precise direction and thresholds.
6. For the archived phenylpropanoid list, run the repository's extraction script described below; review candidate identities and the feature audit.

### Settings recovered from archived objects

The `process_info` slots of four archived `02.TQMSDataProcessing/Result/{POS,NEG}/Objects/step1/object_*_{norm,af}.rda` objects were parsed. A selective machine-readable record with source-file SHA-256 hashes is provided in [results/archived_process_info.json](results/archived_process_info.json); local paths, sample-ID lists, and database objects were omitted from the export.

- Both positive and negative processing histories record `impute_mv(method = "knn", rowmax = 0.5, colmax = 0.8, maxp = 1500, rng.seed = 362436069)`.
- Both record `normalize_data(method = "svr", keep_scale = TRUE, multiple = 1, threads = 1)`. This supports SVR normalization for these stored objects; it does not demonstrate an additional PQN step.
- Both annotation histories record `ms1.match.ppm = 35`, `ms2.match.ppm = 35`, `mz.ppm.thr = 400`, `ms2.match.tol = 0.5`, `rt.match.tol = 30`, `total.score.tol = 0.5`, and `candidate.num = 3`. See the JSON for the other recorded weights and settings.
- Recorded filtering expressions refer to `qc_na_freq` and `S_na_freq`, but the numerical values of those variables were not recovered. Database identities, versions, and the exact project-specific running script are not established by these records.

These are values recorded in the stored objects, not evidence that the entire original analysis has been reproduced. The original MS1 peak-picking procedure and DAM settings remain unverified.

## Inputs and execution

1. For the archived table stage, review [data/raw_feature_matrix.csv](data/raw_feature_matrix.csv) and [data/sample_metadata.csv](data/sample_metadata.csv). The former contains feature identifiers, m/z, retention time, ion mode and sample/QC abundance columns; it is not raw instrument data.
2. Use the full [MetMiner repository](https://github.com/ShawnWx2019/MetMiner) and its [cookbook](https://shawnwx2019.github.io/metminer-cookbook/) for installation and interactive execution. The copied R files are Shiny modules and do not form a standalone executable pipeline. Supply project inputs and document all choices made in a new run.
3. The archived R objects are available in [archived_objects/](archived_objects/); the original MS2 MGF files remain in the supplied archive and are not included in this repository. Raw MS1 instrument files and the original parameters have not been located.
4. To rerun only the downstream extraction from the supplied processed tables, execute `python -m pip install -r requirements.txt`, then `python scripts/01_extract_phenylpropanoids.py` from this directory. Outputs go to `results/`.

## Parameter record needed for an exact rerun

The object records recover the imputation, normalization and selected annotation arguments listed above. Still needed are the exact software and database versions, MS1 peak-picking settings and sample-to-file mapping, numerical quality and missingness thresholds, sample exclusions, database identities, and differential comparison direction, tests, cutoffs and multiple-testing correction. Do not substitute defaults for missing project settings.

The archived candidate list has seven feature IDs. Five are both annotated and present in the normalized matrix. `M165T197_POS` lacks an annotation in the supplied curated table, and `M195T267_POS` lacks a row in the normalized matrix. See [feature_audit.csv](results/feature_audit.csv). Multi-name annotations remain putative and should not be treated as individually confirmed identifications.

## Third-party source provenance

The reference files are copied without modification from [ShawnWx2019/MetMiner](https://github.com/ShawnWx2019/MetMiner), commit [`6585bbccccd0fa82b18a4ead0086f94cf4fe9d3f`](https://github.com/ShawnWx2019/MetMiner/tree/6585bbccccd0fa82b18a4ead0086f94cf4fe9d3f). Copyright (c) 2024 Shawn Wang; see the accompanying [MIT license](reference/MetMiner/LICENSE) and [DESCRIPTION](reference/MetMiner/DESCRIPTION). This is a subset of the upstream repository, not a complete installation and not a claim that this revision generated the archived data. For publication, cite MetMiner as specified by the upstream repository: [doi:10.1111/jipb.13774](https://doi.org/10.1111/jipb.13774).
