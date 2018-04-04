# load the Easy Strata library (http://homepages.uni-regensburg.de/~wit59712/easystrata/EasyStrata_8.6_Commands_140615.pdf)
library(EasyStrata)

# set the script up so that it takes the Easy Strata ecf file as input (and will then just run)
input=commandArgs(trailingOnly=T)[1]
EasyStrata(input)





#### Example
#extDataDir=system.file("extdata", package="EasyStrata")
#### Example Pipeline:
#ecfPipe=paste(extDataDir,"example_pipeline.ecf",sep="/")
#EasyStrata(ecfPipe)
