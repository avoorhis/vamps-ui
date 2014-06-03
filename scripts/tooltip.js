 
$(document).ready(function() { 	
	  $(".cell").tooltip({
         
             
                   tip: "#heatmap_tooltip",          
				   position: 'center below',          
				   offset: [-40,0],
				   opacity: 0.9,          
				   delay: 0,
				   
				   onBeforeShow: function(){
				     
					  var ttip = this.getTrigger().attr("id");
					  
					  stuff = ttip.split('|')
					  datasetx = stuff[0];
					  datasety = stuff[1];
					  metric = stuff[2];
					  distance = stuff[3];
					  dm = metric+': '+distance
					  var newarray=[];
					 
                      $("#heatmap_tooltip table td#distance").text(distance); 	
 					  $("#heatmap_tooltip table td#metric").text(metric); 					  
 					  $("#heatmap_tooltip table td#ds1").text(datasetx);
 					  $("#heatmap_tooltip table td#ds2").text(datasety);
 					 					  
				
				  },			  
				  
                 onHide: function(){
                     //this.getTrigger().parents("tr").children().eq("2").css('background-color', 'grey');          
                 
                 }          
      
      });         
      
      $(".cell").hover(function() {
         
         var cell = $(this);
         //test = cell.parents("tr").cells;
         //alert ('test= '+test)
	
	  });
	
 });


//  $(document).ready(function() { 
//       // this is for the tool tips on the hover over the chart icon on the crosstab table(chart icon)	
//      $(".chart").tooltip({
//          
//              
//                    tip: "#tooltip",          
// 				   position: 'center left',          
// 				   offset: [-40,0],
// 				   opacity: 0.8,          
// 				   delay: 0,
// 				   
// 				   onBeforeShow: function(){
// 				     
// 					  var taxon = this.getTrigger().parents("tr").attr("id");
// 					  var num = this.getTrigger().parents("tr").children()[0].textContent
// 				
// 					  taxa = taxon.split(';')
// 					  var newarray=[];
// 					  for(i in taxa){
// 	                      //newrow = t.rows.length
// 	                      //alert(taxa[i])
// 	                      if (taxa[i] != 'NA'){
// 	                         newarray.push(taxa[i])
// 	                      }
// 	                      
// 					  }
// 					  second = newarray.pop();
// 					  first = newarray.pop();
// 					  short_taxon = first+';'+second;
// 
//  					  $("#tooltip table td#row").text(num);
//  					  $("#tooltip table td#taxon").text(short_taxon);
//  					  //$("#tooltip table td#stats1").text(pct_string);
//  					  //$("#tooltip table td#total").text(total);
// 					  
// 				
// 				  },			  
// 				  
//                  onHide: function(){
//                      //this.getTrigger().parents("tr").children().eq("2").css('background-color', 'grey');          
//                  
//                  }          
//       
//       });         
//       
//       $(".chart").hover(function() {
//          
//          var cell = $(this);
//          //test = cell.parents("tr").cells;
//          //alert ('test= '+test)
// 	
// 	  });
// 	
// });


