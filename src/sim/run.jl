function run_once!(sim_data::OSMSim.SimData,
                            buffer::Array{OSMSim.Road,1},
                            nodes_stats::Dict{Int,OSMSim.NodeStat},
                            flows::Bool
                            )  
    loc = OSMSim.start_location(sim_data.demographic_data)
    agent = OSMSim.demographic_profile(loc, sim_data.demographic_data[loc])
    if flows
        OSMSim.destination_location!(agent,sim_data.DAs_flow_dictionary,sim_data.DAs_flow_matrix)
    else
        OSMSim.destination_location!(agent,sim_data.business_data)
    end
    #before work
    activity = OSMSim.additional_activity(agent,true)
    if isa(activity,Void)
        route = OSMSim.select_route(agent.DA_home, agent.DA_work,sim_data, buffer)
        OSMSim.stats_aggregator!(nodes_stats, agent, route)
    else
        route = OSMSim.select_route(agent.DA_home, agent.DA_work, activity,sim_data, buffer)
        OSMSim.stats_aggregator!(nodes_stats, agent, route)
    end
    #after work
    activity = OSMSim.additional_activity(agent,false)
    if isa(activity,Void)
        route = OSMSim.select_route(agent.DA_work, agent.DA_home, sim_data, buffer)
        OSMSim.stats_aggregator!(nodes_stats, agent, route)
    else
        route = OSMSim.select_route(agent.DA_work, agent.DA_home, activity, sim_data, buffer)
        OSMSim.stats_aggregator!(nodes_stats, agent, route)
    end
    return nothing
end

function run_simulation(sim_data::OSMSim.SimData,
            flows::Bool,
            N::Int)
    nodes_stats = OSMSim.node_statistics(sim_data)
    buffer = Array{OSMSim.Road,1}()
    for i = 1:N
        OSMSim.run_once!(sim_data,buffer,nodes_stats,flows)
    end
    return nodes_stats,buffer
end