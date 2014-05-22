
require 'pathname'
require 'constants'
require 'sample'
require 'scripts'


class OTU

end
class MEDNode

end
class Hash
  def self.recursive
    new { |hash, key| hash[key] = recursive }
  end
end

class ProjectDatasetAccumulator

	@dataset_ids_order = []
	@seq_ids_list = []
	@dataset_names_by_id
	@datasets_by_project_selected
	@counts_sum_per_dataset_id
	@seq_ids_per_dataset_id 
	@counts_per_taxon = {}
	# FOR EACH DATASET:
	# @universal_id_hash = { 
	#   dsid1: {
	#       seq_ids: [seqid1,seqid2,seqid3,seqid4,..., seqidN],
	#       unit_accessor: {
	#           MED:       [nodeid1,nodeid2,nodeid3,nodeid4,...,nodeidN],
	#           tax_gg:    [taxid1,taxid2,taxid3,taxid4,...,taxidN],
	#           tax_silva: [taxid1,taxid2,taxid3,taxid4,...,taxidN],
	#           OTU:       [otuid1,otuid2,otuid3,otuid4,...,otuidN]
	#  }}}
	# there shoud be a one-to-one relation between seqid1-nodeid1-taxid1-otuid1
	# since there are fewer otus than seqs => could use place holders?
	
#================================================================================================#    
	def initialize(myconfig, sql_client)
	    @myconfig = myconfig
	    @verbose = @myconfig[:verbose]
	    @normalization = @myconfig[:normalization]  # if not found will default to 'none'
	    if @verbose
	        puts "\nInitialization Object:\n"+ @myconfig.inspect
	    end
	    @myscripts = Scripts.new()
	    @sql_client = sql_client
		  @units = @myconfig[:units]
		
		  dataset_ids = @myconfig[:ids].flatten.collect { |i| i.to_i } # change string to int
		  @dataset_names_by_id, @datasets_by_project_selected = make_datasets_by_project_hash(dataset_ids)
		  @dataset_ids_order = validate_and_clean_ds_id_list(dataset_ids) # removes ids that are not in db
		  @samples = []
		  @dataset_ids_order.each do |id|
		     @samples << Sample.new(id)
		  end
		  if @units == 'taxonomy' || @units == 'tax_silva108'
  		    @nas  = @myconfig[:nas]
  		    @taxa = @myconfig[:taxa]
  		    @rank = @myconfig[:rank]
  		    @sort = @myconfig[:sort]
  		    pdr_result = get_seq_tax_counts_sql_result()
  		    
  		    @counts_sum_per_dataset_id, @max_dscnt = make_sum_counts_per_dataset_id(pdr_result)
  		    @seq_ids_per_dataset_id = make_seq_ids_per_dataset_id(pdr_result)
  		    
  		    # normalization (if asked for) is done next
  		    counts_per_taxon_no_zeros = make_taxon_strings_w_counts_per_dataset_id(pdr_result)
  		    @counts_per_taxon = fill_zeros_and_set_ds_order(counts_per_taxon_no_zeros)
  		    
  		    @counts_per_dataset_id, @tax_in_order = get_counts_per_dataset_id()
  		    #@R_tax_matrix_string = create_tax_matrix_string()  # this is a text matrix
  		    #R_testing()    

   
  		end
		

	end
	
	def R_testing

	end
	
#================================================================================================#
	def add_ids(ids)
		# can be list or single
		if ids.kind_of?(Array)
			@dataset_ids_order += ids
		else
			@dataset_ids_order.push(ids)
		end
	end
#================================================================================================#
	def showList
		puts 'SHOW ID LIST '+@dataset_ids_order.to_s
	end
#================================================================================================#
	def getList
		return @dataset_ids_order

	end
