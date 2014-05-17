
module Config
    #DATASET_ID_ORDER = ["153",255,"3", "4",-1,'AA','"', "5", "6", "7", "93", "94", "95", "96", "97", "98", "99", "101", "101"]
    DATASET_ID_ORDER = [   "4",-1,'AA','"', "5", "6", "7"]
    RANKS = %w(domain phylum class order family genus species)
    DIST_METRICS = %w(horn yue_clayton bray jaccard manhattan gower raup euclidean canberra kulczynski)
    INIT_OBJ = { 
        ids:   DATASET_ID_ORDER,
#        units: 'tax_silva108',  # must be the name of the field in sequence_uniq_infos
        units: 'taxonomy',
        rank:  RANKS[1],
        taxa:  'bacteria',
        nas:   true,
        sort:  true,
        verbose: true,
        dmetric: DIST_METRICS[3]
        }
end


