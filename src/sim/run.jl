######################
### Run simulation ###
######################

"""
Start location selector

Selects starting DA centroid for an agent randomly weighted by weight_var (when weight_var is not defined DA centroid is chosen uniformly) 
    
**Arguments**
* `demostat` : dictionary with socio-demographic profile of each DA
* `weight_var` : weighting variable name (or nothing)
"""
function run_once!(sim_data::OSMSim.SimData,
                            buffer::Array{OSMSim.Road,1},
                            nodes_stats::Dict{Int,OSMSim.NodeStat},
                            destination_selector::String; 
							weight_var:: Union{Symbol,Nothing},
							google::Bool = false
                            )  
    loc = OSMSim.start_location(sim_data.demographic_data)
    agent = OSMSim.demographic_profile(loc, sim_data.demographic_data[loc], weight_var = weight_var)
    if destination_selector == "flows"
        OSMSim.destination_location!(agent,sim_data.DAs_flow_dictionary,sim_data.DAs_flow_matrix)
    elseif destination_selector == "business"
        OSMSim.destination_location!(agent,sim_data.business_data)
	else
		OSMSim.destination_location!(agent,sim_data)
    end
    #before work
    activity = OSMSim.additional_activity(agent,true)	
    if isa(activity,Nothing)
        route = OSMSim.select_route(agent.DA_home[1], agent.DA_work[1],sim_data, buffer, google = google)
        OSMSim.stats_aggregator!(nodes_stats, agent, route)
    else
        route = OSMSim.select_route(agent.DA_home[1], agent.DA_work[1], activity,sim_data, buffer,google = google)
        OSMSim.stats_aggregator!(nodes_stats, agent, route)
    end
    #after work
    activity = OSMSim.additional_activity(agent,false)
    if isa(activity,Nothing)
        route = OSMSim.select_route(agent.DA_work[1], agent.DA_home[1], sim_data, buffer,google = google)
        OSMSim.stats_aggregator!(nodes_stats, agent, route)
    else
        route = OSMSim.select_route(agent.DA_work[1], agent.DA_home[1], activity, sim_data, buffer,google = google)
        OSMSim.stats_aggregator!(nodes_stats, agent, route)
    end
    return nothing
end

"""
Start location selector

Selects starting DA centroid for an agent randomly weighted by weight_var (when weight_var is not defined DA centroid is chosen uniformly) 
    
**Arguments**
* `demostat` : dictionary with socio-demographic profile of each DA
* `weight_var` : weighting variable name (or nothing)
"""
function run_simulation(sim_data::OSMSim.SimData,
            destination_selector::String,
            N::Int; weight_var::Union{Symbol,Nothing} = OSMSim.weight_var, 
			google::Bool = false)
	if !in(destination_selector,["flows","business","both"])
		error("destination_selector not declared properly! It can only takes flows, business or both values!")
	end
    nodes_stats = OSMSim.node_statistics(sim_data)
    buffer = Array{OSMSim.Road,1}()
    for i = 1:N
        OSMSim.run_once!(sim_data,buffer,nodes_stats,destination_selector, weight_var = weight_var, google = google)
		i == 1 && @info "First simulation completed"
    end
    #TODO check why $(Distributed.myid()) does not work
	@info "All $N simulations completed"
    return nodes_stats,buffer
end