#================================================================================================#
	def create_heatmap(matrix_type)
	
	    if matrix_type == 'counts'
	        counts_table_path   = @myconfig[:files_dir]+@myconfig[:tax_counts_output_filename]
	        heatmap_table_path  = @myconfig[:files_dir]+@myconfig[:heatmap_counts_output_filename]
	        if !File.exist?(counts_table_path)
              write_counts_table()
            end
            puts 'RUN COUNTS HEATMAP SCRIPT'
            args = [
              counts_table_path,    # infile
              heatmap_table_path,   # outfile
              matrix_type,
              @myconfig[:dmetric],  # distance metric
              @rank                 # rank
            ]
	        outfile = @myscripts.run(:heatmap_counts, args)
	        
	    elsif matrix_type == 'distance'
	        distance_table_path = @myconfig[:files_dir]+@myconfig[:dist_output_filename]
	        heatmap_table_path  = @myconfig[:files_dir]+@myconfig[:heatmap_distance_output_filename]
	        if !File.exist?(distance_table_path)
                create_distance_matrix()
            end
            puts 'RUN DISTANCE HEATMAP SCRIPT'
            args = [
              distance_table_path,    # infile
              heatmap_table_path,   # outfile
              matrix_type              
            ]
            outfile = @myscripts.run(:heatmap_distance, args)
            
	    end

	end
#================================================================================================#
	def create_distance_matrix()
	    # distance relies on counts table so we need to check for it
	    counts_table_path   = @myconfig[:files_dir]+@myconfig[:tax_counts_output_filename]
	    distance_table_path = @myconfig[:files_dir]+@myconfig[:dist_output_filename]
	    if !File.exist?(counts_table_path)
	      write_counts_table()
        end
	    puts 'RUN DISTANCE SCRIPT'
	    args = [
	      counts_table_path,    # infile
	      distance_table_path,  # outfile
	      @myconfig[:dmetric]  # distance metric
	    ]
	    outfile = @myscripts.run(:distance, args)
	    
	end

#================================================================================================#	
	def write_counts_table()
	    filename    = @myconfig[:files_dir]+@myconfig[:tax_counts_output_filename]
	  
	    puts "\nStarting to write counts output file: "+filename
		# units can be tax_silva, tax_rdp, tax_gg, otus, nodes, ...
		# 		ds1 ds2 ds3
		# unit1   1   0   9
		# unit2   4   4   0
		# unit3   3   7   1
		# unit4   0   0   1
		txt = "UNITS"
		@dataset_ids_order.each do |id|
		    txt += "\t" + @dataset_names_by_id[id]
		end
		txt += "\r\n"
		
	    @counts_per_taxon.sort.each do |tax, data|
	        txt += tax
	        data.each do |d|
	            cnt = d[:count].to_s
	            if @normalization == 'percent'
	                cnt = "%.5f" % [cnt] 
	            end
	            txt += "\t"+ cnt
	        end
	        txt += "\r\n"
	        #txt = txt.sub!(/\t$/, "\r\n") 
	    end
#	    txt += "TOTALS"
	    @dataset_ids_order.each do |id|
#	        txt += "\t"+@counts_sum_per_dataset_id[id].to_s
	    end
        txt += "\r\n"
        File.open(filename, 'w') { |file| file.write(txt) }
        puts "Done writing counts output file\n\n"
	end
#================================================================================================#
	def create_piechart
        counts_table_path   = @myconfig[:files_dir]+@myconfig[:tax_counts_output_filename]
        piechart_path       = @myconfig[:files_dir]+@myconfig[:piechart_output_filename]
        if !File.exist?(counts_table_path)
	        write_counts_table()
        end
        puts 'RUN PIECHART SCRIPT'
        dataset_id_hash = Hash[@dataset_ids_order.map.with_index.to_a]    # => {id1=>0, id2=>1, id3=>2}
        dsid = 4
	    args = [
	      counts_table_path,        # infile
	      piechart_path,            # outfile
	      @dataset_names_by_id[dsid]# name (column)
	    ]
	    outfile = @myscripts.run(:piechart, args)
        
	end
#================================================================================================#
	def make_barcharts

	end
#================================================================================================#
	def alpha_diversity

	end
