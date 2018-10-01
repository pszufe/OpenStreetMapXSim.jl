"""
Additional activity selector

returns a category of additional activity choosen by agent.

**Arguments**
* `feature_classes` : dictionary containing all possible types of features in the simulation

** Assumptions
 - there is maximum one waypoint
 -probability of driving directly to work is equal to 0.5
 -otherwise waypoint type is chosen randomly from the features categories
"""
function additional_activity(agent_profile::DataFrames.DataFrame, before::Bool,
	                         sim_data::OSMSim.SimData)
	if rand() < 0.5
		return nothing
	else
		return rand(keys(sim_data.feature_classes))
	end
end
