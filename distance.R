#  filename: distance.R
#
#
require(vegan,quietly=TRUE);
args <- commandArgs(TRUE)
matrix_in <- args[1]
metric <- args[2]
# prefix is the filename prefix 
prefix <- args[3]
page <- args[4]

data_matrix<-read.delim(matrix_in, header=T,sep="\t",check.names=TRUE,row.names=1);

rowcount<-nrow(data_matrix)
last_name = row.names(data_matrix)[rowcount]


# get rid of datasets with zero sum over all the taxa:
data_matrix<-data_matrix[,colSums(data_matrix) > 0]

biods = t(data_matrix); #
#print(biods);

#  http://cc.oulu.fi/~jarioksa/softhelp/vegan/html/vegdist.html
# must use upper=FALSE so that get_distanceR can parse the output correctly
dis <- as.matrix(0)
if(metric == "horn" || metric == "Morisita-Horn"){
    stand <-decostand(data.matrix(biods),"total");
   dis<-vegdist(stand, method="horn",upper=FALSE,binary=FALSE);
}else if(metric == "yue-clayton" || metric == "Yue-Clayton"){
    
    stand <-decostand(data.matrix(biods),"total");
   dis<-designdist(stand, method="1-(J/(A+B-J))",terms = c( "quadratic"), abcd = FALSE)
}else if(metric == "morisita"){
    
    stand <-decostand(data.matrix(biods),"total");
   dis<-vegdist(stand, method="morisita",upper=FALSE,binary=FALSE);
}else if(metric == "bray" || metric == "Bray-Curtis"){
    
    stand <-decostand(data.matrix(biods),"total");
   dis<-vegdist(stand, method="bray",upper=FALSE,binary=FALSE);
}else if(metric == "jaccard" ||  metric == "Jaccard"){
    #print('using vegdist')
    stand <-decostand(data.matrix(biods),"total");
   dis<-vegdist(stand, method="jaccard",upper=FALSE,binary=TRUE);
}else if(metric == "jaccard2"){
    #print('using designdist')
    stand <-decostand(data.matrix(biods),"total");
    dis<-designdist(stand, method = "(A+B-2*J)/(A+B-J)",terms = c("binary"))
  
}else if(metric == "manhattan"){
    
    stand <-decostand(data.matrix(biods),"total");
   dis<-vegdist(stand, method="manhattan",upper=FALSE,binary=FALSE);
}else if(metric == "raup"){
    
    stand <-decostand(data.matrix(biods),"total");
   dis<-vegdist(stand, method="raup",upper=FALSE,binary=FALSE);
}else if(metric == "gower"){
    
    stand <-decostand(data.matrix(biods),"total");
    #print(stand)
    dis<-vegdist(stand, method="gower",upper=FALSE,binary=FALSE);
}else if(metric == "euclidean"){
    
    stand <-decostand(data.matrix(biods),"total");
    dis<-vegdist(stand, method="euclidean",upper=FALSE,binary=FALSE);
}else if(metric == "canberra"){
    
    stand <-decostand(data.matrix(biods),"total");
    dis<-vegdist(stand, method="canberra",upper=FALSE,binary=FALSE);
}else if(metric == "kulczynski"){
    
    stand <-decostand(data.matrix(biods),"total");
    dis<-vegdist(stand, method="kulczynski",upper=FALSE,binary=FALSE);
}else if(metric == "mountford"){
    
    stand <-decostand(data.matrix(biods),"total");
    dis<-vegdist(stand, method="mountford",upper=FALSE,binary=FALSE);
}else if(metric == "chao_j"){
   require(fossil,quiet=TRUE);
   #dis<-vegdist(stand, na.rm=TRUE, method="chao",upper=FALSE,binary=FALSE); 
   dis<-ecol.dist(data_matrix, method = chao.jaccard, type = "dis");   
}else if(metric == "chao_s"){
   require(fossil,quiet=TRUE);
   dis<-ecol.dist(data_matrix, method = chao.sorenson, type = "dis");   
}else if(metric == "pearson"){
   
   dis<-cor(data_matrix, method = 'pearson')
   dis<-(1-abs(dis))

}else if(metric == "correlation"){
   require(amap,quiet=TRUE);   
   dis<-Dist(decostand(data.matrix(biods),"total"), method = 'correlation',upper=FALSE)   
}else if(metric == "spearman"){

   dis<-cor(data_matrix, method = 'spearman')
   dis<-(1-abs(dis))

}else{
    #print("ERROR: no distance method found!")
}

if(page != "trees"){
   print(dis);
   q();
}
q()