#================================================================================================#
	def create_dendrogram
        distance_table_path = @myconfig[:files_dir]+@myconfig[:dist_output_filename]
        dendrogram_plot_path     = @myconfig[:files_dir]+@myconfig[:dendrogram_plot_output_filename]
        dendrogram_tree_path     = @myconfig[:files_dir]+@myconfig[:dendrogram_tree_output_filename]
        if !File.exist?(distance_table_path)
	        create_distance_matrix()
        end
        puts 'RUN DENDROGRAM SCRIPT'
	    args = [
	      distance_table_path,      # infile
	      dendrogram_plot_path,     # outfile tree
	      dendrogram_tree_path,     # outfile tree
	      @myconfig[:dmetric],      # distance metric
	      @myconfig[:method]        # method:       # UPGMA, Average  Kistch, Fitch
	    ]
	    outfile = @myscripts.run(:dendrogram, args)
	end

#================================================================================================#	
	def reorder_datasets
	
	end
#================================================================================================#	
private
#================================================================================================#
    def make_datasets_by_project_hash(dataset_ids)
        # dataset_ids not validated yet
        query = " SELECT project, dataset, datasets.id as id\n" 
        query += " FROM datasets\n"  
        query += " JOIN projects ON project_id=projects.id\n" 
        query += " WHERE datasets.id IN (#{dataset_ids.join(',')})" 
        puts "\nPROJECT--DATASET QUERY=>\n"+query+"\n\n"
        results = @sql_client.query(query)
        datasets_by_project = {}
        dataset_names_by_id = {}
        
        results.each do |row|
            p = row['project']
            d = row['dataset']
            pd = p+'--'+d
            id = row['id']
            dataset_names_by_id[id] = pd
            
            if datasets_by_project.has_key?(p)
                datasets_by_project[p] << {dataset: d, id: id}
            else
                datasets_by_project[p] = [{dataset: d, id: id}]
            end
            
        end
        return dataset_names_by_id, datasets_by_project
    end
#================================================================================================#    
    def get_choosen_projects_w_d()
    
    end
#================================================================================================#    
    def get_choosen_projects()
    
    end
#================================================================================================#    
    def get_seq_tax_counts_sql_result
        
        select_items = "dataset_id,sequence_id,#{@units}_id,seq_count"
        tax_tables = "\n"
        if @rank == 'domain'
            select_items += ',domain'
            tax_tables   += " JOIN domains ON (domain_id=domains.id)\n"
        elsif @rank == 'phylum'
            select_items += ',domain,phylum'
            tax_tables   += " JOIN domains ON (domain_id=domains.id)\n"
            tax_tables   += " JOIN phylums ON (phylum_id=phylums.id)\n"
        elsif @rank == 'class'
            select_items += ',domain,phylum,klass'
            tax_tables   += " JOIN domains ON (domain_id=domains.id)\n"
            tax_tables   += " JOIN phylums ON (phylum_id=phylums.id)\n"
            tax_tables   += " JOIN klasses ON (klass_id=klasses.id)\n"
        elsif @rank == 'order'
            select_items += ',domain,phylum,klass,orderx'
            tax_tables   += " JOIN domains ON (domain_id=domains.id)\n"
            tax_tables   += " JOIN phylums ON (phylum_id=phylums.id)\n"
            tax_tables   += " JOIN klasses ON (klass_id=klasses.id)\n"
            tax_tables   += " JOIN orders ON (order_id=orders.id)\n"
        elsif @rank == 'family'
            select_items += ',domain,phylum,klass,orderx,family'
            tax_tables   += " JOIN domains ON (domain_id=domains.id)\n"
            tax_tables   += " JOIN phylums ON (phylum_id=phylums.id)\n"
            tax_tables   += " JOIN klasses ON (klass_id=klasses.id)\n"
            tax_tables   += " JOIN orders ON (order_id=orders.id)\n"
            tax_tables   += " JOIN families ON (family_id=families.id)\n"
        elsif @rank == 'genus'
            select_items += ',domain,phylum,klass,orderx,family,genus'
            tax_tables   += " JOIN domains ON (domain_id=domains.id)\n"
            tax_tables   += " JOIN phylums ON (phylum_id=phylums.id)\n"
            tax_tables   += " JOIN klasses ON (klass_id=klasses.id)\n"
            tax_tables   += " JOIN orders ON (order_id=orders.id)\n"
            tax_tables   += " JOIN families ON (family_id=families.id)\n"
            tax_tables   += " JOIN genera ON (genus_id=genera.id)\n"
        elsif @rank == 'species'
            
            select_items += ',domain,phylum,klass,orderx,family,genus,species'
            tax_tables   += " JOIN domains ON (domain_id=domains.id)\n"
            tax_tables   += " JOIN phylums ON (phylum_id=phylums.id)\n"
            tax_tables   += " JOIN klasses ON (klass_id=klasses.id)\n"
            tax_tables   += " JOIN orders ON (order_id=orders.id)\n"
            tax_tables   += " JOIN families ON (family_id=families.id)\n"
            tax_tables   += " JOIN genera ON (genus_id=genera.id)\n"
            tax_tables   += " JOIN species ON (species_id=species.id)\n"
            puts tax_tables
        else
            # ERROR
        end
        
        query = " SELECT #{select_items}\n" 
        query += " FROM sequence_pdr_infos\n"
        query += " JOIN sequence_uniq_infos USING (sequence_id)\n"
        query += " JOIN taxonomies ON (#{@units}_id=taxonomies.id)"
        query += " #{tax_tables}"
        query += " WHERE dataset_id IN (#{@dataset_ids_order.join(',')})\n"
        puts "\nPDR QUERY=>\n"+query+"\n"
        my_pdrs = @sql_client.query(query)
        return my_pdrs
    end
