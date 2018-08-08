# Meta-analysis of fat distribution phenotypes in UK Biobank and GIANT
Included in this repository is code and data related to the manuscript 'Meta-analysis of genome-wide association studies for body fat distribution in 694,649 individuals of European ancestry' (available on bioRxiv here: https://www.biorxiv.org/content/early/2018/07/27/304030)

## Part I: Data
Data (including supplementary tables or links to data) produced for the manuscript 'Meta-analysis of genome-wide association studies for body fat distribution in 694,649 individuals of European ancestry.' 

#### 1. Summary-level data from meta-analyses
All summary-level data from the meta-analyses in WHRadjBMI, WHR and BMI can be downloaded here: https://doi.org/10.5281/zenodo.1251813

We are additionally in the process of posting this data to the GIANT website, and will post the link here once that is complete.

#### 2. whradjbmi.giant-ukbb.meta.ecf
An 'ecf' file, the expected format to run Easy Strata (http://homepages.uni-regensburg.de/~wit59712/easystrata/EasyStrata_8.6_Commands_140615.pdf). Can be used with Easy Strata and the summary-level data to regenerate the Manhattan plots, Miami plots, and QQ plots shown in the Supplementary Information.

#### 3. metal_params.example.txt
An example parameters file for running meta-analysis in METAL (https://genome.sph.umich.edu/wiki/METAL_Documentation)

#### 4. Supplementary Table 1: SuppTable1/[whr or whradjbmi].giant-ukbb.meta.1.merged.[index or secondary]Snps.combined.parsed.txt
Files containing summary-level data for index SNPs from analysis of either WHR or WHRadjBMI, and for either index or secondary SNPs. The format of these files is provided in the supplementary information. Columns are: <br />

   _SNP, Chr, Pos, A1, A2, frqA1.combined, beta.combined, se.combined, pval.combined, dir.combined, nmeta.combined, info.combined, [columns w/info for analysis in males and females], psexdiff_  
   
#### 5. Supplementary Table 3: SuppTable2/collider.bias.[sex].index.results.txt
Files containing summary-level data for index SNPs from the WHRadjBMI analyses (combined, females, males) and the results for these SNPs from analysis of WHR and BMI as well. These results were used to test for collider bias. Columns are: <br />

   _SNP, frqA1.whradjbmi, beta.whradjbmi, se.whradjbmi, pval.whradjbmi, frqA1.bmi, beta.bmi, se.bmi, pval.bmi, frqA1.whr, beta.whr, se.whr, pval.whr_    

#### 6. Supplementary Tables 4, 7 and 8
Files containing summary-level data from WHRadjBMI and comparing to the EXTEND dataset (a set of independent samples; SuppTable4) and examining the effect of WHRadjBMI-associated SNPs on body fat percentage (SuppTable7 and SuppTable8).

## Part II: Scripts
Relevant code for analyses included in 'Meta-analysis of genome-wide association studies for body fat distribution in 694,649 individuals of European ancestry'

#### 1. run.bolt.ukbb-anthropometric.sh 
Script for running a genome-wide association study on UK Biobank data, using BOLT-LMM  <br />
Usage: ```./run.bolt.ukbb-anthropometric.sh phenotype ldsc_panel grm grm_snp_subset sex```

#### 2. run.bolt-reml.ukbb-anthropometric.sh
Script for estimating heritability of a trait using UK Biobank data and the restricted maximum likelihood (REML) method implented in BOLT-LMM (i.e., BOLT-REML)  <br />
Usaage: ```./run.bolt-reml.ukbb-anthropometric.sh phenotype ldsc_panel grm grm_snp_subset sex```

#### 3. build_grm.sh
Script for generating data to use as the genetic relationship matrix (GRM) when running BOLT-LMM. The script contains steps to generate a GRM from either genotyped or imputed data  <br />
Usage: ```./build_grm.sh chr imputed_or_genotyped```

#### 4. anthropometricPheno.fat-distn.R
R script for generating phenotypes from UK Biobank data. Specifically, this script helps standardize and normalize the body mass index and waiste-hip ratio traits, as well as generate the waist-hip ratio adjusted for BMI trait. <br />
Usage: ```Rscript anthropometricPheno.fat-distn.R```

#### 5. gctaSelect.sh
Script that calls the GCTA software (http://cnsgenomics.com/software/gcta/GCTA_UserManual_v1.24.pdf) to run joint conditional analysis (to determine independent signals within a single genomic loci). This script can be used to determine independetly-associated signals in the UK Biobank-only GWAS (i.e., the 'meta' argument set to 0) or from the meta-analysis ('meta' argument set to 1). <br />
Usage: ```./gctaSelect.sh phenotype sex chromosome significance_level meta```

#### 6. ldscores.sh
Script for generating LD Scores (https://github.com/bulik/ldsc) from PLINK-formatted data. The GRM can included imputed or genotyped data, contain pruned or unpruned SNPs. <br />
Usage: ```./ldscores.sh grm pruned sample_set chr```

#### 7. ldsc-intercept.sh
Script for estimating the LD Score intercept from GWAS summary-level data. <br />
Usage: ```./ldsc-intercept.sh phenotype sex ldsc_panel```

#### 8. run_metal.sh
Example script for running meta-analysis in METAL (https://genome.sph.umich.edu/wiki/METAL_Documentation). <br />
Usage: ```./run_metal.sh metal_params.example.txt``` <br />
The file metal_params.example.txt is provided as part of this repository.

#### 9. plinkClump.sh
Script for clumping SNPs into loci using the Plink clumping algorithm.  <br />
Usage: ```./plinkClump.sh phenotype sex window```

#### 10. parse_clumps.py
A script to identify the genomic windows that result from the Plink clumping, and then identifying overlapping (and unique) windows to define genomic loci. 

#### 11. easyStrata.R
A script that will run the software Easy Strata, which does a number of things including generating Manhattan and Miami plots, and running the sexual dimorphism test.  <br />
Usage: ```Rscript easyStrata.R input.ecf``` <br />
The 'ecf' file is the expected input for Easy Strata, and the file whradjbmi.giant-ukbb.meta.ecf is included in this repository as an example.

