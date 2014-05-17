class VisualizationController < ApplicationController
  
  before_action :authenticate_user!
  protect_from_forgery except: :parse_view
  
  require 'benchmark' 
  require 'project_dataset_accumulator'
  include TaxaCountHelper
  @@counts_per_dataset_id = Hash.new
  @@choosen_projects_w_d  = Hash.new
  @@taxonomy_w_cnts_by_d  = Hash.new
    
  # Andy, I'm collecting all project ids togeteher, is it okay? E.g.: "project_ids"=>["6", "8"], "dataset_ids"=>["3", "4", "238", "239"]

  def index
    # this list needs to be limited if user doesn't have full permissions
    # Also the presented project list should be encapsulated to
    # reflect what is potentially being requested
    # if metadata then only projects with metadata
    # if geo-distribution then only project with lan/lon
    # etc
    @datasets_by_project_all = make_datasets_by_project_hash()
    @domains  = Domain.all
    @ranks    = Rank.all.sorted    
    fresh_when(@domains)
    fresh_when(@ranks)   
    
  end
#########################################################################  

  def parse_view
    # todo: simplify, comment, see https://codeclimate.com/repos/526bee0356b1022c5301920b/VisualizationController
    @domains  = Domain.all
    @ranks    = Rank.all.sorted
    @selected_rank = Rank.find(params['tax_id']).rank
    @selected_rank_number = Rank.find(params['tax_id']).rank_number
    @selected_domains = params['domains']
    unless (params.has_key?(:dataset_ids))
      dataset_not_choosen()
      return      
    end
    
    result = Benchmark.measure do
      @@choosen_projects_w_d  = get_choosen_projects_w_d()
    end

    
    my_pdrs = Hash.new
    result = Benchmark.measure do
      my_pdrs = SequencePdrInfo.taxonomy_ids.where(dataset_id: params["dataset_ids"].uniq)
    end
    # puts "PPP: my_pdrs = " + my_pdrs.inspect

    
    result = Benchmark.measure do
      @@counts_per_dataset_id = get_counts_per_dataset_id(my_pdrs)
    end

    
    create_taxonomy_w_counts_to_show(Rank.find(params[:tax_id]).rank_number, my_pdrs)
    
    @counts_per_dataset_id = @@counts_per_dataset_id
    @choosen_projects_w_d  = @@choosen_projects_w_d
    
    pd_accumulator = ProjectDatasetAccumulator.new(params[:dataset_ids])
    
    what_to_show(params[:view])
  end
#########################################################################  

  def what_to_show(to_render = params[:view])
    @counts_per_dataset_id = @@counts_per_dataset_id
    
    @choosen_projects_w_d  = @@choosen_projects_w_d
    
    @taxonomy_w_cnts_by_d  = @@taxonomy_w_cnts_by_d
    
    render to_render
  end
  
  private
#########################################################################  
  
  def get_choosen_projects_w_d()
    project_array = Array.new
    d_ids  = params[:dataset_ids]   
    p_objs = get_choosen_projects()
    p_objs.each do |p_obj, d_arr|
      
      choosen_p_w_d            = Hash.new
      choosen_p_w_d[:pid]      = p_obj[:id]
      choosen_p_w_d[:pname]    = p_obj[:project]
      choosen_p_w_d[:datasets] = d_arr.select {|d| d[:id] if d_ids.include? d[:id].to_s}
      project_array << choosen_p_w_d
    end
    return project_array
  end
#########################################################################  
  
  def get_choosen_projects()
    datasets_by_project_all = make_datasets_by_project_hash()
    p_objs = datasets_by_project_all.select {|p_o| p_o[:id] if params[:project_ids].include? p_o[:id].to_s }
    return p_objs
  end  