#================================================================================================#    
    def make_sum_counts_per_dataset_id(my_pdrs)
        
        sum_counts_per_dataset_id  = {}
        my_pdrs.each do |row|
            cnt = row['seq_count']
            id  = row['dataset_id']
            if sum_counts_per_dataset_id.has_key?(id)
                sum_counts_per_dataset_id[id] += cnt
            else
                sum_counts_per_dataset_id[id] = cnt
            end
        end
        max_ds = sum_counts_per_dataset_id.max_by{|k,v| v}
        puts max_ds.inspect  # [id, max_cnt]
        # fill zeros
        @dataset_ids_order.each do |id|
            unless sum_counts_per_dataset_id.has_key?(id)
                sum_counts_per_dataset_id[id] = 0
            end
        end
        puts "\ndone creating: sum_counts_per_dataset_id"
        if @verbose
            puts sum_counts_per_dataset_id.inspect
        end
        return sum_counts_per_dataset_id, max_ds       
    end
#================================================================================================#    
    def make_taxon_strings_w_counts_per_dataset_id(my_pdrs)        
        
        
        counts_per_taxon_no_zeros  = {}
        if @verbose && @normalization.nil?
            puts "\nNo Normalization Found -- Using Raw Counts!"
        end
        my_pdrs.each do |row|
            cnt = row['seq_count']
            id  = row['dataset_id']
            if @rank == 'domain'
                taxon = row['domain']
            elsif @rank == 'phylum'
                taxon = row['domain']+';'+row['phylum']
            elsif @rank == 'class'
                taxon = row['domain']+';'+row['phylum']+';'+row['klass']
            elsif @rank == 'order'
                taxon = row['domain']+';'+row['phylum']+';'+row['klass']+';'+row['orderx']
            elsif @rank == 'family'
                taxon = row['domain']+';'+row['phylum']+';'+row['klass']+';'+row['orderx']+';'+row['family']
            elsif @rank == 'genus'
                taxon = row['domain']+';'+row['phylum']+';'+row['klass']+';'+row['orderx']+';'+row['family']+';'+row['genus']
            elsif @rank == 'species'
                taxon = row['domain']+';'+row['phylum']+';'+row['klass']+';'+row['orderx']+';'+row['family']+';'+row['genus']+';'+row['species']
            else
                # ERROR
                taxon =''
            end
            
            if @normalization == 'maximum'
                cnt = (cnt * @max_dscnt[1]) / @counts_sum_per_dataset_id[id]
            elsif @normalization == 'percent'
                puts 'c1 '+cnt.to_s
                puts '-- '+@counts_sum_per_dataset_id[id].to_s
                cnt = (cnt.to_f / @counts_sum_per_dataset_id[id])*100
                puts 'c2 '+cnt.to_s
            end
            
            if counts_per_taxon_no_zeros.has_key?(taxon)
                if h = counts_per_taxon_no_zeros[taxon].find{ |h| h[:dataset_id] == id}
                    h[:count] += cnt
                else
                    counts_per_taxon_no_zeros[taxon] << {dataset_id: id, count: cnt }
                end
                
                #counts_per_taxon[id] += cnt
            else
                
                counts_per_taxon_no_zeros[taxon] = [{dataset_id: id, count: cnt}]
            end
        end
        
        # now update sum counts if normailzed
        
        if @normalization == 'maximum'
                temp_sum_counts = {}
                @counts_sum_per_dataset_id.each do |id,c|
                	temp_sum_counts[id] = @max_dscnt[1]
                end
                @counts_sum_per_dataset_id = temp_sum_counts
            elsif @normalization == 'percent'
                temp_sum_counts = {}
                @counts_sum_per_dataset_id.each do |id,c|
                	temp_sum_counts[id] = 100
                end
                @counts_sum_per_dataset_id = temp_sum_counts
            end
        puts "\ndone creating: counts_per_taxon_no_zeros"
        if @verbose
            puts counts_per_taxon_no_zeros.inspect
        end
        return  counts_per_taxon_no_zeros
                
    end
