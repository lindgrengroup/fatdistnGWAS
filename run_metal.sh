#!/bin/sh
#$ -cwd
#$ -l h_rt=01:00:00

pheno=$1
sex=$2
sample=$3

## example call to run METAL
## see repo for example METAL parameters file

metal=/apps/well/metal/20110325/metal

echo "=== Beginning meta-analysis ==="
echo "=== Running: $pheno $sex    ==="

$metal ./$pheno/$sex/metal_params.$pheno.$sex.$sample.txt

mv ./METAANALYSIS1.TBL ./$pheno/$sex/fat-distn.giant.ukbb.meta-analysis.$pheno.$sex.$sample.tbl
mv ./METAANALYSIS1.TBL.info ./$pheno/$sex/fat-distn.giant.ukbb.meta-analysis.$pheno.$sex.$sample.tbl.info

echo "=== $pheno $sex analysis complete ==="
