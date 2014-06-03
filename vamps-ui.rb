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
myconfig[:counts_filename]              = timestamp +'_'+ myconfig[:counts_filename]             + '.mtx'
myconfig[:distance_filename]            = timestamp +'_'+ myconfig[:distance_filename]           + '.mtx'
myconfig[:heatmap_counts_filename]      = timestamp +'_'+ myconfig[:heatmap_counts_filename]     + '.pdf'
myconfig[:heatmap_distance_filename]    = timestamp +'_'+ myconfig[:heatmap_distance_filename]   + '.pdf'
myconfig[:heatmap_distance_html_filename] = timestamp +'_'+ myconfig[:heatmap_distance_html_filename]   + '.html'
myconfig[:pcoa_output_filename]         = timestamp +'_'+ myconfig[:pcoa_filename]               + '.pdf'
myconfig[:dendrogram_plot_filename]     = timestamp +'_'+ myconfig[:dendrogram_plot_filename]    + '.png'
myconfig[:dendrogram_tree_filename]     = timestamp +'_'+ myconfig[:dendrogram_tree_filename]    + '.tre'
myconfig[:barchart_filename]            = timestamp +'_'+ myconfig[:barchart_filename]           + '.pdf'
myconfig[:barchart_html_filename]       = timestamp +'_'+ myconfig[:barchart_html_filename]      + '.html'
myconfig[:piechart_single_filename]     = timestamp +'_'+ myconfig[:piechart_single_filename]    + '.pdf'
myconfig[:piechart_all_filename]        = timestamp +'_'+ myconfig[:piechart_all_filename]       + '.pdf'
myconfig[:alpha_text_filename]          = timestamp +'_'+ myconfig[:alpha_text_filename]         + '.txt'
myconfig[:alpha_plots_filename]         = timestamp +'_'+ myconfig[:alpha_plots_filename]        + '.pdf'

pd_accumulator = ProjectDatasetAccumulator.new(myconfig, sqlclient)

file_paths = {}
# The counts file is used in many other visualizations and will be created 
#    if not already created
#file_paths['counts'] = pd_accumulator.write_counts_table()

#file_paths['distance'] = pd_accumulator.create_distance_matrix()            # depends on counts matrix

#file_paths['heatmap1'] = pd_accumulator.create_heatmap('counts','pdf')            # depends on counts matrix
#file_paths['heatmap2'] = pd_accumulator.create_heatmap('distance','pdf')     # depends on distance matrix
#file_paths['heatmap3'] = pd_accumulator.create_heatmap('distance','html')    # depends on distance matrix
#file_paths['piechart_single'] = pd_accumulator.create_piechart('single', 4) # depends on counts matrix
#######file_paths['piechart_all'] = pd_accumulator.create_piechart('all')    # depends on counts matrix
#file_paths['barchart'] = pd_accumulator.create_barcharts('pdf')                  # depends on counts matrix
file_paths['barchart2'] = pd_accumulator.create_barcharts('html')                  # depends on counts matrix
#file_paths['dendrogram'] = pd_accumulator.create_dendrogram()               # depends on distance matrix
#file_paths['alpha'] = pd_accumulator.create_alpha_diversity()               # depends on counts matrix
#file_paths['pcoa'] = pd_accumulator.create_pcoa()                            # depends on distance matrix
puts
file_paths.each do |name,path|
    puts path
end