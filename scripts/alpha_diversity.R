#!/usr/bin/env Rscript  --slave --no-restore
#
#  filename: alpha_diversity.R
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
library(fossil,quietly=TRUE);
library(vegan,quietly=TRUE)

args <- commandArgs(TRUE)
matrix_file_path    <- args[1]
out_txt_file_path   <- args[2]
out_pdf_file_path   <- args[3]
rank                <- args[4]
depth               <- as.numeric(args[5])

unlink(out_txt_file_path)
unlink(out_pdf_file_path)
source('scripts/rarefaction.txt')   

# here depth will be zero if you are going to use the total sampling depth

data_matrix<-read.table(matrix_file_path, header=T, check.names=FALSE, row.names=1);

# get rid of datasets with zero sum over all the taxa:
data_matrix<-data_matrix[,colSums(data_matrix) > 0]

#print(data_matrix)
totals = colSums(data_matrix)
ptots <- as.vector(totals)
#print(ptots)


dataset_count<-ncol(data_matrix)

#print(dataset_count);

# x has datasets as cols and taxa as rows

#dataset_count<-dim(dm)[2]
pdnames<-colnames(data_matrix, do.NULL = TRUE, prefix = "col")
#print(dm)
taxnames<-rownames(data_matrix, do.NULL = TRUE, prefix = "row")
#dm[,1] or dm[[1]] is one dataset of abundance data
#dm[[2]]
#dm[,1]
#as.numeric(dataset_count)
# df has taxa as cols and datasets as rows
#df<-t(dm);


#x <- c(123,0,0,34,3,0,1,4,45)
#tot<-210
#x
# a random permutation
#sample(x, replace=TRUE)
#resample <- function(x, ...) x[sample.int(length(x), ...)]
#resample(x[x >  0])
#resample(x[x >  1]) # length 1
#resample(x[x > 10]) # length 0
#print(dm)
#print(randSub(dm,100))
#print(randSub(dm,100))
#vx<-dm[,2]
#vx
#set.seed(123) 
#offset <- 40
write(file=out_txt_file_path,paste("Alpha Diversity"))


