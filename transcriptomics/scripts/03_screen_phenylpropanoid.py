#!/usr/bin/env python3
"""Transparent annotation-only candidate screen; not the missing historical code."""
import argparse
from pathlib import Path
import pandas as pd

# Restrict calls to exact KO codes and specific annotation phrases. Broad P450,
# UGT and peroxidase descriptions are deliberately not assigned to a family.
RULES = {
 'PAL': (['K10775'], ['phenylalanine ammonia-lyase','phenylalanine ammonia lyase']),
 'C4H': (['K00487'], ['cinnamate 4-hydroxylase','cinnamate 4-monooxygenase']),
 '4CL': (['K01904'], ['4-coumarate--coa ligase','4-coumarate:coa ligase','4-coumarate-coa ligase']),
 'HCT': (['K13065'], ['shikimate o-hydroxycinnamoyltransferase','hydroxycinnamoyl-coa shikimate']),
 'CCR': (['K09753'], ['cinnamoyl-coa reductase']),
 'CAD': (['K00083'], ['cinnamyl-alcohol dehydrogenase','cinnamyl alcohol dehydrogenase']),
 'COMT': (['K00588'], ['caffeic acid 3-o-methyltransferase','caffeic acid o-methyltransferase']),
 'CCoAOMT': (['K00598'], ['caffeoyl-coa o-methyltransferase']),
 'CHS': (['K00660'], ['chalcone synthase']),
 'CHI': (['K01859'], ['chalcone isomerase']),
 'F3H': (['K00475'], ['flavanone 3-hydroxylase','naringenin 3-dioxygenase']),
 'DFR': (['K13082'], ['dihydroflavonol 4-reductase','dihydroflavonol reductase']),
 'ANS': (['K05277'], ['anthocyanidin synthase','leucoanthocyanidin dioxygenase']),
 'ANR': (['K08695'], ['anthocyanidin reductase']),
 'FLS': (['K05278'], ['flavonol synthase']),
}

def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('annotation',help='eggNOG annotation.txt');p.add_argument('expression',help='expression_result.xlsx')
 p.add_argument('output',help='output CSV');args=p.parse_args()
 a=pd.read_csv(args.annotation,sep='\t',dtype=str,keep_default_na=False,low_memory=False)
 required={'query','Description','Preferred_name','KEGG_ko','KEGG_Pathway'}
 if not required.issubset(a.columns): raise ValueError('Missing columns: '+', '.join(sorted(required-set(a.columns))))
 if a['query'].duplicated().any():raise ValueError('Duplicate annotation query IDs require resolution')
 rna=pd.read_excel(args.expression,sheet_name='count',usecols=['GeneID']);genes=set(rna.GeneID.dropna().astype(str))
 hits=[]
 for _,r in a.iterrows():
  gene=r['query']; desc=(r['Description']+' '+r['Preferred_name']).lower(); ko=set(r['KEGG_ko'].replace('ko:','').split(','))
  pathways=set(r['KEGG_Pathway'].replace('path:','').split(','))
  for family,(ids,phrases) in RULES.items():
   matched=sorted(ko.intersection(ids)); matched_terms=[term for term in phrases if term in desc]
   if matched or matched_terms:
    hits.append({'GeneID':gene,'enzyme_family':family,'KO_match':';'.join(matched),'description_match':';'.join(matched_terms),'KEGG_ko':r['KEGG_ko'],'KEGG_Pathway':r['KEGG_Pathway'],'Description':r['Description'],'Preferred_name':r['Preferred_name'],'RNA_present':gene in genes,'pathway_00940':bool(pathways.intersection({'map00940','ko00940','zma00940'}))})
 out=Path(args.output);out.parent.mkdir(parents=True,exist_ok=True)
 pd.DataFrame(hits,columns=['GeneID','enzyme_family','KO_match','description_match','KEGG_ko','KEGG_Pathway','Description','Preferred_name','RNA_present','pathway_00940']).to_csv(out,index=False)
 print(f'{len(hits)} gene-family matches; {len({h["GeneID"] for h in hits})} unique genes. Candidates require manual validation.')
if __name__=='__main__':main()
