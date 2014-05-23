#  filename: piechart_all.R
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

library(ggplot2)
library(plyr)
library(reshape2)
library(RColorBrewer)
library(digest)
args <- commandArgs(TRUE)

matrix_file_path<- args[1]
out_file_path   <- args[2]
rank            <- args[3]
#names            <- args[3]  # dataset name (column header)
#print(names)
#names <- unlist(strsplit(names, split=","))
#print(length(names))



# check.names=TRUE converts '--' to '..' in project--dataset names (also checks for dups)
# check.names=FALSE: SLM_NIH_Bv4v5--1St_120_Richmond
# row.names=1  gives the column of the row names
w=10
h=10

pdf(out_file_path, width=w, height=h, title="bars")
x<-read.table(matrix_file_path, header=T, check.names=FALSE, row.names=1);
#x <- data.frame(t(x)) 
#x <- data.frame(x) 
print(x)

# get rid of ds with all zeros
#x<-x[,colSums(x) > 0]

colourCount = nrow(x)

#print(colSums(x))
#max<-max(colSums(x))
max_df<-x*100  # will multiply each elem by 100 to normalize

x<-data.frame(scale(max_df, center=FALSE, scale=colSums(x) != 0)) 

print(x)
#print(colSums(x))
#print(colnames(x))
taxnames = rownames(x)
#print(taxnames)
hexcolors = c()
for(i in 1:length(taxnames))
{
    #print(taxnames[i])
    #b = sprintf("%d", strtoi(taxnames[i]))
    b = digest(taxnames[i], algo=c("crc32"), ascii=TRUE)
    b = sprintf("#%.6s", b)
    #print(b)
    hexcolors<-append(hexcolors,b)
}
#print(hexcolors)


#print(x$Bacteria.Bacteroidetes.Bacteroidia.Bacteroidales.Bacteroidaceae.Bacteroides)
#summary(x)

data.wide <- melt(t(x))
#print(data.wide)
# Var1 == Site
# Var2 = Tax
#cols<- c("Tax1"="darkgrey","Tax2"="lightgrey", "Tax3"="white", "Tax5"="black","Tax6"="lightblue")
#getPalette = colorRampPalette(brewer.pal(6, "Set1"))

ggplot(data=data.wide, aes(x=Var1, y=value, fill=Var2)) + geom_bar(stat='identity', position = "fill") +
        scale_fill_manual(values=hexcolors, guide = guide_legend(title = 'Taxa',keyheight = .5)) +
        labs(x="Site", y="Taxonomy",title=paste("Taxonomy Distribution\n(Rank: ",rank,")",sep="")) +
        theme(text = element_text(size=7), axis.text.x = element_text(angle = 90, vjust=1), plot.title = element_text(lineheight=.8, face="bold"))


dev.off()
q()


#taxnames<-row.names(data_matrix)

pdf_title<-paste("VAMPS PieChart\n")

for(i in 1:length(names))
{

    ds<- as.matrix(x[names[i]])
    print(ds)
    
    ds<-ds[which(rowSums(ds) > 0),]
    print(ds)
    #lbls<-paste(names(ds), "\n", ds, sep="")
    
    
   
    
    
    pie(ds, radius=0.5, main=pdf_title)

}


