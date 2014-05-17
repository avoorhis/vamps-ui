args <- commandArgs(TRUE)
#print(args)
min <- NULL
max <- NULL
norm_code <- args[1]
prefix <- args[2]
min <- as.integer(args[3] ) 
max <- as.integer(args[4])

if( is.na(min) || min < 0){
   min <- 0
}
if( is.na(max) || max > 100){
   max <- 100
}

matrix_in <- paste("/usr/local/www/vamps/docs/tmp/",prefix,"_data.mtx",sep='')
matrix_out<- paste("/usr/local/www/vamps/docs/tmp/",prefix,"_normalized.mtx",sep='')
#matrix_filtered<- paste("/usr/local/www/vamps/docs/tmp/",prefix,"_filtered_and_normalized_matrix.mtx",sep='')
data_matrix<-read.delim(matrix_in, header=T,sep="\t",check.names=TRUE,row.names=1);

x<-as.matrix(data_matrix)

ncols<-ncol(x)
nrows<-nrow(x)
ORIGINAL_SUMS<-colSums(x)
if(min != 0 || max != 100){
    pcts<-prop.table(x,2)*100
    # create an empty new matrix with the correct number of cols
    newMatrix<-matrix(nrow=0, ncol=ncols)
    
    newNames<-list()
    k=1
    for(i in 1:nrows){  
      print(k)
      if (sum(pcts[i,] > min) & sum(pcts[i,] <= max)){
        print(k)
        #print(rownames(x)[i])
        #print(pcts[i,])
        #print(x[i,])
        newNames[k] <- rownames(x)[i]
        newMatrix<-rbind(newMatrix,x[i,])
        k=k+1
      }
    }
    
    rownames(newMatrix) <- newNames
    x<-newMatrix
}
#colSums(x)
# add original sums to last row and name it
x<-rbind(x,ORIGINAL_SUMS)
rownames(x)[nrow(x)] <- "ORIGINAL_SUMS"
v <- sub('\\.\\.', "--", colnames(x))
# x<-data_matrix
# print(norm_code)
# The value of scale determines how column scaling is performed (after centering). 
# If scale is a numeric vector with length equal to the number of columns of x, 
# then each column of x is divided by the corresponding value from scale. 
# If scale is TRUE then scaling is done by dividing the (centered) columns of x by 
# their standard deviations if center is TRUE, and the root mean square otherwise. 
# If scale is FALSE, no scaling is done.
cat(file=matrix_out, append=FALSE)
if(norm_code == 1){

    # write to file:    
    cat("taxa\t", file=matrix_out, append=TRUE)
    cat(v, file=matrix_out, sep="\t", append=TRUE)
    cat("\n", file=matrix_out, append=TRUE)
    write.table(x, append=TRUE, quote=FALSE, file=matrix_out, na="NA", sep="\t", col.names=FALSE)
    
    # write to console (return matrix to parse):
    cat("taxa\t",append=TRUE)
    cat(v, sep="\t", append=TRUE)
    cat("\n", append=TRUE)
    write.table(x, append=TRUE, quote=FALSE, na="NA", sep="\t", col.names=FALSE)
    
}else if(norm_code == 2){
    # 2) frequency just  divide each elem by it's colSum  
    norm_to_freq_mtx<-scale(x, center=FALSE, scale=colSums(x))  # use colSum(x) not colSum(max_mtx)
    
    # write to file:    
    cat("taxa\t",   file=matrix_out, append=TRUE)
    cat(v,      file=matrix_out, sep="\t", append=TRUE)
    cat("\n",   file=matrix_out, append=TRUE)    
    write.table(norm_to_freq_mtx, append=TRUE, file=matrix_out, quote=FALSE, na="NA", sep="\t", col.names=FALSE)
    
    # write to console (return matrix to parse):
    cat("taxa\t", append=TRUE)
    cat(v,      sep="\t", append=TRUE)
    cat("\n", append=TRUE)
    write.table(norm_to_freq_mtx, append=TRUE, quote=FALSE, na="NA", sep="\t", col.names=FALSE)
    
}else if(norm_code == 3){

    # for normalize to maximum: 
    # 3) find the total of each column then the max
    
    max<-max(colSums(x))
    
    # then scale each element up by this amount and divide each by colSum (using scale())
    # (elem*max)/colsum
    
    max_mtx<-x*max  # will multiply each elem by max
    
    # scale and round to zero places
    # use colSum(x) not colSum(max_mtx)
    norm_to_max_mtx<-round(scale(max_mtx, center=FALSE, scale=colSums(x)), 0) 
    
    # write to file:     
    cat("taxa\t",   file=matrix_out, append=TRUE)
    cat(v,      file=matrix_out, sep="\t", append=TRUE)
    cat("\n",   file=matrix_out, append=TRUE) 
    write.table(norm_to_max_mtx, append=TRUE, file=matrix_out, quote=FALSE, na="NA", sep="\t", col.names=FALSE)
    
    # write to console (return matrix to parse):
    cat("taxa\t", append=TRUE)
    cat(v,      sep="\t", append=TRUE)
    cat("\n", append=TRUE)
    write.table(norm_to_max_mtx, append=TRUE, quote=FALSE, na="NA", sep="\t", col.names=FALSE)

}else{
    print("ERROR")
}