#########################################################################  
  
  def make_datasets_by_project_hash()
    puts 'IN  make_datasets_by_project_hash'
    puts current_user.username
    if current_user.admin?
        projects = Project.all    
        datasets = Dataset.all
    else
        public_projects = Project.where('public is true')
        
        if current_user.username == 'guest'
            projects = public_projects
            datasets = Dataset.joins('JOIN projects ON project_id=projects.id where public is true')
        else
            user_projects = Project.joins("JOIN users_projects on projects.id=users_projects.project_id where users_projects.user_id=#{current_user.id}")
            projects = user_projects + public_projects
            datasets = Dataset.all
        end
    end
       
    datasets_by_project = Hash.new
    projects.each do |p|
        datasets_by_project[p] = datasets.select{|d| d.project_id == p.id}
    end
    projects = ''
    datasets = ''
    return datasets_by_project
  end
#########################################################################  
  
  def dataset_not_choosen()
    redirect_to visualization_index_path, :alert => 'Choose some data!'
  end
#########################################################################  
  def get_counts_per_dataset_id(my_pdrs)
    counts_per_dataset_id = Hash.new
    
    my_pdrs.each do |d|
      # puts "my_pdrs.each = " + d.inspect
      #<SequencePdrInfo id: 1620, dataset_id: 4, sequence_id: 1005, seq_count: 20, classifier: "GAST", created_at: "2013-08-19 13:04:05", updated_at: "2013-08-19 13:04:05">
      if counts_per_dataset_id[d[:dataset_id]].nil? 
        counts_per_dataset_id[d[:dataset_id]] = d[:seq_count]
      else
        counts_per_dataset_id[d[:dataset_id]] += d[:seq_count]
      end
    end

    # puts "counts_per_dataset_id = " + counts_per_dataset_id.to_s
    return counts_per_dataset_id
  end
#########################################################################  

  def make_taxon_strings_w_counts_per_d(taxonomy_by_t_id_upto_rank, tax_hash_obj, taxonomy_per_d)
    # todo: move to an object?
    taxon_strings_w_counts_per_d = Hash.recursive
    taxonomy_by_t_id_upto_rank.each do |taxonomy_id, taxonomy_hash|
      taxon_strings_w_counts_per_d[taxonomy_hash[:taxon_string]] = fill_zeros(tax_hash_obj.get_cnts_per_dataset_ids_by_tax_ids(taxonomy_per_d, taxonomy_hash[:tax_ids]))
    end
    # puts "\nPPP, taxon_strings_w_counts_per_d = " + taxon_strings_w_counts_per_d.inspect
    # PPP, taxon_strings_w_counts_per_d = {82=>["Bacteria", "Proteobacteria", "Gammaproteobacteria", {3=>8, 4=>4}], 96=>["Bacteria", "Actinobacteria", "class_NA", {3=>2, 4=>2}], 137=>["Bacteria", "Proteobacteria", "Alphaproteobacteria", {3=>3}]}
    
    return taxon_strings_w_counts_per_d
  end
#########################################################################  
  
  def fill_zeros(cnts_per_dataset_ids_by_tax_ids)
     #puts "VVV: params[\"dataset_ids\"] = " + params["dataset_ids"].inspect
     #puts "VVV1: cnts_per_dataset_ids_by_tax_ids = " + cnts_per_dataset_ids_by_tax_ids.inspect
    
    params[:dataset_ids].each do |d_id|
      cnts_per_dataset_ids_by_tax_ids[d_id.to_i] = 0 unless cnts_per_dataset_ids_by_tax_ids[d_id.to_i].is_a? Numeric
    end
    #puts "WWW: cnts_per_dataset_ids_by_tax_ids = " + cnts_per_dataset_ids_by_tax_ids.inspect
    return cnts_per_dataset_ids_by_tax_ids
  end
#########################################################################  
 
  def create_taxonomy_w_counts_to_show(rank_number, my_pdrs)
    @taxonomies            = {}
    @dat_counts_seq_tax    = {}    
    
    tax_hash_obj           = TaxaCount.new    
    taxonomy_per_d = Hash.new
    result = Benchmark.measure do
      taxonomy_per_d         = get_taxonomy_per_d(my_pdrs, tax_hash_obj)
    end
    
    # 1) make taxonomy_id strings from Taxonomy by rank
    # 2) get taxon names
    # 3) arrange by dataset_ids
    # 4) add counts to show in tax_table_view    
    taxonomy_by_t_id_upto_rank_obj = TaxonomyWNames.new
    taxonomy_by_t_id_upto_rank     = Hash.new
    result = Benchmark.measure do
      taxonomy_by_t_id_upto_rank = taxonomy_by_t_id_upto_rank_obj.create(rank_number, @taxonomies)
    end
    
    result = Benchmark.measure do
      @@taxonomy_w_cnts_by_d = make_taxon_strings_w_counts_per_d(taxonomy_by_t_id_upto_rank, tax_hash_obj, taxonomy_per_d)
    end
    
    @@taxonomy_w_cnts_by_d
  end
