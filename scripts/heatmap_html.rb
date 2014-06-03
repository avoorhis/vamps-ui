#!/usr/bin/env ruby -w

dist_matrix_file_path   = ARGV[0]
out_file_path           = ARGV[1]
metric                  = ARGV[2]

lines = []
counter = 0
datasets = []
file = File.new(dist_matrix_file_path, "r")
while (line = file.gets)
    items = line.split
    if counter==0
        datasets = items
    else
        lines << line
    end
    
    counter = counter + 1
end
file.close


colors = [
 '1111ff',   #blue-0
  '3333ff',
  '5555ff',
  '7777ff',
  '9999ff',
  'aaaaff',
  'ccccff',
  'ddeeee',
  'eeeedd',
  'ffdddd',
  'ffbbbb',
  'ff9999',
  'ff7777',
  'ff5555',
  'ff3333',
  'ff0000'  # red-15
  ]
black = '000000' 
green = '008000';
grey  = '808080'  
myfile = File.new("heatmap.html", "w+") 
##myfile = File.new(out_file_path, "w+") 
myfile.puts "<html>"
myfile.puts "<head>"
myfile.puts "<link rel=\"stylesheet\" type=\"text/css\" href=\"scripts/mystyle.css\">"
myfile.puts "<script src=\"http://cdn.jquerytools.org/1.2.2/jquery.tools.min.js\"></script>"
myfile.puts "<script type=\"text/javascript\" src = \"scripts/tooltip.js\"></script>"
#myfile.puts "<script type=\"text/javascript\" src=\"http://github.com/DmitryBaranovskiy/raphael/raw/master/raphael-min.js\"></script>"
myfile.puts "<script type=\"text/javascript\" src = \"scripts/heatmap.js\"></script>"
myfile.puts "<title>Test HTML Page</title>"
d = datasets.join('|')
myfile.puts "<script>var datasets='"+d+"'</script>"
myfile.puts "</head>"

myfile.puts "<body>"

myfile.puts "<div id=\"main\">"
myfile.puts "<h1>Heatmap</h1>"
cell_width = 14
cell_height = 8
num_cols = datasets.length
table_width_first_col = 250
table_width = cell_width * num_cols + table_width_first_col;
myfile.puts "<table border=\"1\" width='#{table_width}'>"
myfile.puts "<tr>"
myfile.puts "<td>DATASETS</td>"
datasets.each do |ds|
    #myfile.puts "<td> #{ds} </td>"
end
myfile.puts "</tr>"

row_counter = 0
lines.each do |row|

    #puts row
    #puts
    myfile.puts "<tr>"
    # set at 300 and hope that no ds names are longer?
    myfile.puts "<td width='#{table_width_first_col}' align='right'> " + datasets[row_counter] + "</td>"
    col_counter = 0
    items = row.split
    items.each do |value|
        num = value.to_f
        cnum = '%.0f' % (num*15)
        puts "#{num} -- #{cnum}"
		color = colors[cnum.to_i];
		if col_counter == row_counter
		    color = black
		    myfile.puts "<td class='same' bgcolor='#{color}' width='#{cell_width}' height='#{cell_height}'></td>"
		else
		    tooltip = datasets[col_counter] +'|'+ datasets[row_counter] + '|'+metric+'|'+value
		    myfile.puts "<td class='cell' 
		                     id='#{tooltip}' 
		                     bgcolor='#{color}' 
		                     width='#{cell_width}' 
		                     height='#{cell_height}'
		                     onclick=\"open_pies('"+datasets[col_counter]+"','"+datasets[row_counter]+"')\" >
		                     </td>"
		end		
        
        col_counter = col_counter + 1
    end
    myfile.puts "<tr>"
    row_counter = row_counter + 1
end
myfile.puts "</table>"
myfile.puts "</div>"

myfile.puts "<div id=\"side\">"


myfile.puts "</div>"

myfile.puts "<div id='canvas_container'>"
myfile.puts "</div>"

myfile.puts "<span id='heatmap_tooltip'>"
	myfile.puts "<table style='margin:0'>"	    
		myfile.puts "<tr>"		   
			myfile.puts "<td class='count'>Distance:</td>"
			myfile.puts "<td id='distance'></td>"
		myfile.puts "</tr>"
		myfile.puts "<tr>"		   
			myfile.puts "<td class='count'>Metric:</td>"
			myfile.puts "<td id='metric'></td>"
		myfile.puts "</tr>"
		myfile.puts "<tr>"		    
			myfile.puts "<td class='pct'>x-Dataset:</td>"
			myfile.puts "<td id='ds1'></td>"
		myfile.puts "</tr>"
		myfile.puts "<tr>"		    
			myfile.puts "<td class='project'>y-Dataset:</td>"
			myfile.puts "<td id='ds2'></td>"
		myfile.puts "</tr>"			
	myfile.puts "</table>"	
myfile.puts "</span>"  

myfile.puts "</body>"
myfile.puts "</html>"