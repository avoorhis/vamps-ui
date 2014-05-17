args <- commandArgs(TRUE)
#print(args)
prefix <- args[1]
distmetric <- args[2]
tree_type <- args[3]
treefile <- args[4]


library(ape)
require(vegan,quietly=TRUE);

dend <- read.tree(treefile)
numtips<-length(dend$tip.label);
myheight<- numtips*50;
plotname <- paste(prefix,'_tree.png',sep='');
filename <-paste('/usr/local/www/vamps/docs/tmp/',plotname,sep='')
png(file=filename, pointsize = 10, width=800, height=myheight, bg='#F8F8FF')
#par(mai=c(.5,2.5,.5,4.0));
plot(dend)
#plot(dend,type="fan", edge.width=2, edge.color="purple")
add.scale.bar(x=0, y=.5, length=.01)
htime<-Sys.time();
if(tree_type=='UPGMA'){
    cluster_method<-'PHYLIP:UPGMA'
}else if(tree_type=='Neighbor_Joining'){
    cluster_method<-'PHYLIP:Neighbor Joining'
}else if(tree_type=='Weighbor'){
    cluster_method<-'PHYLIP:Weighted Neighbor Joining'
}else if(tree_type=='Fitch'){
    cluster_method<-'PHYLIP:Fitch'
}else if(tree_type=='Kitsch'){
    cluster_method<-'PHYLIP:Kitsch'
}else{
    cluster_method<-tree_type
}

maintitle=paste('VAMPS Cluster Plot Based on Taxonomic Counts\n(clustering method = ',cluster_method,'; distance metric = ',distmetric,')\n',htime);
title(main=maintitle);
dev.off();
sink();