#================================================================================================#    
    def make_seq_ids_per_dataset_id(my_pdrs)
    
        seq_ids_per_dataset_id = {}
        my_pdrs.each do |row|
            seq_id = row['sequence_id']
            ds_id  = row['dataset_id']
            if seq_ids_per_dataset_id.has_key?(ds_id)
                seq_ids_per_dataset_id[ds_id] << seq_id
            else
                seq_ids_per_dataset_id[ds_id] = [seq_id]
            end
        end
        puts "\ndone creating: seq_ids_per_dataset_id"
        if @verbose
            puts seq_ids_per_dataset_id.inspect
        end
        return seq_ids_per_dataset_id        
    end
#================================================================================================#
    
    def fill_zeros_and_set_ds_order(counts_per_taxon_no_zeros)
        counts_per_taxon_w_zeros = {}
        counts_per_taxon_no_zeros.each do |tax, data_array|
            counts_per_taxon_w_zeros[tax]=[]
            # maintain dataset order
            @dataset_ids_order.each do |id|
                if h = data_array.find{ |h| h[:dataset_id] == id}
                    counts_per_taxon_w_zeros[tax] << {dataset_id: id, count: h[:count]}
                else
                    counts_per_taxon_w_zeros[tax] << {dataset_id: id, count: 0}
                end
	        end
        end
        puts "\ndone creating: counts_per_taxon"
        if @verbose
            puts counts_per_taxon_w_zeros.inspect
        end
        return counts_per_taxon_w_zeros
    end
#================================================================================================#
    def validate_and_clean_ds_id_list(id_list)
        # if id is NOT in dataset_names_by_id hash then it will be removed from id_list
        # retains order
        # uniques list
        new_dataset_id_list = []
        id_list.each do |id|
            if @dataset_names_by_id.has_key?(id)
                new_dataset_id_list << id
            end
        end
        puts "\ndone cleaning,uniqueing (validating) new_dataset_id_list"
        if @verbose
            puts new_dataset_id_list.uniq.inspect
        end
        return new_dataset_id_list.uniq
    end
