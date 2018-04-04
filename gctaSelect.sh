#!/bin/sh
#$ -cwd
#$ -pe threaded 4
#$ -l h_rt=08:00:00

gcta=/path/to/software/gcta64/gcta64
home=/path/to/meta-analysis/index-snps

pheno=$1
sex=$2
chr=$3
sig=$4
meta=$5

if [ $meta == 0 ]; then
    my_ma="fat-distn.ukbb.$pheno.$sex.bolt.association.stats.bgen.infinitesimal.hrc.chr$chr.ma"
elif [ $meta == 1 ]; then
    my_ma="fat-distn.giant.ukbb.meta-analysis.$pheno.$sex.metal.association.stats.hrc.chr$chr.ma"
fi

# The GCTA data for this is set up so that the *.ma files contain summary-level information per associated locus
# For more information on GCTA formatting, see here: http://cnsgenomics.com/software/gcta/GCTA_UserManual_v1.24.pdf
# significance was set at 5e-9 to account for the dense SNP data

for locus in {0..100}; do
if [ -f /path/to/$pheno/gcta-slct/$sex/loci-lists/fat-distn.giant.ukbb.meta-analysis.$pheno.$sex.metal.association.stats.hrc.chr$chr.ma.5e-9.5.Mb.clumped.locus$locus.txt ]; then

    # use cojo-slct to identify independently-associated SNPs that reside in the same genomic locus
    $gcta --bfile $home/ld-panel/ukbb.imputed.snps.hrc.info_0.3.maf_0.0001.v2.chr$chr \
	--extract /path/to/$pheno/gcta-slct/$sex/loci-lists/fat-distn.giant.ukbb.meta-analysis.$pheno.$sex.metal.association.stats.hrc.chr$chr.ma.5e-9.5.Mb.clumped.locus$locus.txt \
	--chr $chr \
	--cojo-file $home/$pheno/summary-ma/$sex/$my_ma \
	--cojo-p $sig \
	--cojo-slct \
	--thread-num 4 \
	--out /path/to/$pheno/gcta-slct/$sex/$my_ma.$sig.locus$locus

fi

done
