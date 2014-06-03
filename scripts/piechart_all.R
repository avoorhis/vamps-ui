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




args <- commandArgs(TRUE)

matrix_file_path<- args[1]
out_file_path   <- args[2]
names            <- args[3]  # dataset name (column header)
print(names)
names <- unlist(strsplit(names, split=","))
print(length(names))



#  check.names=TRUE converts '--' to '..' in project--dataset names (also checks for dups)
#  check.names=FALSE: SLM_NIH_Bv4v5--1St_120_Richmond
#  row.names=1  gives the column of the row names

x<-read.table(matrix_file_path, header=T, check.names=FALSE, row.names=1);
#taxnames<-row.names(data_matrix)
w=10
h=10
pdf_title<-paste("VAMPS PieChart\n")
pdf(out_file_path, width=w, height=h, title=pdf_title)
for(i in 1:length(names))
{

    ds<- as.matrix(x[names[i]])
    print(ds)
    
    ds<-ds[which(rowSums(ds) > 0),]
    print(ds)
    #lbls<-paste(names(ds), "\n", ds, sep="")
    
    
    pie(ds, radius=0.2, labels=NA, main=pdf_title)

}


dev.off()