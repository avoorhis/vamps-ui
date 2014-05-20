#  filename: distance.R
#
# Expected input file (args[1]):
# TAB delimited matrix:
# UNITS ds1 ds2 ds3 ds4
# tax1  4   7   8   3
# tax2  0   0   1   0
# tax3  6   10  2   0
#
require(vegan,quietly=TRUE);
require(MASS)
args <- commandArgs(TRUE)
matrix_file_path <- args[1]
out_file_path <- args[2]
metric <- args[3]
# prefix is the out filename prefix 



data_matrix<-read.delim(matrix_file_path, header=T,sep="\t",check.names=TRUE,row.names=1);

rowcount<-nrow(data_matrix)
last_name = row.names(data_matrix)[rowcount]


# get rid of datasets with zero sum over all the taxa:
data_matrix<-data_matrix[,colSums(data_matrix) > 0]

biods = t(data_matrix); # rotate to have ds as rows

# must use upper=FALSE so that get_distanceR can parse the output correctly
# dis <- as.matrix(0) # create 1:1 empty matrix

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
    #print("ERROR: no distance method found!")
}

print(dis);

write.matrix(dis, file = out_file_path, sep = "\t")
