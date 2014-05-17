module R_distance

    def R_distance.get_dist_matrix(metric)
        
        taxnames = @@tax_in_order.join("','")
		dsidnames = @@dataset_ids_order.join("','")
		@@counts_per_dataset_id.each do |id,list|
		        # accumulate the data
		        all_counts += list
		end
        RR.eval <<-EOF
            mtx <- matrix(data=c(#{all_counts}), ncol=#{cols}, byrow = TRUE)
            #print(mtx)
            colnames(mtx) <- c('#{taxnames}')
            rownames(mtx) <- c('#{dsidnames}')
        # get rid of datasets with no counts over all taxa:
        #    mtx<-mtx[,rowSums(mtx) > 0]
            #print(mtx)
            colsums <- colSums(mtx)
            #print(colsums)
            require(vegan,quietly=TRUE)
            stand <-decostand(data.matrix(mtx),"total")
            dist<-vegdist(stand, method="horn", upper=FALSE)
            #print(dist)
            
        EOF
        dist = RR.pull "as.matrix(dist)"
        return dist
    end

end