end
#########################################################################  
#########################################################################  
module TaxaCountHelper

  def get_taxonomy_per_d(my_pdrs, tax_hash_obj)

    dat_counts_seq = []
    
    dat_counts_seq = create_dat_seq_cnts(my_pdrs)  
    
    
    @dat_counts_seq_tax = dat_counts_seq
    
    
    @taxonomies = get_taxonomies(dat_counts_seq)
       

    # @taxonomies = taxonomies
    # puts "\nHHH: taxonomies = " + taxonomies.inspect

    tax_hash = {}
    
    tax_hash     = tax_hash_obj.create(@taxonomies, dat_counts_seq)
    
      
    # puts "\nRES: tax_hash = " + tax_hash.inspect
    # RES: tax_hash = {2=>{3=>{3=>{16=>{18=>{129=>{129=>{4=>{:datasets_ids=>{3=>8, 4=>4}}, :datasets_ids=>{3=>8, 4=>4}}, :datasets_ids=>{3=>8, 4=>4}}, :datasets_ids=>{3=>8, 4=>4}}, :datasets_ids=>{3=>8, 4=>4}}, :datasets_ids=>{3=>8, 4=>4}}, 5=>{65=>{129=>{129=>{129=>{4=>{:datasets_ids=>{3=>3}}, :datasets_ids=>{3=>3}}, :datasets_ids=>{3=>3}}, :datasets_ids=>{3=>3}}, :datasets_ids=>{3=>3}}, :datasets_ids=>{3=>3}}, :datasets_ids=>{3=>11, 4=>4}}, 4=>{32=>{5=>{52=>{76=>{129=>{4=>{:datasets_ids=>{3=>2, 4=>2}}, :datasets_ids=>{3=>2, 4=>2}}, :datasets_ids=>{3=>2, 4=>2}}, :datasets_ids=>{3=>2, 4=>2}}, :datasets_ids=>{3=>2, 4=>2}}, :datasets_ids=>{3=>2, 4=>2}}, :datasets_ids=>{3=>2, 4=>2}}, :datasets_ids=>{3=>13, 4=>6}}}
    
    return tax_hash
  end
#########################################################################  

  def create_dat_seq_cnts(my_pdrs)
    dat_seq_cnts = Array.new
    
    my_pdrs.each do |v|
      # puts "HERE: v = " + v.inspect
      # puts "HERE:  v.sequence_uniq_info = " +  v.sequence_uniq_info.inspect
      # HERE:  v.sequence_uniq_info = #<SequenceUniqInfo id: 1001, sequence_id: 1001, taxonomy_id: 96, gast_distance: #<BigDecimal:103a8ee28,'0.0',9(18)>, refssu_id: 0, refssu_count: 1263, rank_id: 5, refhvr_ids: "v4v5_FT014", created_at: "2013-08-19 13:11:00", updated_at: "2013-08-19 13:11:00">
      
      interm_hash = Hash.new
      interm_hash[:dataset_id]  = v.dataset_id
      interm_hash[:sequence_id] = v.sequence_id
      interm_hash[:seq_count]   = v.seq_count
      interm_hash[:taxonomy_id] = v.sequence_uniq_info.taxonomy_id
      
      dat_seq_cnts << interm_hash
    end
    return dat_seq_cnts
  end
#########################################################################  

  def get_taxonomies(dat_counts_seq)
    tax_ids = dat_counts_seq.map{|i| i[:taxonomy_id]}
    Taxonomy.where(id: tax_ids.uniq)
  end
  
end
#########################################################################  
#########################################################################  

class Hash
  def self.recursive
    new { |hash, key| hash[key] = recursive }
  end
end