pdf(file=out_pdf_file_path, pointsize = 8, bg='#F8F8FF')    
for(i in 1:dataset_count){
#for(i in 1:2){
   
    
    # data frame of one column
    pd<-pdnames[i]
    #df<-dm[[i]]
    #print(length(ptots))
    
        
       
    site_total = ptots[i]
    #print(paste('site total ',site_total))
       
  
    # vector of one column 
    v<-data_matrix[,i]
    # [1]   0   0   0   0   0   0   0   0   0  12   0   0  17 114   0   0   0  49   0
    #print(v)
    
    # get sub sample vx
    print(paste("v ",pd))
    #print(v)
    if(max(v)>0){
        # loop to re-calculate v according to sampling depth from user input
        if(depth > 0 && depth != site_total){
            samptbl <- apply(t(v), 1, function(x) sample(rownames(data_matrix), depth, prob=x, replace=TRUE) ) 
            sampdf <- as.data.frame(samptbl) 
            sampdf[[1]] <-  factor( sampdf[[1]], levels= rownames(data_matrix) ) 
            vtmp<-sapply(sampdf, table)
            v <- as.vector(vtmp[,1])
            print(v)
        }
        if(depth > 0){
            samp_depth<-depth        
        }else{
            samp_depth<-site_total        
        }
        # gives the number of species
        richness<-sum(v > 0)
        

        # http://cc.oulu.fi/~jarioksa/softhelp/vegan/html/radfit.html
        
        
        ace <- ACE(v,taxa.row = TRUE)
        chao <- chao1(v,taxa.row = TRUE)
        shannon <- diversity(v, index = "shannon")
        simpson <- diversity(v, index = "simpson")
        invsimpson <- diversity(v, index = "invsimpson")
        write(file=out_txt_file_path,"===========================================================", append=TRUE)
        write(file=out_txt_file_path, paste("Dataset ..................",pd,sep=" "), append=TRUE)
        write(file=out_txt_file_path, paste("Taxonomic Rank ...........",rank,sep=" "), append=TRUE)
        write(file=out_txt_file_path, paste("Site Total ...............",site_total,sep=" "), append=TRUE) 
        write(file=out_txt_file_path, paste("Sub-Sampling Depth .......",samp_depth,sep=" "), append=TRUE) 
        if(as.numeric(samp_depth) > as.numeric(site_total)){
            write(file=out_txt_file_path, "<< WARNING: SUB-SAMPLING DEPTH IS GREATER THAN TOTAL COUNT >>", append=TRUE) 
        }
        write(file=out_txt_file_path, paste("Observed Richness ........",richness,sep=" "), append=TRUE) 
        write(file=out_txt_file_path, paste("ACE ......................",ace,sep=" "), append=TRUE)    
        write(file=out_txt_file_path, paste("CHAO .....................",chao,sep=" "), append=TRUE)
        write(file=out_txt_file_path, paste("Simpson ..................",simpson,sep=" "), append=TRUE) 
        write(file=out_txt_file_path, paste("Inverse Simpson ..........",invsimpson,sep=" "), append=TRUE)   
        write(file=out_txt_file_path, paste("Shannon ..................",shannon,sep=" "), append=TRUE)   
        

        ########################################################################
        # SPECIES ABUNDANCE
        # 
        #
        print('sp. abund')
        
        abund<-as.matrix(table(v))          
        
        mx<-as.numeric(rownames(abund)[length(abund)])
        
        write("\nSpecies Abundance:",file=out_txt_file_path, append=TRUE)
        write.table(abund, file=out_txt_file_path, append=TRUE, quote = FALSE, sep="\t", col="Abund.\tCount")
        #print(cat("abund_txt=",abund_filename_txt_web,"\n",sep=" "))  
        
        
        title<-paste("Species Abundance\n",pd,"\nSampling Depth ",samp_depth)
        hist(v[v>0], breaks=c(0:mx), ylab="Number of Occurrences", main=title, col="blue", xlab="Taxon Abundance")



        ########################################################################
        # RANK ABUNDANCE
        #
        #
        print('rk. abund')
        rad<-as.rad(v)
        sorted_by_rank = sort.int(rad, decreasing=TRUE)
        #print(rad)
        #print(sorted_by_rank)
        
        write("\nRank Abundance:",file=out_txt_file_path, append=TRUE)
        
        write.table(sorted_by_rank, file=out_txt_file_path, append=TRUE, quote = FALSE, sep="\t", col="Rank\tAbund.")
        #print('sorted_by_rank')
        #print(sorted_by_rank)
        adder<-1
        if(sorted_by_rank[1] > 100){
          adder<-100
        }
        if(sorted_by_rank[1] > 1000){
           adder<-500
        }
        if(sorted_by_rank[1] > 5000){
           adder<-1000
        }
        if(sorted_by_rank[1] > 10000){
           adder<-1000
        }
        if(sorted_by_rank[1] > 50000){
           adder<-5000
        }
        
        ylimr_max<-as.integer(sorted_by_rank[1] + adder)
        
        #png(file=rad_filename_png, pointsize = 12, width=1600, height=1000,  bg='#F8F8FF')
        try(barplot(sorted_by_rank, legend = c(paste("Taxonomic Rank:",rank)), width=.84,  horiz=F, col="lightblue", ylim=c(0,ylimr_max), ylab="Abundance", xlab="Rank"),TRUE)
       
        for(t in 1:length(sorted_by_rank)){
            text(t,sorted_by_rank[t]+adder/10, srt = 90, adj=.2, cex=.8, paste(sorted_by_rank[t]))
        }
        title(main=paste("Rank Abundance\n",pd,"\nSampling Depth ",samp_depth), font.main= 4)
        
    }    
    
}

########################################################################
# RAREFACTION
# Single plot with all datasets shown
#  
print('rare')
if(depth > 0){
    # a scalar
    samp_depth<-depth        
    this_step <- as.integer(( samp_depth / 100 ))
}else{
    # a vector
    samp_depth<-ptots 
    #print(samp_depth)
    this_step <- as.integer(( max(samp_depth) / 100 ))
}

#print(data_matrix)
#print(rownames(data_matrix))
#print(samp_depth)
samptbl <- apply(t(data_matrix), 1, function(x) sample(rownames(data_matrix), samp_depth, prob=x, replace=TRUE) ) 

sampdf <- as.data.frame(samptbl) 
for(i in 1:dataset_count){
    sampdf[[i]] <-  factor( sampdf[[i]], levels= rownames(data_matrix) )
}

vtmp<-sapply(sampdf, table)
#print(vtmp) 

# uses function above

rare<-rarefaction(t(vtmp), 
                    subsample=this_step, 
                    plot=TRUE, 
                    color=TRUE, 
                    error=TRUE,  
                    legend=TRUE
                    )

write(file=out_txt_file_path, "\n===RAREFACTION=============================================", append=TRUE)  
write(file=out_txt_file_path, "Richness:", append=TRUE)  
write.table(rare$richness, file=out_txt_file_path, append=TRUE)
write(file=out_txt_file_path, "\nStandard Error:", append=TRUE)  
write.table(rare$SE, file=out_txt_file_path, append=TRUE)
#write.table(rare$subsample, file=out_txt_file_path, append=TRUE)
write(file=out_txt_file_path, "===END=====================================================", append=TRUE)   
dev.off();


q()