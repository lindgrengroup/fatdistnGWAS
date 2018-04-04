#!/bin/sh
#$ -cwd
#$ -pe shmem 1
#$ -q short.qc

pheno=$1
sex=$2
ldpanel=$3 ## pointer to which LDSC panel to use

# Reformat GWAS data into LDSC format
# unique ID, A1, A2, n, pval, beta
# This process is described in the LDSC GitHub repo: https://github.com/bulik/ldsc

# Find the sample size for this phenotype/analysis
# format of this file: column 1, phenotype; column 2; sex (combined, females males); column 3, sample size
my_n=`cat ./anaylysis.sample_n.txt | awk ' $1=="'$pheno'" && $2=="'$sex'" { print $3 } '`

# Reformat into LDSC-friendly format
# this is parsing e.g., output from BOLT-LMM
echo "snpid a1 a2 info n beta pval" > ./ukbb.fat-distn.$pheno.bolt.association.$sex.hrc.ldsc.input.txt
zcat /path/to/summary-level/gwas/$pheno/ukbb.fat-distn.$pheno.bolt.association.$sex.imputed.ukbb.10k.imp.r2.stats.bgen.infinitesimal.hrc.txt.gz | \
    awk -F '\t' ' { print $1, $5, $6, $8, '$my_n', $11, $14 } ' | fgrep -w -v SNP >> ./ukbb.fat-distn.$pheno.bolt.association.$sex.hrc.ldsc.input.txt

# Now we can start estimating the LD Score intercept
# Point to the reference LD score panels
if [ $ldpanel == "baseline" ]; then
    ld_dir="/path/to/ldscores/sensitivityAnalysis/1000G_Phase3_baselineLD_ldscores/baseline."
elif [ $ldpanel == "ukbb" ]; then
    ld_dir="/path/to/ldscores/sensitivityAnalysis/h2.grm/ukbb.h2.grm.pruned.v2.10k.a.chr"
fi

echo $ld_dir

# First 'munge stats' for LDSC Intercept estimation (see https://github.com/bulik/ldsc for details)
/resources/anaconda2/bin/python2.7 /resources/ldsc/munge_sumstats.py \
    --sumstats ./ukbb.fat-distn.$pheno.bolt.association.$sex.hrc.ldsc.input.txt \
    --N $my_n \
    --out ./ukbb.fat-distn.$pheno.bolt.association.$sex.hrc.ldsc

# Now we can calculate the intercept (and heritability (h2) while we're at it)
/resources/anaconda2/bin/python2.7 /resources/ldsc/ldsc.py \
    --h2 ./ukbb.fat-distn.$pheno.bolt.association.$sex.hrc.ldsc.sumstats.gz \
    --ref-ld-chr $ld_dir \
    --w-ld-chr $ld_dir \
    --out ./ukbb.fat-distn.$pheno.bolt.association.$sex.hrc.ldsc.$ldpanel.h2
