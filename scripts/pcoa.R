#!/usr/bin/env Rscript  --slave --no-restore
#
#  filename: pcoa.R
#
#
#
#library(vegan);
library(labdsv)
#library(RColorBrewer)

args                  <- commandArgs(TRUE)
dist_matrix_file_path <- args[1]
out_file_path         <- args[2]
metric                <- args[3]  # just for labeling


label_on_plot<- 'yes'
if(label_on_plot=='yes'){
	labels_on_the_plot<-TRUE
}else{
	labels_on_the_plot<-FALSE
}
unlink(out_file_path)
distance_matrix<-read.delim(dist_matrix_file_path, header=T, sep="\t", check.names=FALSE);

dist <- as.dist(distance_matrix)
axes=list(c(1:2), c(1,3), c(2:3))
axes_labels <- c("12", "13", "23")
pdf(out_file_path,  title="PCoA")

pcoa <- pco(dist, k=3)
print(pcoa$points[,axes[[3]]])
#plot(pcoa, title=paste("PCoA\n",metric))

for (ax in c(1,2,3))
{

    xlabel <- paste("PCOA", substring(axes_labels[ax],1,1), " (", round((pcoa$eig[as.integer(substring(axes_labels[1], 1, 1))]/sum(pcoa$eig[1:3]))*100, 1), "%)", sep="")
    ylabel <- paste("PCOA", substring(axes_labels[ax],2,2), " (", round((pcoa$eig[as.integer(substring(axes_labels[ax], 2, 2))]/sum(pcoa$eig[1:3]))*100, 1), "%)", sep="")
 
    # The main title for each graph, 
    main <- paste("PCoA using ", metric)
    
    plot(pcoa$points[,axes[[ax]]],  main = main, xlab=xlabel, ylab=ylabel)
    
    
}


dev.off()
q()
#======END==========================================
metadata_in<-paste("/usr/local/www/vamps/docs/tmp/",prefix,"_metadata.txt",sep='')
# the QIIME map file doesnt work well: linkerprimersequence, project, dataset, dataset_description

md<-read.delim(metadata_in, header=T,sep="\t",check.names=TRUE,row.names=1);
tmp_matrix <- mtx[rowSums(mtx) > 0,]

ncols<-ncol(mtx)
nrows<-nrow(mtx)


axes=list(c(1:2), c(1,3), c(2:3))
axes_labels <- c("12", "13", "23")




#pcoa2 <- pcoa(d)
#print(pcoa)
# pcoa$points provides the points for all of the samples (matrix columns), and I have conveniently named my matrix columns
# this gives a new matrix with only the 
#print(md)
#print(a_mtx)
for(md_name in colnames(md))
{
    #print(md_name)
}
# write this to a file for download

print(pcoa)
point_file<-paste("/usr/local/www/vamps/docs/tmp/",prefix,"_pcoa_matrix_out.txt",sep='')
cat("pc\n", file = point_file)
write.table(pcoa$points, file = point_file, append = TRUE, quote = FALSE, col.names = FALSE, sep="\t" )

# creating this for make_emperor.py qiime script
cat("\n\neigvals\t", append = TRUE, file = point_file)
eig_vals <- paste(pcoa$eig[1], pcoa$eig[2], pcoa$eig[3], pcoa$eig[4], sep="\t")
cat(eig_vals, append = TRUE, file = point_file)
sum_eigs <- sum(pcoa$eig[1:4])
cat("\n% variation explained\t", append = TRUE, file = point_file)
eig_pcts <- paste((pcoa$eig[1]*100)/sum_eigs, (pcoa$eig[2]*100)/sum_eigs, (pcoa$eig[3]*100)/sum_eigs, (pcoa$eig[4]*100)/sum_eigs, sep="\t")
cat(eig_pcts, append = TRUE, file = point_file)


# this gives the row numbers of datasets that have these
#prows <- grep("2008", rownames(pcoa$points))
#print(prows)
#print(rownames(pcoa$points))
#prows <- grep("P$", rownames(pcoa$points))
#print("xxxxx")
#print(pcoa$points)
#print(md[,"envo_biome"])
#prows <- grep("^estuarine biome$", md[,"envo_biome"])
#print(prows)
#prows <- grep("^marine neritic benthic zone biome$", md[,"envo_biome"])
#print(prows)
num_md_items = length(colnames(md))

