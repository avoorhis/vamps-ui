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

tax_output_filename = 'tax_counts.mtx'
dist_output_filename = 'distance.mtx'

pd_accumulator = ProjectDatasetAccumulator.new(Config::INIT_OBJ, sqlclient)

pd_accumulator.print_counts_table(tax_output_filename)
#pd_accumulator.print_distance_matrix(dist_output_filename, Config::INIT_OBJ[:dmetric])
#puts "\033[1;31mbold red text\033[0m\n"