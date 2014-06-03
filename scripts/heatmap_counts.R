#!/usr/bin/env Rscript  --slave --no-restore
#
#  filename: heatmap.R
#
#
#

require(vegan,quietly=TRUE);
library(pheatmap) 
library(RColorBrewer)

args <- commandArgs(TRUE)
counts_matrix_file_path <- args[1]
out_file_path           <- args[2]
metric                  <- args[3]  # distance
rank                    <- args[4]  # rank


data_matrix<-read.delim(counts_matrix_file_path, header=T, sep="\t", check.names=FALSE, row.names=1);
data_matrix<-data_matrix[,colSums(data_matrix) > 0]
x<-as.matrix(data_matrix)

ncols<-ncol(x)
nrows<-nrow(x)


# columns are datasets
# need to get the sum of each column
#print(colSums(x))
#print(x/colSums(x))
#print(x)
#print(colSums(x))
# this divides each count by the col sum
#x = x/colSums(x)

# rows (taxa)
if (nrow(x) <= 30 ){
    h<-7
}else if(nrow(x) > 30 && nrow(x) <= 80){
    h<-12
}else if(nrow(x) > 80 && nrow(x) <= 150){
    h<-20
}else if(nrow(x) > 150 && nrow(x) <= 300){
    h<-30
}else if(nrow(x) > 300 && nrow(x) <= 400){
    h<-40
}else if(nrow(x) > 400 && nrow(x) <= 500){
    h<-50
}else if(nrow(x) > 500 && nrow(x) <= 600){
    h<-60
}else if(nrow(x) > 600 && nrow(x) <= 700){
    h<-70
}else if(nrow(x) > 700 && nrow(x) <= 800){
    h<-80
}else if(nrow(x) > 800 && nrow(x) <= 900){
    h<-90
}else if(nrow(x) > 900 && nrow(x) <= 1000){
    h<-100
}else if(nrow(x) > 1000 && nrow(x) <= 1100){
    h<-110
}else if(nrow(x) > 1100 && nrow(x) <= 1200){
    h<-120
}else{
    h<-130
}
# cols (datasets)
if (ncol(x) <= 5){
    w<-10
}else if(ncol(x) > 5 && ncol(x) <= 15){
    w<-14
}else if(ncol(x) > 15 && ncol(x) <= 30){
    w<-20
}else if(ncol(x) > 30 && ncol(x) <= 50){
    w<-23
}else if(ncol(x) > 50 && ncol(x) <= 70){
    w<-26
}else if(ncol(x) > 70 && ncol(x) <= 90){
    w<-29
}else if(ncol(x) > 90 && ncol(x) <= 110){
    w<-32
}else{
    w<-35
}
print(paste("rows:",nrow(x),"h:",h))
print(paste("cols:",ncol(x),"w:",w))
#k=x
#dimnames(k) <- NULL 
#annotation = data.frame(factor(1:ncol(x) %% 2 == 0, labels = c("Even", "Odd")))
#print(data_matrix)
#head(x)
pdf_title="VAMPS Frequency Heatmap"


#print(h)
#print(w)
pdf(out_file_path, width=w, height=h, title=pdf_title)


if(rank==tolower("Genus") || rank==tolower("species") || rank==tolower("strain")){
    r_margin=35
}else if(rank==tolower("Class") || rank==tolower("Order") || rank==tolower("Family")){
    r_margin=20
}else{
    r_margin=10
}

fontsize_row = 8
fontsize_col = 8

# clustering methods
if(metric=='Morisita-Horn'){ 
    meth <- 'horn'
    text <- "Morisita-Horn"
}else if(metric=='Bray-Curtis'){
    meth <- 'bray'
    text <- "Bray-Curtis"
}else if(metric=='Jaccard'){
    meth <- 'jaccard'
    text <- "Jaccard"
}else if(metric=='Manhattan'){
    meth <- 'manhattan'
    text <- "Manhattan"
}else if(metric=='Gower'){
    meth <- 'gower'
    text <- "Gower"
}else if(metric=='Euclidean'){
    meth <- 'euclidean'
    text <- "Euclidean"
}else if(metric=='Canberra'){
    meth <- 'canberra'
    text <- "Canberra"
}else if(metric=='Kulczynski'){
    meth <- 'kulczynski'
    text <- "Kulczynski"
}else if(metric=='Mountford'){
    meth <- 'mountford'
    text <- "Mountford"
}else{
    meth <- 'horn'
    text <- "Morisita-Horn"
}
main_label=paste("The VAMPS Frequency Heatmap\n--Taxonomic Level:",rank,"\n--Clustering: ",text)
print(x)
drows<-vegdist(x, method=meth)

dcols<-vegdist(t(x), method=meth, na.rm=TRUE)


#
#mypalette1<-colorRampPalette(c("blue", "green", "yellow", "orange", "red"), bias=0.75)(128)
#mypalette2<-colorRampPalette(brewer.pal(12,"Set3"))(128)
#mypalette3<-colorRampPalette(brewer.pal(8,"Dark2"))(128)
#mypalette4<-colorRampPalette(brewer.pal(9,"BuPu"))(128)
#mypalette5<-colorRampPalette(brewer.pal(9,"PuBuGn"))(128)
#mypalette7<-colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan",
#                     "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))(128)
#mypalette8<-colorRampPalette(c("red", "orange", "blue"),space = "Lab")(128)                    
#mypalette9<-colorRampPalette(c("blue", "magenta", "red", "yellow"), bias=0.75, space="Lab")(128)  

mypalette6<-colorRampPalette(brewer.pal(12,"Paired"))(256)

x1<-scale(x, center=FALSE, scale=colSums(x))
# do not use pheatmap to scale
pheatmap(x1,scale="none", color=mypalette6,
			clustering_distance_rows=drows,
			clustering_distance_cols=dcols, margins=c(15,r_margin),
		    fontsize_row=fontsize_row, fontsize_col=fontsize_col,
		    cellwidth=8, cellheight=8, main=main_label
		)

dev.off()

