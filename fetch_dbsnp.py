#!/usr/bin/env python

## script that reads in a list of SNPs and gets the newest dbSNP identifiers for them

from Bio import Entrez
import sys
import time

print(time.ctime())

# Read in the 'chunk' of SNPs (first argument is the SNP name)
print 'This is the chunk argument:', sys.argv[1]

Entrez.email = 'your_email@your_institute.edu'

mySnps = './snps.list.' + sys.argv[1]

# Read in the snp list
with open(mySnps) as f:
    mylist = f.read().splitlines()

# Convert the list of SNPs to a comma-separated string
myString = ",".join(mylist )

handle = Entrez.efetch(db="snp", id=myString, rettype = 'chr', retmode = 'text')

sys.stdout.write(handle.read())
handle.close()

print(time.ctime())