# maximum number of colors/divisions on a graph 
# for practical reasons
# so for datasets: anything greater than 6 will show a single color
maxLength=20
colors1 = c( "blue" )
colors2 = c( "blue", "red" )
colors3 = c( "green", "red",  "blue" )
colors4 = c( "green", "red",  "blue", "cyan" )
colors5 = c( "green", "red",  "blue", "cyan","orange")
colors6<-colorRampPalette(c("blue", "green", "cyan", "orange", "red"))(maxLength)
one_color<-c( "blue" )
one_shape<-16
myshapes<-c(16,17,18,19,20,21,22,23,24,25)
#pch = c(21,22,23,24,25)
pdf_file = paste("/usr/local/www/vamps/docs/tmp/",prefix,"_pcoa.pdf",sep='')

h=(num_md_items*5)+2
pdf(pdf_file, width=25, height=h, title='PDF Title')
par(mfrow=c(num_md_items,3))


for(md_name in colnames(md))
{
    #print(md_name)
    #  but you need the list of datasets for each metadata value.
    #  how do i find all the discreet values for this md_name?    
    md_values <- unique(md[,md_name])
    md_val_count<-length(md_values)
    
	if(md_val_count == 1)
	{
		mypalette = colors1  
		pch<-19
		
	}else if(md_val_count == 2)
	{
		mypalette = colors2 
		pch<-c(21,22)
	}else if(md_val_count == 3)
	{
		mypalette = colors3 
		pch<-c(19:21)
	}else if(md_val_count == 4)
	{
		mypalette = colors4 
		pch<-c(19:22)
	}else if(md_val_count == 5)
	{
		mypalette = colors5 
		pch<-c(19:23)
	}else if(md_val_count > 5)
	{
		mypalette = colors6 
		pch<-c(0:81)
	}
	
	
	#print(mypalette)
	for (ax in c(1,2,3))
	{
	
		xlabel <- paste("PCOA", substring(axes_labels[ax],1,1), " (", round((pcoa$eig[as.integer(substring(axes_labels[1], 1, 1))]/sum(pcoa$eig[1:3]))*100, 1), "%)", sep="")
		ylabel <- paste("PCOA", substring(axes_labels[ax],2,2), " (", round((pcoa$eig[as.integer(substring(axes_labels[ax], 2, 2))]/sum(pcoa$eig[1:3]))*100, 1), "%)", sep="")
	 
		# The main title, 
		main <- paste("PCoA using",method_text," ( metadata:", md_name, ")")
		par(xpd=NA, mar = c(5, 4, 4, 18) + 0.1)
		
		#plot(pcoa$points[,axes[[ax]]], main = main, xlab=xlabel, ylab=ylabel)
		plot(pcoa$points[,axes[[ax]]], type="n", main = main, xlab=xlabel, ylab=ylabel)
		#print(md_name)
		ymax=par('usr')[4]
		xmax=par('usr')[2]
		
		
		
		for(i in 1:md_val_count)
		{
			prows <- grep(md_values[i], md[,md_name])
			#print(prows)
			
			if(length(prows)==1)
			{
				# this is needed for single data points; 
				# it turns a vector into the correct matrix
				pts<-t(pcoa$points[prows,axes[[ax]]])
				
			}else{
				pts<-pcoa$points[prows,axes[[ax]]]
			}
			
			
			if(md_val_count > maxLength){
				c=one_color	
				p=one_shape
			}else{
				c=mypalette[i]
				p=myshapes[i]
			}
					
			
			if(labels_on_the_plot){
				cex = 1.2
				text  (pts, labels = rownames(pcoa$points)[prows], adj=c(0.25,-0.5), cex=cex, col=c)
			}else{
				cex = 3			
			}
			points(pts, col=c,  pch=p, cex=cex)	
			
		}
		if(md_val_count > maxLength){
			c=one_color
			p=one_shape
		}else{
			c=mypalette	
			p=myshapes
		}
		legend(x=xmax+0.05, y=ymax, legend=md_values, col=c, title=md_name, pch=p, cex=1.2)
		#legend(x=xmax+0.05, y=ymax, legend=md_values, col=c, fill=c, border='black', title=md_name, pch=myshapes)
        
    }
}
dev.off()

