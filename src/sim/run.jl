function run_once!(sim_data::OSMSim.SimData,
                            buffer::Array{OSMSim.Road,1},
                            nodes_stats::Dict{Int,OSMSim.NodeStat},
                            destination_selector::String,agentid::Int; google::Bool = false
                            )  
    loc = OSMSim.start_location(sim_data.demographic_data)
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
    activity = OSMSim.additional_activity(agent,true)	
    local routebefore
    if isa(activity,Nothing)
        routebefore = OSMSim.select_route(agent.DA_home[1], agent.DA_work[1],sim_data, buffer, google = google)        
    else
        routebefore = OSMSim.select_route(agent.DA_home[1], agent.DA_work[1], activity,sim_data, buffer,google = google)        
    end
    OSMSim.stats_aggregator!(nodes_stats, agent, routebefore)
    local routeafter
    #after work
    activity = OSMSim.additional_activity(agent,false)
    if isa(activity,Nothing)
        routeafter = OSMSim.select_route(agent.DA_work[1], agent.DA_home[1], sim_data, buffer,google = google)
    else
        routeafter = OSMSim.select_route(agent.DA_work[1], agent.DA_home[1], activity, sim_data, buffer,google = google)        
    end
    OSMSim.stats_aggregator!(nodes_stats, agent, routeafter)
    return (routebefore,routeafter)
end

function run_simulation(sim_data::OSMSim.SimData,
            destination_selector::String,job::Int,
            N::Int; google::Bool = false)
	if !in(destination_selector,["flows","business","both"])
		error("destination_selector not declared properly! It can only takes flows, business or both values!")
	end
    nodes_stats = OSMSim.node_statistics(sim_data)
    buffer = Array{OSMSim.Road,1}()
    routes = Dict()
    for i = 1:N
        agentid = (job*1000000) + i
        routes[agentid] = OSMSim.run_once!(sim_data,buffer,nodes_stats,destination_selector,agentid, google = google)
		i == 1 && @info "Worker: $(Distributed.myid()) First simulation completed"
    end
    #$(Distributed.myid())
	@info "Worker: $(Distributed.myid()) All $N simulations completed"
    return nodes_stats,buffer,routes
end