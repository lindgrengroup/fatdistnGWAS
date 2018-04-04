#!/usr/bin/env python

import sys

## import numpy and pandas
import numpy
import pandas

## set the phenotype, sex, and chromosome from the command line or hard code it (for testing)
## eg for debugging: pheno = 'bmi'; sex = 'combined'; chr = 18
pheno = sys.argv[1]
sex = sys.argv[2]
chr = sys.argv[3]

## read in the genomic positions in the bim file
bim_data = './ld-panel/ukbb.imputed.snps.hrc.info_0.3.maf_0.0001.v2.chr' + str(chr) + '.bim'
bim = pandas.read_table(bim_data, header=-1)

## read in the Plink clumping results
## change significance level in the file name, if necessary
sig = '5e-9'

clumps_data = ('./' + pheno + '/plink-clump/' + sex + '/fat-distn.giant.ukbb.meta-analysis.' + pheno + '.' + sex +
               '.metal.association.stats.hrc.chr' + str(chr) + '.ma.' + sig + '.5.Mb.clumped')
clumps = pandas.read_table(clumps_data, header=0, delim_whitespace=1)
clumps = pandas.DataFrame(clumps)

## sort the clumps file so that it is in genomic order
clumps = clumps.sort_values('BP')

## identify the genomic regions (loci) from the ld clumping
final_result = numpy.empty((0,4))

def find_window(i):

    ## annotate the index SNP of the first listed clump
    index_snp = clumps.iloc[i,2]
    posindex = bim.loc[bim[1] == index_snp]; posindex = posindex.iloc[0,3]

    ## identify the first and last snp in the clump of this index snp.
    ## The clump does not include the index SNP, so check to see if that SNP is at the start of the window
    snplist = pandas.Series(clumps.iloc[i:i+1,11:12]); snplist = snplist.str.split(',',expand=True)

    ## positions of the first and last snps in the window
    snp1 = snplist.iloc[0,0]; snp1 = snp1[0:-3] # start snp

    ## if there are no SNPs in the clump, this will happen
    if snp1 != 'N':
        pos1 = bim.loc[bim[1] == snp1]; pos1 = pos1.iloc[0,3]

        snp2 = snplist.iloc[0,-1]; snp2 = snp2[0:-3] # end snp
        pos2 = bim.loc[bim[1] == snp2]; pos2 = pos2.iloc[0,3]

        ## check to see if the index SNP has an earlier position in the genome than the first SNP in the clump
        pos1 = min(pos1,posindex)

    ## otherwise, set the positions when there are additional SNPs in the clump
    else:
        pos1 = posindex
        snp2 = index_snp
        pos2 = pos1

    ## add a tiny bit of buffer to around the positions
    pos1 = pos1 - 1000
    pos2 = pos2 + 1000

    ## store the results
    result = [chr, index_snp, pos1, pos2]
    return(result)

## generate the genomic windows from the LD clumping
for i in range(0,numpy.shape(clumps)[0]):
    result = find_window(i)
    final_result = numpy.append(final_result, [result], axis=0)

final_result = pandas.DataFrame(final_result)
final_result[2] = final_result[2].astype(int); final_result[3] = final_result[3].astype(int)
final_result = pandas.DataFrame(final_result.sort_values(2, ascending=True))

## write out the results
raw_windows = ('./' + pheno + '/plink-clump/' + sex + '/windows/fat-distn.giant.ukbb.meta-analysis.' + pheno + '.' + sex +
               '.metal.association.stats.hrc.chr' + str(chr) + '.ma.5e-9.5.Mb.clumped.raw_windows.txt')
final_result.to_csv(raw_windows, index=0, sep=' ')

## now find the overlapping windows and merge them
def merge_intervals(intervals):

    ## sort the intervals that are given to the function by their lower bound
    sorted_by_lower_bound = sorted(intervals, key=lambda tup: tup[0])
    merged = []

    for higher in sorted_by_lower_bound:
        if not merged:
            merged.append(higher)
        else:
            lower = merged[-1]

            ## test for intersection between lower and higher:
            ## we know via sorting that lower[0] <= higher[0]
            if higher[0] <= lower[1]:
                upper_bound = max(lower[1], higher[1])
                merged[-1] = (lower[0], upper_bound)  ## replace by merged interval
            else:
                merged.append(higher)
    return merged

## reformat the intervals from final_result into the paired intervals
x = final_result[2].tolist()
y = final_result[3].tolist()
intervals = zip(x, y)

## run the function on our genomic intervals
if __name__ == '__main__':

    merged_list = merge_intervals(intervals)
    genomic_windows = pandas.DataFrame.from_records(merged_list)

    ## save the windows
    windows = ('./' + pheno + '/plink-clump/' + sex + '/windows/fat-distn.giant.ukbb.meta-analysis.' + pheno + '.' + sex +
               '.metal.association.stats.hrc.chr' + str(chr) + '.ma.' + sig + '.5.Mb.clumped.windows.txt')
    genomic_windows.to_csv(windows, index=0, sep=' ')

## use the genomic windows to find the list of snps in each locus. write out the list to be used in gcta
for i in range(0,numpy.shape(genomic_windows)[0]):

    locus_snps = bim.loc[(bim[3] >= int(genomic_windows.iloc[i,0])) & (bim[3] <= int(genomic_windows.iloc[i,1]))]
    locus_snps = locus_snps[1]

    data_name = ('./' + pheno + '/plink-clump/' + sex + '/loci-lists/fat-distn.giant.ukbb.meta-analysis.' + pheno + '.' + sex +
                 '.metal.association.stats.hrc.chr' + str(chr) + '.ma.' + sig + '.5.Mb.clumped.locus' + str(i) + '.txt')
    locus_snps.to_csv(data_name, index=0)
