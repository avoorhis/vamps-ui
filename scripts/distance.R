#!/usr/bin/env Rscript  --slave --no-restore
#
#  filename: distance.R
#
# Expected input file (args[1]):
# TAB delimited matrix:
# UNITS ds1 ds2 ds3 ds4
# tax1  4   7   8   3
# tax2  0   0   1   0
# tax3  6   10  2   0
# The word 'UNITS' in header can be omitted and no space or tab needs to be retained
#    as long as you have header=T in read.table() R is smart enough.
# This table gets inverted with t(data_matrix) below
#
# IMPORTANT: Make sure that numbers have less than 10 significant figures
# or read.table seems to read them as 'factors' rather than numbers

require(vegan,quietly=TRUE);
require(MASS,quietly=TRUE)

args <- commandArgs(TRUE)

matrix_file_path    <- args[1]
out_file_path       <- args[2]
metric              <- args[3]


# check.names=TRUE converts '--' to '..' in project--dataset names (also checks for dups)
# check.names=FALSE: SLM_NIH_Bv4v5--1St_120_Richmond
# row.names=1  gives the column of the row names

data_matrix<-read.table(matrix_file_path, header=T, check.names=FALSE, row.names=1);

# TESTING
#rowcount<-nrow(data_matrix)
#last_name = row.names(data_matrix)[rowcount]
#print(colnames(data_matrix))
#print(rownames(data_matrix))
#print(last_name)
#print(rowcount)
#print(data_matrix[,1])
#print(data_matrix[,2])
#print(str(data_matrix))

# get rid of datasets with zero sum over all the taxa:
data_matrix<-data_matrix[,colSums(data_matrix) > 0]

# IMPORTANT::rotate to have ds as rows
biods = t(data_matrix); 

# must use upper=FALSE so that get_distanceR can parse the output correctly
# dis <- as.matrix(0) # create 1:1 empty matrix (not needed?)

# decostand gets sites as rows
#   and species (or units) as columns
stand <-decostand(data.matrix(biods),"total");

if(metric == "Morisita-Horn"){    
   dis<-vegdist(stand, method="horn",upper=FALSE,binary=FALSE);
}else if(metric == "Yue-Clayton"){
   dis<-designdist(stand, method="1-(J/(A+B-J))",terms = c( "quadratic"), abcd = FALSE)
}else if(metric == "Bray-Curtis"){
   dis<-vegdist(stand, method="bray",upper=FALSE,binary=FALSE);
}else if(metric == "Jaccard"){
   dis<-vegdist(stand, method="jaccard",upper=FALSE,binary=TRUE);
}else if(metric == "Manhattan"){
   dis<-vegdist(stand, method="manhattan",upper=FALSE,binary=FALSE);
}else if(metric == "Raup"){
   dis<-vegdist(stand, method="raup",upper=FALSE,binary=FALSE);
}else if(metric == "Gower"){
    dis<-vegdist(stand, method="gower",upper=FALSE,binary=FALSE);
}else if(metric == "Euclidean"){
    dis<-vegdist(stand, method="euclidean",upper=FALSE,binary=FALSE);
}else if(metric == "Canberra"){
    dis<-vegdist(stand, method="canberra",upper=FALSE,binary=FALSE);
}else if(metric == "Kulczynski"){
    dis<-vegdist(stand, method="kulczynski",upper=FALSE,binary=FALSE);
}else{
    print("ERROR: no distance method found! -- Using Morisita-Horn")
    dis<-vegdist(stand, method="horn",upper=FALSE,binary=FALSE);
}

print(dis);

write.matrix(dis, file = out_file_path, sep = "\t")
q()