#================================================================================================# 
    def get_counts_per_dataset_id()
        puts "\nCreating counts per dataset_id"
        counts_per_dataset_id = {}
        tax_in_order = []
        @counts_per_taxon.each do |tax,value|
            tax_in_order << tax
            value.each do |p|
                if counts_per_dataset_id.key?(p[:dataset_id])
                    counts_per_dataset_id[p[:dataset_id]] << p[:count]
                else
                    counts_per_dataset_id[p[:dataset_id]] = [p[:count]]
                end
            end
        end
        
        puts "Done creating counts per dataset_id:"
        if @verbose
            puts counts_per_dataset_id.inspect
        end
        return counts_per_dataset_id,tax_in_order
    end
#================================================================================================#     
    def create_tax_matrix_string()  
        puts "\nCreating tax matrix string"
        # This is a 'text' matrix
        # there is also a ruby command 'Matrix'
		# units can be tax_silva, tax_rdp, tax_gg, otus, nodes, ...
		# 		ds1 ds2 ds3
		# unit1   1   0   9
		# unit2   4   4   0
		# unit3   3   7   1
		# unit4   0   0   1
		txt = "taxa"
		@dataset_ids_order.each do |id|
		    txt += "\t" + @dataset_names_by_id[id]+'('+id.to_s+')'
		end
		txt += "\n"
	    @counts_per_taxon.sort.each do |tax, data|
	        txt += tax+"\t"
	        data.each do |d|
	            txt += "\t"+d[:count].to_s
	        end
	        txt += "\n"
	    end
	    
        puts "Done creating tax matrix string:\n"
        if @verbose
            puts txt+"\n"
        end
        return txt
    end
#================================================================================================#       
    def get_R_distance(metric)
        
        rows = @dataset_ids_order.length
		cols = @counts_per_taxon.length
		puts 'Rows: '+rows.to_s+' Cols: '+cols.to_s
        
		all_counts = []
		@counts_per_dataset_id.each do |id,list|
		        # accumulate the data
		        all_counts += list
		end
		all_counts = all_counts.join(',')
		taxnames = @tax_in_order.join("','")
		dsidnames = @dataset_ids_order.join("','")
		
        R.eval <<-EOF
            mtx <- matrix(data=c(#{all_counts}), ncol=#{cols}, byrow = TRUE)
            #print(mtx)
            metric = '#{metric}'
            colnames(mtx) <- c('#{taxnames}')
            rownames(mtx) <- c('#{dsidnames}')
            # get rid of datasets with no counts over all taxa:
            #    mtx<-mtx[,rowSums(mtx) > 0]
            #print(mtx)
            colsums <- colSums(mtx)
            #print(colsums)
            require(vegan,quietly=TRUE)
            stand <-decostand(data.matrix(mtx),"total");
            if(metric == "horn" ){                
                dis<-vegdist(stand, method="horn",upper=FALSE, binary=FALSE);
            }else if(metric == "yue_clayton"){
                dis<-designdist(stand, method="1-(J/(A+B-J))",terms = c( "quadratic"), abcd = FALSE)
            }else if(metric == "bray"){
               dis<-vegdist(stand, method="bray",upper=FALSE,binary=FALSE);
            }else if(metric == "jaccard"){               
               dis<-vegdist(stand, method="jaccard",upper=FALSE,binary=TRUE); 
            }else if(metric == "manhattan"){
               dis<-vegdist(stand, method="manhattan",upper=FALSE,binary=FALSE);
            }else if(metric == "raup"){
               dis<-vegdist(stand, method="raup",upper=FALSE,binary=FALSE);
            }else if(metric == "gower"){
                dis<-vegdist(stand, method="gower",upper=FALSE,binary=FALSE);
            }else if(metric == "euclidean"){
                dis<-vegdist(stand, method="euclidean",upper=FALSE,binary=FALSE);
            }else if(metric == "canberra"){ 
                dis<-vegdist(stand, method="canberra",upper=FALSE,binary=FALSE);
            }else if(metric == "kulczynski"){
                dis<-vegdist(stand, method="canberra",upper=FALSE,binary=FALSE);
            }
            
            
            
        EOF
        dist = R.pull "as.matrix(dis)"
        return dist
    end
end