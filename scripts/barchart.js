/*
Script: barchart.js

Dependencies:
	mootools-beta-1.2b2.js
	moocanvas.js

Author:
	Greg Houston, <http://greghoustondesign.com/>

Credits:
	Based on Stoyan Stefanov's Canvas bar:< http://www.phbard.com/canvas-bar/>
	Color algorithm inspired by Jim Bumgardner:<http://www.krazydad.com/makecolors.php>

License:
	MIT License, <http://en.wikipedia.org/wiki/MIT_License>	
	
Example Usage:
	
<table class="barChart">
    <tr><th>Browser</th> <th>Value</th></tr>
    <tr><td>Safari </td> <td>180  </td></tr>
    <tr><td>Firefox</td> <td>210  </td></tr>
    <tr><td>IE     </td> <td>30   </td></tr>
    <tr><td>Opera  </td> <td>120  </td></tr>
</table>

*/


var BarChart = new Class({
	options: {
		barChartHeight: 15,  // Height of your bar chart
		barChartWidth: 900,  // width of your bar chart
    	td_label_index: 0,    // which TD contains the label			
    	td_index: 1,          // which TD contains the data	
    	td_color_index: 2,    // and which td contains the color; form= '#000000'
    	td_link_index: 3,      // relative link info 
    	td_sitetotal_index: 4,  // total
    	td_site_index: 5       // site: project--dataset
	},
	initialize: function(options){
		this.setOptions(options);
		
		// Initialize variables
		this.barChartHeight = this.options.barChartHeight;		
		this.barChartWidth = this.options.barChartWidth;
		
		this.index = 0;
		this.tableIndex = 1;
		this.areaIndex = 1;
		this.canvas = '';
		this.container = '';
		this.data_table = '';
		
		// Run Methods
		$$('.barChart').each( function(el){
			this.insertElements(el);
			this.makebarChart(el);			
		}.bind(this) );
		this.addToolTips();		
	},
	insertElements: function(el){
		
    	///// STEP 1 - Insert HTML Elements
	
		// Insert a div that will contain the bar chart
		this.container = new Element('div', {
			id: 'barChartContainer' + this.tableIndex
		}).injectBefore($(el)).addClass('barChartContainer');

		// Pull the table out of the page and put it in the bar chart container
		this.data_table = el.clone().injectBottom(this.container);
		el.dispose();
		
		// Insert a div that will contain both the bar chart canvas and it's image map overlay		
		new Element('div', {
			id: 'barChartWrapper' + this.tableIndex
		}).injectTop(this.container).addClass('barChartWrapper');
		
		// Insert the canvas to draw the bar on
		this.canvas = new Element('canvas', {
			id: 'canvas' + this.tableIndex,
			width: this.barChartWidth,
			height: this.barChartHeight
		}).injectInside(this.container.getElement('.barChartWrapper')).addClass('barChartCanvas');
		
		// Insert the map element. The area elements will be added later
		new Element('map', {		
			id: 'barChartMap' + this.tableIndex,
			name: 'barChartMap' + this.tableIndex			
		}).injectBottom(this.container).addClass('barChartMap');
		
		// Insert the blank transparent gif that is used for the image map
		new Asset.image('/library/MooTools.net/spacer.gif', {
			alt: '',
			usemap: '#barChartMap' + this.tableIndex,
			width: this.barChartWidth,
			height: this.barChartHeight
		}).injectInside(this.container.getElement('.barChartWrapper')).setStyles({
				'width': this.barChartWidth,
				'height': this.barChartHeight
			});

		// Insert a div to insure layout integrity
		new Element('div').injectBottom(this.container).addClass('clear');
	
	},
	makebarChart: function(){

    	///// STEP 2 - Get the data

    	// Get the data[] from the table
    	var tds, data = [], color, colors = [], link, links = [], label, labels = [], 
    	             titles = [], value = 0, values = [], taxa_url=[], total = 0;
    	var trs = this.data_table.getElementsByTagName('tr'); // all TRs
    	//var tableLength = trs.length; // removes header row
		// For each table row ...
		for (var i = 0; i < trs.length; i++) {
        	tds = trs[i].getElementsByTagName('td'); // Get the TDs for this row. There should two of them
                                                      // three if I add color to the table
                                                      // four if I add a link
			if (tds.length === 0) continue; //  no TDs here, move on
           
            // create the url
        	// Get the value, update total
			label = tds[this.options.td_label_index].innerHTML;
			
			// titles are for tooltips
			titles[i] = label;
			
			// replace white space with '%20' for url
			taxa_url[i] = label.replace(/\s+/g, "%20");
			//label = label.split(';');
			if(label.search(';') == -1) 
			{
			   // there are no ';' here
			   labels[i]=label;
			   
			}
			else  // labels with ';' are taxa
			{
				
				label = label.split(';');
					
				for(k=label.length-1; k > 0; k--)
				{
				   if(label[k] != 'NA')
				   {
					 if(label[k-1])
					 {
					   labels[i] =label[k-1] + ' ' + label[k];
					 }
					 else
					 {
						labels[i] =label[k];
					 }
					 break;
				   }
				   else
				   {
					  labels[i] =label[k-1] + ' ' + label[k];
				   }
				}
			}
			
	
	
	
	
	

	
        	value = parseFloat(tds[this.options.td_index].innerHTML);
        	//values[colors.length] = 'yy';
			values[i] = value; // Save value for canvas and tooltips     	

        	total += value;

            // I added the colors to the 3rd table column and retrieve them here
            color = tds[this.options.td_color_index].innerHTML;
            colors[i] = color; // 
                   	
            // for clickable barcharts: put the link data in the 4th table column
            link = tds[this.options.td_link_index].innerHTML;
            links[links.length] = link;            
        	
    	}

    	///// STEP 3 - Draw bar on canvas
		
		// only need one site total: no array needed
		site = tds[this.options.td_site_index].innerHTML;
    	site_total = parseFloat(tds[this.options.td_sitetotal_index].innerHTML);
    	
    	// get canvas context, determine radius and center
    	var ctx = this.canvas.getContext('2d');

		var barstart = 0;
		var tableLength = colors.length;
    	for (piece=0; piece < tableLength; piece++) {
    	//alert("tablelength= "+tableLength+" pce= "+piece)
            var thisvalue = values[piece] / total;
        	var barwidth = values[piece] * this.barChartWidth / total;	
        	
        	var barend = barwidth + barstart;
        	//alert('value '+values[piece]+' height:'+barwidth+' start: '+barstart+' end: '+barend)
			var pct = values[piece] / site_total * 100;
			//alert(barwidth)
			ctx.beginPath();
			//ctx.moveTo(0,0); // Center of the bar
			ctx.fillStyle = colors[piece]; // Color
			// fillRect(x,y,width,height)
			ctx.fillRect(barstart, 0, barend, this.barChartHeight);
    	
        	///// STEP 4 - Draw bar on image map						
			

			var myArea = 'area' + this.tableIndex + '-' + piece;
		    
		    // to make the area clickable I added the 'href' field: it takes data from the 4th table column
		    lnk = links[piece].replace(/&amp;/g, "&");
		    
		    if(lnk == 'nolink')
		    {
		       new Element('area', {
				'id': myArea ,
				'shape': 'rect',
				'coords': barstart + ',0,' + barend + ',' + this.barChartHeight,
				'title': values[piece] + '::' + titles[piece]	
								
			   }).injectInside(this.container.getElement('.barChartMap'));
		    }
		    else
		    {
				new Element('area', {
					'id': myArea ,
					'shape': 'rect',
					'coords': barstart + ',0,' + barend + ',' + this.barChartHeight,
					'title': '<div style="padding:10px;"> \
					   <table> \
					   <tr> \
					       <td style="background:'+colors[piece]+';width:10px;" width="2"><span></span></td> \
					       <td>Count: ' +values[piece]+ ' ('+pct.round(2)+'%)</td> \
					   </tr> \
					   <tr> \
					       <td colspan="2">'+site+'</td> \
					   </tr> \
					   <tr> \
					        <td colspan="2">' +titles[piece] + '</td> \
					   </tr> \
					   </table> \
					   </div>',					
					'href': lnk,				
					'target': '_blank'
					
				}).injectInside(this.container.getElement('.barChartMap'));
			}
            barstart = barend;
        	this.index += thisvalue; // increment progress tracker
    	}

	this.tableIndex++;
    	
	},
	addToolTips: function(){    

    		///// STEP 5 - Add Tooltips
           
			new Tips($$(document.getElementsByTagName('area')), {
				showDelay: 10,
				hideDelay: 10
				
			});	
	}
	
});
BarChart.implement(new Options);

window.addEvent('domready', function(){
		new BarChart();
});



