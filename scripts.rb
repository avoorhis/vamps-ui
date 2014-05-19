
class Scripts
  
  
  def initialize
    @myscripts = {
      distance: 'scripts/distance.R',
      heatmap:  "scripts/heatmap.R", 
      dendrogram: "scripts/dendrgram.R",
      piechart: "scripts/piechart.R",
      barchart: "scripts/barchart.R"
    }
  end
  
  def run(script, args)
    
    puts @myscripts[script]
    puts args.inspect
    # Rscript --slave --no-restore ./scripts/distance.R tax_counts1400357817.mtx Morisita-Horn xxx
    cmd = "/usr/bin/Rscript --slave --no-restore" 
    cmd += " "+@myscripts[script]
    cmd += " "+args[0]   # infile path
    cmd += " "+args[1]   # outfile path
    cmd += " "+args[2]   # metric
    puts cmd
    `#{cmd}`   # runs command
    return args[1]
  end
  
end