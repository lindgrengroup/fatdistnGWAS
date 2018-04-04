#!/bin/sh
#$ -cwd
#$ -P lindgren.prjc
#$ -q short.qc

pheno=$1
sex=$2
window=$3

# make sure plink really knows how many threads it can use! this might be system-specific variable
export OMP_NUM_THREADS=1

plink=/apps/well/plink/1.90b3/plink

for chr in {1..22}; do

# here's the GWAS summary data
# this data is formatted in the same way as is expected by GCTA: SNP A1 A2 freq b se p N
gunzip ./$pheno/summary-ma/$sex/fat-distn.giant.ukbb.meta-analysis.$pheno.$sex.metal.association.stats.hrc.chr$chr.ma.gz

# run the clumping setting genome-wide significance at p = 5e-9 and pruning down to an r2 = 0.05, and allowing p-values down to 0.05
# see the Plink 1.9 documentation for full details
$plink --bfile ./ld-panel/ukbb.imputed.snps.hrc.info_0.3.maf_0.0001.v2.chr$chr \
    --clump ./$pheno/summary-ma/$sex/fat-distn.giant.ukbb.meta-analysis.$pheno.$sex.metal.association.stats.hrc.chr$chr.ma \
    --clump-field p \
    --clump-snp-field SNP \
    --clump-p1 5e-9 \
    --clump-kb "$window"000 \
    --clump-r2 0.05 \
    --clump-p2 0.05 \
    --out ./$pheno/plink-clump/$sex/fat-distn.giant.ukbb.meta-analysis.$pheno.$sex.metal.association.stats.hrc.chr$chr.ma.5e-8.$window.Mb \
    --memory 16000 \
    --threads 1

pigz=/well/lindgren/sara/bin/pigz
$pigz ./$pheno/summary-ma/$sex/fat-distn.giant.ukbb.meta-analysis.$pheno.$sex.metal.association.stats.hrc.chr$chr.ma

done
