
###################################
# Start location selector
###################################

"""
Start location selector

Selects starting DA_home for an agent randomly weighted by weight_var
    
**Arguments**
* `demostat` : dataframe with weight_var value for each DA
* `weight_var` : weighting variable name
"""
function start_location(demostat::Dict, weight_var::Symbol)
    weights = StatsBase.fweights([ds[weight_var] for ds in collect(values(demostat))])
    return StatsBase.sample(collect(keys(demostat)), weights)
end