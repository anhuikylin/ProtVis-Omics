#!/usr/bin/env python3
"""Reconstruct extraction from archived tables; this is not the original processing code."""
from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
data, output = ROOT / 'data', ROOT / 'results'
output.mkdir(exist_ok=True)
ids = pd.read_csv(data / 'phenylpropanoid_feature_ids.csv', dtype=str)
anno = pd.read_csv(data / 'curated_annotations.csv')
matrix = pd.read_csv(data / 'normalized_abundance.csv')
meta = pd.read_csv(data / 'sample_metadata.csv')
for name, frame, key in [('IDs', ids, 'variable_id'), ('annotations', anno, 'variable_id'), ('matrix', matrix, 'variable_id'), ('samples', meta, 'sample_id')]:
    if frame[key].isna().any() or frame[key].duplicated().any():
        raise ValueError(f'{name}: missing or duplicated {key}')
status = ids.merge(anno, on='variable_id', how='left', validate='one_to_one', indicator='annotation_status')
status['matrix_status'] = status.variable_id.isin(matrix.variable_id).map({True: 'present', False: 'missing'})
status.to_csv(output / 'feature_audit.csv', index=False)
selected = status[(status.annotation_status == 'both') & (status.matrix_status == 'present')].drop(columns=['annotation_status','matrix_status'])
selected = selected.merge(matrix, on='variable_id', validate='one_to_one')
for tissue in ['leaf', 'root']:
    sample_ids = meta.loc[(meta['class'] == 'Subject') & (meta.tissue.str.lower() == tissue), 'sample_id'].tolist()
    missing = sorted(set(sample_ids) - set(matrix.columns))
    if missing:
        raise ValueError(f'{tissue}: samples missing in matrix: {missing}')
    selected[['variable_id','Compound.name.collapse','Level.collapse','Adduct.collapse'] + sample_ids].to_csv(output / f'phenylpropanoid_{tissue}.csv', index=False)
print(f'{len(ids)} requested; {len(selected)} have both abundance and annotation. See results/feature_audit.csv')
