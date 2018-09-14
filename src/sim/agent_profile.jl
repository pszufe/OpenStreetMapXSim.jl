###################################
# Agent demographic profile generator
###################################

"""
Demographic profile generator

Creates socio-demographic profile of an agent based on demostats distributions per DA
    
**Arguments**
* `DA_home` : unique id of DA centroid home location selected for an agent
* `DA_demostat` : dictionary  with population statistics for specific DA
* `demografic_categories` : dictionary with demografic categories used in generating of agent's profile

"""
function demographic_profile(DA_home::Int, DA_demostat::Dict{Symbol,Int};
							demografic_categories = OSMSim.demografic_categories)::DataFrames.DataFrame
	profile = Dict()
	for key in keys(demografic_categories)
		categories = demografic_categories[key]
		weights = StatsBase.fweights(get.(Ref(DA_demostat), collect(keys(categories)), 0))
		value = StatsBase.sample(collect(values(categories)), weights)
		if isa(value,UnitRange)
			profile[key] = rand(value)
		else
			profile[key] = value
		end
	end
	return DataFrames.DataFrame(profile)
end