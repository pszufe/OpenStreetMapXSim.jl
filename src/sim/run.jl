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
                            destination_selector::String,
							agentid::Int; 
							weight_var:: Union{Symbol,Nothing} = nothing,
							google::Bool = false     
							)  
    loc = OSMSim.start_location(sim_data.demographic_data, weight_var = weight_var)
    agent = OSMSim.demographic_profile(loc, sim_data.demographic_data[loc])
    agent[:id]=agentid
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
        routebefore = OSMSim.select_route(agent.DA_home[1], agent.DA_work[1],sim_data, buffer, google = google)        
    else
        routebefore = OSMSim.select_route(agent.DA_home[1], agent.DA_work[1], activity,sim_data, buffer,google = google)        
    end
    OSMSim.stats_aggregator!(nodes_stats, agent, routebefore)
    local routeafter
    #after work
    activity = OSMSim.additional_activity(sim_data.feature_classes)
    if isa(activity,Nothing)
        routeafter = OSMSim.select_route(agent.DA_work[1], agent.DA_home[1], sim_data, buffer,google = google)
    else
        routeafter = OSMSim.select_route(agent.DA_work[1], agent.DA_home[1], activity, sim_data, buffer,google = google)        
    end
    OSMSim.stats_aggregator!(nodes_stats, agent, routeafter)
    return (routebefore,routeafter)
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
			job::Int,
            N::Int; 
			weight_var::Union{Symbol,Nothing} = OSMSim.weight_var, 
			google::Bool = false)
	if !in(destination_selector,["flows","business","both"])
		error("destination_selector not declared properly! It can only takes flows, business or both values!")
	end
    nodes_stats = OSMSim.node_statistics(sim_data)
    buffer = Array{OSMSim.Road,1}()
    routes = Dict()
    for i = 1:N
        agentid = (job*1000000) + i
        routes[agentid] = OSMSim.run_once!(sim_data,buffer,nodes_stats,destination_selector,agentid, weight_var = weight_var google = google)
		i == 1 && @info "Worker: $(Distributed.myid()) First simulation completed"
    end
    #$(Distributed.myid())
	@info "Worker: $(Distributed.myid()) All $N simulations completed"
    return nodes_stats,buffer,routes
end