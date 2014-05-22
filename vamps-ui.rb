#!/usr/bin/env ruby

# vamps-ui.rb
$LOAD_PATH << '.'
require 'project_dataset_accumulator'
require 'mysql2'
require 'config'
# test data
# project--datasets
# units
# normalization
# selected taxonomy

# need mysql connection
begin
  #db = Mysql2.new('localhost', 'ruby', 'ruby', 'vamps_rails')
  sqlclient = Mysql2::Client.new(:host => "localhost", :username => "ruby", :password=>'ruby', :database=>'vamps_rails')
rescue Mysql2::Error
  puts "Oh no! We could not connect to our database."
  exit 1
end


myconfig = MyConfig::INIT
#myconfig['prefix'] = Random.rand(100...999)
timestamp = Time.now.to_i.to_s
myconfig[:timestamp] = timestamp
myconfig[:tax_counts_output_filename]       = timestamp +'_'+ myconfig[:tax_counts_output_filename]         + '.mtx'
myconfig[:dist_output_filename]             = timestamp +'_'+ myconfig[:dist_output_filename]               + '.mtx'
myconfig[:heatmap_counts_output_filename]   = timestamp +'_'+ myconfig[:heatmap_counts_output_filename]     + '.pdf'
myconfig[:heatmap_distance_output_filename] = timestamp +'_'+ myconfig[:heatmap_distance_output_filename]   + '.pdf'
myconfig[:pcoa_output_filename]             = timestamp +'_'+ myconfig[:pcoa_output_filename]               + '.pdf'
myconfig[:dendrogram_plot_output_filename]  = timestamp +'_'+ myconfig[:dendrogram_plot_output_filename]    + '.png'
myconfig[:dendrogram_tree_output_filename]  = timestamp +'_'+ myconfig[:dendrogram_tree_output_filename]    + '.tre'
myconfig[:barchart_output_filename]         = timestamp +'_'+ myconfig[:barchart_output_filename]           + '.pdf'
myconfig[:piechart_output_filename]         = timestamp +'_'+ myconfig[:piechart_output_filename]           + '.pdf'


pd_accumulator = ProjectDatasetAccumulator.new(myconfig, sqlclient)


#pd_accumulator.write_counts_table()

#pd_accumulator.create_distance_matrix()        # depends on counts matrix

#pd_accumulator.create_heatmap('counts')     # depends on counts matrix
#pd_accumulator.create_heatmap('distance')   # depends on distance matrix
#pd_accumulator.create_piechart()            # depends on counts matrix
pd_accumulator.create_dendrogram()            # depends on distance matrix
