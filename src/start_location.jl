###############################
### Start location selector ###
###############################

"""
Start location selector

Selects starting DA centroid for an agent randomly weighted by weight_var (when weight_var is not defined DA centroid is chosen uniformly) 
    
**Arguments**
* `demostat` : dictionary with socio-demographic profile of each DA
* `weight_var` : weighting variable name (or nothing)
"""
function start_location(demostat::Dict{Int,Union{Nothing,Dict{Symbol,Int}}}; weight_var::Union{Symbol,Nothing} = nothing)
	if isa(weight_var, Nothing)
		return rand(keys(demostat))
	else
		weights = StatsBase.fweights([ds[weight_var] for ds in collect(values(demostat))])
		return StatsBase.sample(collect(keys(demostat)), weights)
	end
end

