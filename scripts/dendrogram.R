#!/usr/bin/env Rscript  --slave --no-restore
#
#  filename: dendrogram.R
#
#
#
library(ape);

args <- commandArgs(TRUE)
dist_file_path  <- args[1]

out_file_path   <- args[2]
tree_file_path   <- args[3]
metric          <- args[4]
method          <- args[5]

x<-read.delim(dist_file_path, header=T, sep="\t", check.names=FALSE);


#print(x)

x<-as.dist(x)
#print(x)
#pdf(out_file_path, width=10, height=10, title='VAMPS Counts Dendrogram')

hc <- hclust(x)                # apply hirarchical clustering 

# ape(as.phylo) is a generic function which converts an object into a tree of class "phylo".
tree<-as.phylo(hc);
edges<-paste(tree$edge,collapse=',');
lengths<-paste(tree$edge.length,collapse=',');
tiplabels<-paste(tree$tip.label,collapse=',');
numtips<-length(tree$tip.label);
myheight<- numtips*60;
#print(paste('edges',edges,"\nlengths",lengths,'tiplabels',tiplabels,'numtips',numtips, sep=' '))

write.tree(tree, file=tree_file_path)

dend <- as.dendrogram(hc)

png(file=out_file_path,  width=900, height=myheight,  bg='#F8F8FF')


maintitle=paste('VAMPS Cluster Plot Based on Taxonomic Counts (distance metric = ',metric,')\n');

par(mai=c(.5,2.5,.5,4.0));
plot(dend,horiz=TRUE)
title(main=maintitle);
dev.off();