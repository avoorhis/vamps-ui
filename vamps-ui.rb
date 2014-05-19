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
myconfig[:tax_counts_output_filename]      += timestamp + '.mtx'
myconfig[:dist_output_filename]            += timestamp + '.mtx'
myconfig[:heatmap_output_filename]         += timestamp + '.mtx'
myconfig[:pcoa_output_filename]            += timestamp + '.mtx'
myconfig[:dendrogram_output_filename]      += timestamp + '.mtx'
myconfig[:barchart_output_filename]        += timestamp + '.mtx'
myconfig[:piechart_output_filename]        += timestamp + '.mtx'


pd_accumulator = ProjectDatasetAccumulator.new(myconfig, sqlclient)


pd_accumulator.print_counts_table()

pd_accumulator.create_distance_matrix()




