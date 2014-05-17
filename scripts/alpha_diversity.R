args <- commandArgs(TRUE)
library(fossil);
library(vegan)
#library(Cairo)
#library(GDD);
source('/usr/local/www/vamps/docs/vamps/common_code/alpha/rarefaction.txt')

d <- args[1];

prefix <- args[2]

# here depth will be zero if you are going to use the total sampling depth
# which is attached to the project(..dataset)name:
# Season_Summer;121200,avone;67421,AB_SAND_Bv6..HS122;8577
depth  <- as.numeric(args[3])
totals <- args[4]
rank <- args[5]

dm<-read.delim(d,header=T,sep="\t",check.names=TRUE,row.names=1);

# totals looks like this: proj1--dset1;total1,proj2--dset2;total2
# ptots:  proj1--dset1;total1
ptots <- unlist(strsplit(totals, ',', fixed = TRUE))
dataset_count<-as.numeric(dim(dm)[2])

#print(d);
# dm has datasets as cols and taxa as rows

#dataset_count<-dim(dm)[2]
pdnames<-colnames(dm, do.NULL = TRUE, prefix = "col")
#print(dm)
taxnames<-rownames(dm, do.NULL = TRUE, prefix = "row")
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


    
for(i in 1:dataset_count){
   
    
    # data frame of one column
    pd<-pdnames[i]
    #df<-dm[[i]]
    #print(length(ptots))
    for(k in 1:length(ptots)){
        #print(pd)
        
        tmp<-unlist(strsplit(ptots[k], ';', fixed = TRUE))
        #print(tmp[1])
        #print(pd)
        if(pd == tmp[1] || pd == paste('X',tmp[1]))
        {
           site_total = as.numeric(tmp[2])
           #print(pd)
        }
    }
    # vector of one column 
    v<-dm[,i]
    # [1]   0   0   0   0   0   0   0   0   0  12   0   0  17 114   0   0   0  49   0
    
    
    # get sub sample vx
    #print(paste("v ",pd))
    #print(v)
    if(max(v)>0){
        if(depth > 0 && depth != site_total){
            samptbl <- apply(t(v), 1, function(x) sample(rownames(dm), depth, prob=x, replace=TRUE) ) 
            sampdf <- as.data.frame(samptbl) 
            sampdf[[1]] <-  factor( sampdf[[1]], levels= rownames(dm) ) 
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
        
        # to sum rows:
        # apply(dm,1,sum) or max
        # to sum rcols:
        # apply(dm,2,sum)
        # http://cc.oulu.fi/~jarioksa/softhelp/vegan/html/radfit.html
        
        
        ace <- ACE(v,taxa.row = TRUE)
        chao <- chao1(v,taxa.row = TRUE)
        shannon <- diversity(v, index = "shannon")
        simpson <- diversity(v, index = "simpson")
        invsimpson <- diversity(v, index = "invsimpson")
        print(cat("dataset=",pd,"\n",sep=" "))
        print(cat("depth=",site_total,"\n",sep=" ")) 
        
        
        print(cat("sub_depth=",samp_depth,"\n",sep=" ")) 
        print(cat("richness=",richness,"\n",sep=" ")) 
        print(cat("ACE=",ace,"\n",sep=" "))    
        print(cat("CHAO=",chao,"\n",sep=" "))
        print(cat("simp=",simpson,"\n",sep=" ")) 
        print(cat("invsimp=",invsimpson,"\n",sep=" "))   
        print(cat("shan=",shannon,"\n",sep=" "))   
        
        rad_filename_png <-paste('/usr/local/www/vamps/docs/tmp/',prefix,pd,'_rad.png',sep='')
        rad_filename_txt <-paste('/usr/local/www/vamps/docs/tmp/',prefix,pd,'_rad.txt',sep='')
        abund_filename_txt <-paste('/usr/local/www/vamps/docs/tmp/',prefix,pd,'_abund.txt',sep='')
        abund_filename_png <-paste('/usr/local/www/vamps/docs/tmp/',prefix,pd,'_abund.png',sep='')
        rare_filename_png <-paste('/usr/local/www/vamps/docs/tmp/',prefix,pd,'_rare.png',sep='')
        
        rad_filename_png_web <-paste('/tmp/',prefix,pd,'_rad.png',sep='')
        rad_filename_txt_web <-paste('/tmp/',prefix,pd,'_rad.txt',sep='')
        abund_filename_txt_web <-paste('/tmp/',prefix,pd,'_abund.txt',sep='')
        abund_filename_png_web <-paste('/tmp/',prefix,pd,'_abund.png',sep='')
        rare_filename_png_web <-paste('/tmp/',prefix,pd,'_rare.png',sep='')
        
        # delete if already present
        unlink(rad_filename_png)
        unlink(rad_filename_txt)
        unlink(abund_filename_txt)
        unlink(abund_filename_png)
        unlink(rare_filename_png)

        ########################################################################
        # SPECIES ABUNDANCE
        # 
        #
        print('abund')
        
        abund<-as.matrix(table(v))          
        
        mx<-as.numeric(rownames(abund)[length(abund)])
        
        write("Taxa Abundance",file=abund_filename_txt, append=TRUE)
        write(paste("Dataset= ",pd),file=abund_filename_txt, append=TRUE)
        write(paste("Taxonomic Rank= ",rank),file=abund_filename_txt, append=TRUE)
        write.table(abund, file=abund_filename_txt, append=TRUE, quote = FALSE, sep="\t", col="Abund.\tCount")
        print(cat("abund_txt=",abund_filename_txt_web,"\n",sep=" "))  
        
        png(file=abund_filename_png, pointsize = 12, width=1600, height=1000,  bg='#F8F8FF')
        
        adder<-1
        if(mx > 100){
          adder<-100
        }
        if(mx > 500){
           adder<-500
        }
        if(mx > 1000){
           adder<-1000
        }
        if(mx > 5000){
           adder<-2000
        }
        if(mx > 10000){
           adder<-3000
        }
        if(mx > 50000){
           adder<-5000
        }
        
        hist(v[v>0], breaks=c(0:mx), ylab="Count", main='', labels = FALSE, xlim=c(0,mx+adder), col="lightgreen", xlab="Taxon Abundance")
        
    
        title(main=paste("Species Abundance Curve\n",pd), font.main= 4)
        print(cat("abund_png=",abund_filename_png_web,"\n",sep=""))  
        dev.off();
        sink();
        
        
        ########################################################################
        # RANK ABUNDANCE
        #
        #
    
        rad<-as.rad(v)
        sorted_by_rank = sort.int(rad, decreasing=TRUE)
        #print(rad)
        #print(sorted_by_rank)
        
        write("Rank Abundance",file=rad_filename_txt, append=TRUE)
        write(paste("Dataset=",pd),file=rad_filename_txt, append=TRUE)
        write(paste("Taxonomic Rank= ",rank),file=rad_filename_txt, append=TRUE)
        write.table(sorted_by_rank, file=rad_filename_txt, append=TRUE, quote = FALSE, sep="\t", col="inc.\tAbund.")
        print('sorted_by_rank')
        print(sorted_by_rank)
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
        
        png(file=rad_filename_png, pointsize = 12, width=1600, height=1000,  bg='#F8F8FF')
        try(barplot(sorted_by_rank, legend = c(paste("Taxonomic Rank:",rank)), width=.84,  horiz=F, col="lightblue", ylim=c(0,ylimr_max), ylab="Abundance", xlab="Rank"),TRUE)
       
        for(t in 1:length(sorted_by_rank)){
            text(t,sorted_by_rank[t]+adder/10, srt = 90, adj=.2, cex=.8, paste(sorted_by_rank[t]))
        }
        title(main=paste("Rank Abundance Graph\n",pd), font.main= 4)
        #print(sort.int(rad, decreasing=TRUE))
        print(cat("rad_png=",rad_filename_png_web,"\n",sep=" "))      
        print(cat("rad_txt=",rad_filename_txt_web,"\n",sep=" ")) 
        dev.off();
        sink();
    }else{  # end max(v)>0
        # should print out some descriptive files here
    }
}


