# Results from joint conditional analysis

To identify independent signals within the same locus, we performed joint conditional analysis in each associated locus using the GCTA 'Select' method.

We identified associated loci and performed conditional/joint analysis by:  
  - Running the Plink clumping algorithm, setting genome-wide significance at p = 5e-9, r^2 = 0.05, and a window of 5Mb.     
  - Finding the genomic window defined by each 'clump' produced by Plink (i.e., identifying the downstream-most and upstream-most SNPs)  
  - Running GCTA Select in each window. To run GCTA, we used a subset of ~20,000 unrelated UK Biobank individuals to estimate LD.  

## Contents of tarballs provided here

Each tarball is constructed as:  

    [phenotype]/gcta-slct/[sex]/
  
Phenotype can be: bmi (body mass index), whr (waist-to-hip ratio), or whradjbmi (waist-to-hip ratio adjusted for BMI).  
Sex can be: combined (i.e., all samples), females, males.

Each directory contains a .jma.cojo and .ldr.cojo file per locus. The .jma.cojo file contains the independent signal(s) in that locus, as determined by GCTA Select. The .ldr.cojo file contains the linkage disequilibrium (r^2) calculations between all indepedent signal(s).
