# B73 and Y12 metabolomics

This directory contains metabolomics data tables, archived processing objects, reference source modules and a phenylpropanoid-related feature extraction script. The analyses examine metabolite profiles in B73 and Y12 samples.

## Analysis overview

Raw metabolomics data were converted with tidyMass. The converted mass-spectrometry data and sample information were imported into MetMiner for peak extraction and subsequent analysis. Data processing included quality control, removal of noisy features and outliers, missing-value imputation and normalization. Metabolite features were then annotated, filtered and integrated across positive and negative ion modes.

Phenylpropanoid-related metabolite features were extracted from the archived candidate list and matched to the annotation and abundance tables. These features are putative metabolite assignments.

| File | Analysis |
| --- | --- |
| [01_extract_phenylpropanoids.py](scripts/01_extract_phenylpropanoids.py) | Match archived phenylpropanoid-related feature IDs to annotation and abundance tables and export leaf and root results. |
| [MetMiner reference modules](reference/MetMiner/) | Source modules corresponding to data import, quality control, normalization, annotation and integration. |

The MetMiner modules are a partial reference snapshot and require the full application. The extraction script was newly prepared from archived results.

## Data and results

| File or directory | Contents |
| --- | --- |
| [data/raw_feature_matrix.csv](data/raw_feature_matrix.csv) | Archived metabolite feature matrix. |
| [data/sample_metadata.csv](data/sample_metadata.csv) | Sample, group, tissue and quality-control information. |
| [data/normalized_abundance.csv](data/normalized_abundance.csv) | Archived normalized metabolite abundance matrix. |
| [data/curated_annotations.csv](data/curated_annotations.csv) | Curated feature annotation table. |
| [data/phenylpropanoid_feature_ids.csv](data/phenylpropanoid_feature_ids.csv) | Archived phenylpropanoid-related feature list. |
| [archived_objects/](archived_objects/) | R objects from the original metabolomics processing directories. |
| [results/](results/) | Extracted feature tables, feature audit and selected processing records. |

## Analysis notes

The original instrument files and complete processing records are not included. The archived feature table is downstream of peak extraction. The extracted feature tables can be traced to the available candidate, annotation and abundance files; the script and audit record which candidates can be matched.

For processing provenance and a detailed account of the archived objects, see [WORKFLOW.md](WORKFLOW.md). MetMiner reference source files are included under their accompanying [MIT license](reference/MetMiner/LICENSE).
