#!/bin/bash
#$ -cwd
#$ -pe shmem 14
#$ -q long.qc
#$ -P lindgren.prjc

pheno=$1 ## bmi, whr, whradjbmi
ldsc=$2 ## ukbb.10k.imp.r2, baseline
grm=$3 ## imputed, h2.grm
subset=$4 ## pruned
sex=$5 ## combined, females, males

echo "************************************************************"
echo "Started at: "`date +"%m/%d/%Y %H:%M:%S"`
echo "************************************************************"

mygrm=/path/to/grm/$grm/$subset

## Set up the phenotype information
if [ $pheno == "bmi" ]; then
    myPhenoCol="res_bmi_inv"
elif [ $pheno == "whr" ]; then
    myPhenoCol="res_whr_inv"
elif [ $pheno == "whradjbmi" ]; then
    myPhenoCol="res_whrAdjBMI_inv"
fi

## Set up the ldscore file
if [ $ldsc == "ukbb.10k.imp.r2" ]; then
    ldscore_file="/path/to/ldscores/sensitivityAnalysis/10k/ukbb.imputed.pruned.v2.10k.a.l2.ldscore.gz"
    ldscore_header="L2"
elif [ $ldsc == "baseline" ]; then
    ldscore_file="/path/to/ldscores/sensitivityAnalysis/1000G_Phase3_baselineLD_ldscores/baselineLD.all_chr.l2.ldscore.gz"
    ldscore_header="baseL2"
    ldscore_header="L2"
fi

echo $myPhenoCol $ldscore_file

/apps/well/bolt-lmm/2.3/bolt \
    --reml \
    --bim $mygrm/ukbb.$grm.snps.v2.hrc.grm.$subset.chr{1:22}.bim \
    --bed $mygrm/ukbb.$grm.snps.v2.hrc.grm.$subset.chr{1:22}.bed \
    --fam $mygrm/ukbb.$grm.snps.v2.hrc.grm.$subset.chr1.fam \
    --exclude=/path/to/snps/ukbb.non-hrc.snps.txt \
    --remove /path/to/samples/bolt.in_plink_but_not_imputed.FID_IID.968.txt \
    --remove /path/to/samples/ukbb.dropSamples.sex-mismatch.txt \
    --remove /path/to/samples/ukbb.dropSamples.sampleMissingness-0.05.txt \
    --remove /path/to/samples/ukbb.dropSamples.het.missing.outliers.txt \
    --remove /path/to/samples/ukbb.dropSamples.consentRevoked.txt \
    --phenoFile=/path/to/phenotypes/UKBiobank.BMI_WHR_WHRadjBMI.inv_residuals.$sex.v2.bolt.txt \
    --phenoCol=$myPhenoCol \
    --covarFile=/path/to/phenotypes/UKBiobank.BMI_WHR_WHRadjBMI.covariates.v2.bolt.txt \
    --covarCol=ArrayType \
    --LDscoresFile=$ldscore_file \
    --LDscoresCol=$ldscore_header \
    --geneticMapFile=/path/to/recombination/maps/genetic_map_hg19_withX.txt.gz \
    --numThreads=14 \
    --verboseStats \
    --maxModelSnps 10000000

echo "Ended at: "`date +"%m/%d/%Y %H:%M:%S"`
