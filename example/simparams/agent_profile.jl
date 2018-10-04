###################################
# Agent demographic profile generator
###################################

"""
Demographic profile generator

Creates socio-demographic profile of an agent based on demostats distributions per dissemination area (DA)

**Arguments**

* `DA_home` : unique id of DA centroid home location selected for an agent
* `DA_demostat` : dictionary  with population statistics for specific DA
* `demographic_categories` : dictionary with demographic categories used in generating of agent's profile

"""
function demographic_profile(DA_home::Int, DA_demostat::Nothing;
							demographic_categories = demographic_categories)::DataFrames.DataFrame
	profile = Dict()
	profile[:DA_home] = DA_home
	profile[:DA_work] = 0
	for key in keys(demographic_categories)
		categories = demographic_categories[key]
		category = rand(keys(categories))
		value = categories[category]
		if isa(value,UnitRange)
			profile[key] = rand(value)
		else
			profile[key] = value
		end
	end
	return DataFrames.DataFrame(profile)
end
