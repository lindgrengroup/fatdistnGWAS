# Meta-analysis of fat distribution phenotypes in UK Biobank and GIANT
Included in this repository is code and data related to the manuscript 'Meta-analysis of genome-wide association studies for body fat distribution in 694,649 individuals of European ancestry' (available on bioRxiv here: XXX)


#### 1. run.bolt.ukbb-anthropometric.sh
Script for running a genome-wide association study on UK Biobank data, using BOLT-LMM
Usage: ```./run.bolt.ukbb-anthropometric.sh phenotype ldsc_panel grm grm_snp_subset sex```

#### 2. run.bolt-reml.ukbb-anthropometric.sh
Script for estimating heritability of a trait using UK Biobank data and the restricted maximum likelihood (REML) method implented in BOLT-LMM (i.e., BOLT-REML)
Usaage: ```./run.bolt-reml.ukbb-anthropometric.sh phenotype ldsc_panel grm grm_snp_subset sex```

#### 3. build_grm.sh
Script for generating data to use as the genetic relationship matrix (GRM) when running BOLT-LMM. The script contains steps to generate a GRM from either genotyped or imputed data
Usage: ```./build_grm.sh chr imputed_or_genotyped```
