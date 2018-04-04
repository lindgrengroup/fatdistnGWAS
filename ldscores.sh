#!/bin/sh
#$ -cwd
#$ -S /bin/bash
#$ -q short.qc

date +"%m/%d/%Y %H:%M:%S"

mygrm=$1 ## genotyped, imputed
myprune=$2 ## pruned, unpruned
sample=$3 ## label for sample set
chr=$4

grm=/path/to/grm/$mygrm/$myprune
home=/path/to/ldscores
plink=/path/to/plink

# repeated this across multiple 'chunks' of samples drawn, to test stability of the ld score metric across samples from UK Bionbank
for chunk in a b c d e; do

## Shrink the input data and add information from a recombination map
$plink --bfile $grm/ukbb.$mygrm.snps.v2.hrc.grm.$myprune.chr$chr \
    --allow-no-sex \
    --make-bed \
    --keep $home/sensitivityAnalysis/$sample/subset.samples.$sample.$chunk \
    --maf 0.0001 \
    --cm-map /path/to/1000GP_Phase3/genetic_map_chr@_combined_b37.txt \
    --threads 1 \
    --out $home/sensitivityAnalysis/$sample/ukbb.$mygrm.$myprune.v2.$sample.$chunk.chr$chr

$plink --bfile $grm/ukbb.$mygrm.snps.v2.hrc.grm.$myprune.chr$chr \
    --allow-no-sex \
    --make-bed \
    --keep $home/sensitivityAnalysis/$sample/subset.samples.$sample.$chunk \
    --cm-map /path/to/1000GP_Phase3/genetic_map_chr@_combined_b37.txt \
    --threads 1 \
    --out $home/sensitivityAnalysis/$sample/ukbb.$mygrm.$myprune.v2.$sample.$chunk.chr$chr

## Calculate LD-scores following the LDSC documentation (https://github.com/bulik/ldsc)
/resources/anaconda2/bin/python2.7 /resources/ldsc/ldsc.py \
    --bfile $home/sensitivityAnalysis/$sample/ukbb.$mygrm.$myprune.v2.$sample.$chunk.chr$chr \
    --l2 \
    --ld-wind-cm 1 \
    --out $home/sensitivityAnalysis/h2.grm/ukbb.$mygrm.$myprune.v2.$sample.$chunk.chr$chr \
    --yes-really

if [ -f $home/sensitivityAnalysis/$sample/ukbb.$mygrm.$myprune.v2.$sample.$chunk.chr$chr.l2.ldscore.gz ]; then
    rm $home/sensitivityAnalysis/$sample/ukbb.$mygrm.$myprune.v2.$sample.$chunk.chr$chr.bed
    rm $home/sensitivityAnalysis/$sample/ukbb.$mygrm.$myprune.v2.$sample.$chunk.chr$chr.fam
    rm $home/sensitivityAnalysis/$sample/ukbb.$mygrm.$myprune.v2.$sample.$chunk.chr$chr.bim
fi

done
