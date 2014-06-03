#!/usr/bin/env ruby -w

counts_file_path    = ARGV[0]
out_file_path       = ARGV[1]
rank                = ARGV[2]
show_legend         = ARGV[3]

lines = []
counter = 0
datasets = []
file = File.new(counts_file_path, "r")
while (line = file.gets)
    puts line
    items = line.split
    if counter==0
        datasets = items
    else
        lines << line
    end
    
    counter = counter + 1
end
file.close
# remove 'UNITS'
datasets.shift


black = '000000';
green = '008000';
grey  = '808080';
myfile = File.new("barchart.html", "w+") 
##myfile = File.new(out_file_path, "w+") 
myfile.puts "<html>"
myfile.puts "<head>"
myfile.puts "<link rel=\"stylesheet\" type=\"text/css\" href=\"scripts/mystyle.css\">"
myfile.puts "<link rel=\"stylesheet\" type=\"text/css\" href=\"scripts/barchart.css\">"
#myfile.puts "<script src=\"http://cdn.jquerytools.org/1.2.2/jquery.tools.min.js\"></script>"
#myfile.puts "<script type=\"text/javascript\" src = \"scripts/tooltip.js\"></script>"
#myfile.puts "<script type=\"text/javascript\" src=\"http://github.com/DmitryBaranovskiy/raphael/raw/master/raphael-min.js\"></script>"
myfile.puts "<script type=\"text/javascript\" src = \"scripts/mootools-beta-1.2b2.js\"></script>"
myfile.puts "<script type=\"text/javascript\" src = \"scripts/barchart.js\"></script>"
myfile.puts "<title>Test HTML Page</title>"
d = datasets.join('|')
myfile.puts "<script>var datasets='"+d+"'</script>"
myfile.puts "</head>"

myfile.puts "<body>"

myfile.puts "<div id=\"main\">"
myfile.puts "<h1>BarChart</h1>"
#cell_width = 14
#cell_height = 8
#num_cols = datasets.length
#table_width_first_col = 250
#table_width = cell_width * num_cols + table_width_first_col;
myfile.puts "<table border=\"1\" width='200'>"
myfile.puts "<tr>"
myfile.puts "<td>DATASETS</td>"# 
#datasets.each do |ds|
    #myfile.puts "<td> #{ds} </td>"
#end
myfile.puts "</tr>"
puts datasets.inspect
row_counter = 0
dataset_collect = {}
taxa = []
lines.each do |row|
    col_counter = 0   
    items = row.split
    
    items.each do |value|
        ds = datasets[col_counter]
        if col_counter==0
            taxa << value
        else
            
            if dataset_collect.key?(ds)
                dataset_collect[ds] << value 
            else
                dataset_collect[ds] = [value] 
            end
        end
        col_counter = col_counter + 1
    end
    row_counter = row_counter + 1
end

#puts dataset_collect.inspect


myfile.puts "</table>"
myfile.puts "</div>"

myfile.puts "<div id=\"side\">"


myfile.puts "</div>"

# myfile.puts "<div id='canvas_container'>"
# myfile.puts "</div>"
# 
# myfile.puts "<span id='heatmap_tooltip'>"
# 	myfile.puts "<table style='margin:0'>"	    
# 		myfile.puts "<tr>"		   
# 			myfile.puts "<td class='count'>Distance:</td>"
# 			myfile.puts "<td id='distance'></td>"
# 		myfile.puts "</tr>"
# 		myfile.puts "<tr>"		   
# 			myfile.puts "<td class='count'>Metric:</td>"
# 			myfile.puts "<td id='metric'></td>"
# 		myfile.puts "</tr>"
# 		myfile.puts "<tr>"		    
# 			myfile.puts "<td class='pct'>x-Dataset:</td>"
# 			myfile.puts "<td id='ds1'></td>"
# 		myfile.puts "</tr>"
# 		myfile.puts "<tr>"		    
# 			myfile.puts "<td class='project'>y-Dataset:</td>"
# 			myfile.puts "<td id='ds2'></td>"
# 		myfile.puts "</tr>"			
# 	myfile.puts "</table>"	
# myfile.puts "</span>"  

myfile.puts "</body>"
myfile.puts "</html>"