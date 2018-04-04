#!/bin/sh
#$ -cwd
#$ -S /bin/bash
#$ -l h_rt=01:00:00

chr=$1
grm=$2 ## genotyped or imputed

echo "Started at: "`date +"%m/%d/%Y %H:%M:%S"`

plink=/path/to/plink
plink2=/path/to/plink2

if [ $grm == "genotyped" ]; then

#############################
####### GENOTYPE DATA #######
#############################

    ## Identify SNPs with maf>1%, missingness<1%, hwe p>1e-8, and LD pruned at r2=0.2
    $plink --bim /path/to/ukbb/genotypes/ukb_snp_chr"$chr"_v2.bim \
	--bed /path/to/ukbb/genotypes/ukb_cal_chr"$chr"_v2.bed \
	--fam ./ukbb.fam \
	--maf 0.01 \
	--geno 0.01 \
	--hwe 1e-8 \
	--indep-pairwise 50 5 0.2 \
	--out ./ukbb.genotyped.snps.v2.chr$chr \
	--threads 1

    ## Extract those SNPs from the data; these files can be passed to BOLT for the GRM
    $plink --bim /path/to/ukbb/genotypes/ukb_snp_chr"$chr"_v2.bim \
        --bed /path/to/ukbb/genotypes/ukb_cal_chr"$chr"_v2.bed \
        --fam ./ukbb.fam \
	--extract ./ukbb.genotyped.snps.v2.chr$chr.prune.in \
	--make-bed \
	--allow-no-sex \
	--out ./genotyped/ukbb.genotyped.snps.v2.hrc.grm.pruned.chr$chr \
	--threads 1

    ## As an alternative, don't prune and just write out the data for the GRM
    $plink --bim /path/to/ukbb/genotypes/ukb_snp_chr"$chr"_v2.bim \
        --bed /path/to/ukbb/genotypes/ukb_cal_chr"$chr"_v2.bed \
        --fam ./ukbb.fam \
	--maf 0.01 \
	--geno 0.01 \
	--hwe 1e-8 \
	--make-bed \
	--out ./genotyped/ukbb.genotyped.snps.v2.hrc.grm.chr$chr \
	--threads 1

fi

if [ $grm == "imputed" ]; then

    ## identify high-quality SNPs
    zcat /path/to/ukbiobank/snp/info/ukbb_mfi.chr$chr.info_0.8.maf_0.01.snps.txt.gz > ./ukbb_mfi.chr$chr.info_0.8.maf_0.01.snps.txt

############################
####### IMPUTED DATA #######
############################

    ## Convert pvar/pgen to bim/bed/fam
    ## note that this was a pre-generated version of the UK Biobank in 'pfile' format per Plink
    ## Select MAF > 1%, info > 0.8, conversion for imputation is 0.1 (plink default)
    $plink2 --pfile /path/to/UKBIOBANK_Info/plink_format/ukbb.imputation.release2.chr$chr \
	--extract ./ukbb_mfi.chr$chr.info_0.8.maf_0.01.snps.txt \
	--allow-no-sex \
	--make-bed \
	--out ukbb.imputed.snps.v2.chr$chr \
	--memory 50000

    ## Subset to HRC SNPs only, clean on missingness and hwe. Remove duplicate SNPs (caused by UK Biobank 'unraveling' multiallelic SNPs)
    awk ' { print $2 }' ./ukbb.imputed.snps.v2.chr$chr.bim | sort | uniq -d > ukbb.imputed.snps.v2.chr$chr.duplicates

    $plink --bfile ukbb.imputed.snps.chr$chr.v2 \
	--extract /path/to/hrc.snps.list \
	--exclude ukbb.imputed.snps.v2.chr$chr.duplicates \
	--hwe 1e-8 \
	--geno 0.01 \
	--maf 0.01 \
	--make-bed \
	--allow-no-sex \
	--threads 1 \
	--out ./ukbb.imputed.snps.v2.hrc.grm.chr$chr

    ## These steps leave us with 4.9M SNPs that are usable in the GRM; this is probably way too many
    ## SNPs are stored in ./imputed/ukbb.snps.hrc.info_0.8.maf_0.01.cleaned.list.gz

    ## Take a random subset of these SNPs for the GRM
    zcat ./imputed/ukbb.snps.hrc.info_0.8.maf_0.01.cleaned.list.gz | awk ' NR % 5 == 0 ' > ./imputed/ukbb.snps.hrc.info_0.8.maf_0.01.imputed.cleaned.random_1M_subset.list

    ## Prune, to check how many SNPs will be left after LD pruning
    $plink --bfile ./ukbb.imputed.snps..v2.hrc.grm.chr$chr \
	--allow-no-sex \
	--indep-pairwise 50 5 0.2 \
	--out ./ukbb.imputed.snps.v2.hrc.grm.chr$chr

    ## Subset based on either the random subset of 1M SNPs or the pruned SNPs, write out the files for the GRM
    $plink --bfile ./ukbb.imputed.snps.v2.hrc.grm.chr$chr \
	--allow-no-sex \
	--extract ./ukbb.imputed.snps.v2.hrc.grm.chr$chr.prune.in \
	--make-bed \
	--out ./imputed/pruned/ukbb.imputed.snps.v2.hrc.grm.pruned.chr$chr

    $plink --bfile ./ukbb.imputed.snps.v2.hrc.grm.chr$chr \
	--allow-no-sex \
	--extract ./imputed/ukbb.snps.hrc.info_0.8.maf_0.01.imputed.cleaned.random_1M_subset.list \
	--make-bed \
	--out ./imputed/unpruned/ukbb.imputed.snps.v2.hrc.grm.unpruned.chr$chr

fi

echo "Ended at: "`date +"%m/%d/%Y %H:%M:%S"`
