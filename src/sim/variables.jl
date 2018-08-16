# maximum distance from DA_home to city_centre to assume DA_home is in the downtown
max_distance_from_cc = 8000

# quantiles of the home - business distance for agents living in the downtown:
# agent living in the downtown tend to work in the businesses located from home within 0.5 quantile 
# of the distribution of all distances home-business for a given industry
q_centre = 0.5

# quantiles of the home - business distance for agents NOT living in the downtown 
q_other = 0.7

# radius around Home/Work within which an agent might go shopping
distance_radius_H = 3000      # metres
distance_radius_W = 2000      # metres

# working-out probabilities - TO BE CONFIRMED
p_recreation_before = 0.4     # before work
p_recreation_F = 0.5          # for females
p_recreation_M = 0.7          # for males
p_recreation_younger = 0.8    # for younger
p_recreation_older = 0.2      # for older
young_old_limit = 55          # age at which agents get from younger to older
p_recreation_poorer = 0.2     # for poorer     
p_recreation_richer = 0.9     # for richer
poor_rich_limit = 100000      # income at which agents get from poorer to richer