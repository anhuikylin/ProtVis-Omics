# ProtVis-Omics

This repository contains transcriptomics and metabolomics analysis code and supporting data for a B73 and Y12 study associated with [ProtVis](https://github.com/anhuikylin/ProtVis). The analyses were organized around gene expression, metabolite profiles, and phenylpropanoid metabolism.

## Overview

### Transcriptomics

The transcriptomics workflow compares gene expression between B73 and Y12 and examines biological pathways associated with expression differences. It includes differential expression analysis, gene set enrichment analysis, GO and KEGG enrichment analysis, and annotation-based screening of phenylpropanoid-related genes.

The scripts, expression matrices and archived analysis results are in [transcriptomics/](transcriptomics/). See its [README](transcriptomics/README.md) for the analysis overview and file descriptions.

### Metabolomics

Raw metabolomics data were converted with tidyMass. The converted data and sample information were imported into MetMiner for peak extraction and subsequent data processing. The workflow includes feature quality control, missing-value imputation, normalization, metabolite annotation and integration of ion modes. Phenylpropanoid-related metabolite features were then extracted from the archived results.

The data tables, archived processing objects, reference modules and extraction script are in [metabolomics/](metabolomics/). See its [README](metabolomics/README.md) for the analysis overview and file descriptions.

## Repository structure

| Directory | Contents |
| --- | --- |
| [transcriptomics/](transcriptomics/) | Gene expression analysis scripts, expression and annotation tables, and archived results. |
| [metabolomics/](metabolomics/) | Metabolomics data tables, archived processing objects, MetMiner reference modules, and a feature extraction script. |

## Data and code availability

The repository includes processed data and selected archived results. Raw sequencing reads, raw instrument files and some original processing records are not included. The organized scripts include newly prepared analyses; their relationship to the archived results and their validation status are described in the respective directories.

Metabolite annotations and gene-family assignments represent candidates for further evaluation. The transcriptomics count input contains fractional values and its origin should be checked before differential expression analysis. Selected MetMiner source modules are provided with their [license](metabolomics/reference/MetMiner/LICENSE); see the [metabolomics workflow guide](metabolomics/WORKFLOW.md) for source and processing details.
