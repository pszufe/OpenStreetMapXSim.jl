######################
### Run simulation ###
######################

"""
Run one simulation iteration 
    
**Arguments**
* `sim_data` : `SimData` object
* `buffer` : list of `OSMSim.Road` objects containing informations about routes selected during the simulation run.
* `nodes_stats` : dictionary of `OSMSim.NodeStat` objects containing informations about each intersection in simulation.
* `destination_selector` : string determining a way how the destination (workplace) will be selected (based on journey matrix, business data or on both)
* `weight_var` : weighting variable name (or nothing)
* `google` : boolean variable; if true simulation will generates routes based on Google Distances API
"""
function run_once!(sim_data::OSMSim.SimData,
                            buffer::Array{OSMSim.Road,1},
                            nodes_stats::Dict{Int,OSMSim.NodeStat},
                            destination_selector::String; 
							weight_var:: Union{Symbol,Nothing} = nothing,
							google::Bool = false
                            )  
    loc = OSMSim.start_location(sim_data.demographic_data, weight_var = weight_var)
    agent = OSMSim.demographic_profile(loc, sim_data.demographic_data[loc])
    if destination_selector == "flows"
        OSMSim.destination_location!(agent,sim_data.DAs_flow_dictionary,sim_data.DAs_flow_matrix)
    elseif destination_selector == "business"
        OSMSim.destination_location!(agent,sim_data.business_data)
	else
		OSMSim.destination_location!(agent,sim_data)
    end
    #before work
    activity = OSMSim.additional_activity(sim_data.feature_classes)	
    if isa(activity,Nothing)
        route = OSMSim.select_route(agent.DA_home[1], agent.DA_work[1],sim_data, buffer, google = google)
        OSMSim.stats_aggregator!(nodes_stats, agent, route)
    else
        route = OSMSim.select_route(agent.DA_home[1], agent.DA_work[1], activity,sim_data, buffer,google = google)
        OSMSim.stats_aggregator!(nodes_stats, agent, route)
    end
    #after work
    activity = OSMSim.additional_activity(sim_data.feature_classes)
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
Run simulation

Run simulation for data stored in `SimData` object
    
**Arguments**
* `sim_data` : `SimData` object
* `destination_selector` : string determining a way how the destination (workplace) will be selected (based on journey matrix, business data or on both)
* `N` : number of iterations
* `weight_var` : weighting variable name (or nothing)
* `google` : boolean variable; if true simulation will generates routes based on Google Distances API
"""
function run_simulation(sim_data::OSMSim.SimData,
            destination_selector::String,
            N::Int; 
			weight_var::Union{Symbol,Nothing} = OSMSim.weight_var, 
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