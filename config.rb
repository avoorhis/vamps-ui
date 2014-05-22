
module MyConfig
    #DATASET_ID_ORDER = ["153",255,"3", "4",-1,'AA','"', "5", "6", "7", "93", "94", "95", "96", "97", "98", "99", "101", "101"]
    DATASET_ID_ORDER = [   "4",-1,'AA','"', "5", "6", "7", "94", "95", "96", "97",]
    DENDROGRAM_METHODS = ['average','UPGMA', 'Kitsch','Fitch', 'Neighbor Joining', 'Weighbor Joining']
    RANKS = ['domain','phylum','class','order','family','genus','species']
    DIST_METRICS = [
      'Morisita-Horn', 
      'Yue-Clayton',
      'Bray-Curtis',
      'Jaccard',
      'Manhattan',
      'Gower',
      'Raup',
      'Euclidean', 
      'Canberra',
      'Kulczynski']
      
      
       INIT = { 
          ids:   DATASET_ID_ORDER,
    #        @@units: 'tax_silva108',  # must be the name of the field in sequence_uniq_infos
		  units: 'taxonomy',
		  rank: RANKS[5],
		  taxa:  'bacteria',
		  nas: true,
		  sort:  true,
		  verbose: true,
		  normalization: 'none',    # 'none', 'maximum' or 'percent'
		  dmetric: DIST_METRICS[0],
		  method: DENDROGRAM_METHODS[1],
		  files_dir: './files/',
		  tax_counts_output_filename: 'tax_counts',
		  dist_output_filename: 'distance',
		  heatmap_counts_output_filename: 'heatmap_clustered_counts',
		  heatmap_distance_output_filename: 'heatmap_sample_distance',
		  pcoa_output_filename: 'pcoa',
		  dendrogram_plot_output_filename: 'dendrogram_plot',
		  dendrogram_tree_output_filename: 'dendrogram_tree',
		  barchart_output_filename: 'barchart',
		  piechart_output_filename: 'piechart'
      
      
    }
      
end


