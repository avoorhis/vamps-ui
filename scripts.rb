
class Scripts
  
  
  def initialize
    @myscripts = {
      distance:         "scripts/distance.R",
      heatmap_counts:   "scripts/heatmap_counts.R",
      heatmap_distance: "scripts/heatmap_distance.R",
      dendrogram:       "scripts/dendrogram.R",
      piechart:         "scripts/piechart.R",
      barchart:         "scripts/barchart.R"
    }
  end
  
  def run(script, args)
    
    puts @myscripts[script]
    puts args.inspect
    # Rscript --slave --no-restore ./scripts/distance.R tax_counts1400357817.mtx Morisita-Horn xxx
    cmd = "/usr/bin/Rscript --slave --no-restore" 
    cmd += " "+@myscripts[script]
    args.each do |arg|
        cmd += " "+arg.to_s
    end
    puts cmd
    `#{cmd}`   # runs command
    return args[1]
  end
  
end