# Sue's code:
# can't remember k exactly, but how many levels to go, and then I am running the 1vs2, then the 1vs3 then the 2 vs 3 axis pairs
# 	k=3
# 	axes=list(c(1:2), c(1,3), c(2:3))
# 	axes_labels <- c("12", "13", "23")
# 
# 	# I am subselecting columns from a larger matrix, which then requires me to remove any rows that are now only zeros
#// 	tmp_matrix <- taxacnts[,metadata$Tissue == "Epithelium" & metadata$Collection == "Brush"]
#// 	tmp_matrix <- tmp_matrix[rowSums(tmp_matrix) > 0,]
#// 
#// 	# I am running for both Morisita-Horn and Jaccard Presence Absence, which of course are in different packages.  You can get rid of the for (j) loop.
#// 	for (j in c("Horn", "Binary"))
#// 	{
#// 		print(j)
#// 		if (j=="Horn")
#// 		{
#// 			d  <- vegdist(t(tmp_matrix), method="horn")
#// 		} else {
#// 			d  <- dist(t(tmp_matrix), method="binary")
#// 		}
#// 		
#// 		# Here is the actual PCoA generation
#// 		pcoa <- pco(d, k=k)
#// 
#// 		# Here is my metadata information.  
#// 		# pcoa$points provides the points for all of the samples (matrix columns), and I have conveniently named my matrix columns
#// 		# to end in H (Healthy) or P (Pouchitis), I am pulling all of the coordinates for each metadata set here
#// 		# I'm not sure what you will do to pull the metadata, but you need the list of datasets for each metadata value.  
#           Here I have only the two values H and P.
#// 		prows <- grep("P$", rownames(pcoa$points))
#// 		hrows <- grep("H$", rownames(pcoa$points))
#// 		
#// 		# going to create three graphs 1vs2, 1vs3 and 2v3, which makes the rest of the code exceedingly ugly!
#// 		for (ax in c(1,2,3))
#// 		{
#// 			# Can't remember why some of these errored out, so I have this to make sure that it doesn't error out
#// 			if (pcoa$eig[axes[[ax]][1]] > 0  & pcoa$eig[axes[[ax]][2]] > 0) 
#// 			{
#// 				# X and Y Axis labels, which includes the axis number (1-3) 
#// 				# and then I round off the eigen values, which tells me what percent of the variation can be ascribed to each axis
#// 				xlabel <- paste("PCOA", substring(axes_labels[ax],1,1), " (", round((pcoa$eig[as.integer(substring(axes_labels[1], 1, 1))]/sum(pcoa$eig[1:3]))*100, 1), "%)", sep="")
#// 				ylabel <- paste("PCOA", substring(axes_labels[ax],2,2), " (", round((pcoa$eig[as.integer(substring(axes_labels[ax], 2, 2))]/sum(pcoa$eig[1:3]))*100, 1), "%)", sep="")
#// 
#// 				# The main title, the first line lists the patients and the second is the usual title stuff include the distance metric used
#// 				main <- paste(patients, collapse=", ")
#// 				main <- paste("PCoA for Epithelium of patients:", main, "using", j)
#// 
#// 				# Plot all the PCoA points with the title and labels
#// 				plot(pcoa$points[,axes[[ax]]], main = main, xlab=xlabel, ylab=ylabel)
#// 				
#// 				# Go back and recolor the points based on the metadata (Pouchitis are in red and Healthy are in blue)
#// 				points(pcoa$points[prows,axes[[ax]]], col="red", bg="red", pch=19)
#// 				points(pcoa$points[hrows,axes[[ax]]], col="blue", bg="blue", pch=8)
#// 
#// 				# Label the points, the substring is removing the end of the label and then getting rid of any trailing _'s. So 202_7_E_P and 202_12_E_P go to 202_7 and 202_11.
#// 				text(pcoa$points[prows,axes[[ax]]], labels = gsub("_$", "", substring(rownames(pcoa$points)[prows], 1,6)), adj=c(0.25,-0.5), cex=0.75, col="red")
#// 				text(pcoa$points[hrows,axes[[ax]]], labels = gsub("_$", "", substring(rownames(pcoa$points)[hrows], 1,6)), adj=c(0.25,-0.5), cex=0.75, col="blue")
#// 			}
#// 		}
#// 	}
#// 



