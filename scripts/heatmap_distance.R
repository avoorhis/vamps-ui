#  filename: heatmap.R
#
#
#

require(vegan,quietly=TRUE);
library(pheatmap) 
library(RColorBrewer)

args <- commandArgs(TRUE)
matrix_file_path<- args[1]
out_file_path   <- args[2]
matrix_type     <- args[3]



data_matrix<-read.delim(matrix_file_path, header=T, sep="\t", check.names=FALSE);

x<-as.matrix(data_matrix)
ncols<-ncol(x)
nrows<-nrow(x)
rownames(x) <- colnames(x)
print(x)




#k=x
#dimnames(k) <- NULL 
#annotation = data.frame(factor(1:ncol(x) %% 2 == 0, labels = c("Even", "Odd")))
#print(data_matrix)
#head(x)
pdf_title="VAMPS Distance Heatmap"

w=10
h=10
#print(h)
#print(w)
pdf(out_file_path, width=w, height=h, title=pdf_title)

#print(paste("fontsize_row:",fontsize_row))

                    

fontsize_row = 8


main_label=paste("The VAMPS Distance Heatmap\n")


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

#x1<-scale(x, center=FALSE, scale=colSums(x))
# do not use pheatmap to scale
#pheatmap(x,scale="none", color=mypalette6,
#			margins=c(15,10),
#		    fontsize_row=fontsize_row, cellwidth=3, cellheight=6, main=main_label
#		)
pheatmap(x, cellwidth=10, cellheight=10,cluster_rows=FALSE, cluster_cols=FALSE, main=main_label)
#heatmap(x, Rowv=NA, Colv="Rowv", margins=c(30,30) )
dev.off()

