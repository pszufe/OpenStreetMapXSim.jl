
###################################
# Statistics aggregator
###################################


mutable struct NodeStat
    node_id::Int
    count::Int
    coordinates_ENU::OpenStreetMap.ENU
    coordinates_LLA::Tuple{Float64,Float64}
    DA_home::Array{Int}                             
    DA_work::Array{Int}                         
    routing_mode::Array{String}                     
    agent_profile::Array{DemoProfile}
    additional_activity::Array{AdditionalActivity}
end


# dictionary with aggregated data for each node / intersection
nodes_stats = Dict{Int, NodeStat}()


"""
Statistics aggregator

Aggregates data for each intersection and returns dictionary with keys as unique nodes_id 
and values as NodeStat struct.
    
**Arguments**
* `additional_activity` : selected additional activities (waypoints) for an agent as an AdditionalActivity object
* `agent_profile` : selected agent profile as a DemoProfile object
* `DA_home` : DA_home unique id selected for an agent
* `DA_work` : DA_work unique id selected for an agent
* `nodes_stats` : dictionary with keys as unique nodes_id and values as NodeStat struct
* `route` : RouteData.route object (route represented by nodes ids)
* `routingMode` : routing mode selected for an agent as a Function

**Output
NodeStat dictionary with the following objects for each key as a node_id:
- `node_id` : node unique id 
- `count` : total traffic count in a node
- `coordinates_ENU` : node ENU coordinates in OpenStreetMap.ENU format
- `coordinates_LLA` : node LLA coordinates as a Tuple{Float64,Float64}
- `DA_home` : DA_home selected for and agent
- `DA_work` : DA_work selected for and agent
- `routing_mode` : routing mode selected for an agent
- `agent_profile` : selected agent profile as a DemoProfile object
- `additional_activity` : selected additional activities (waypoints) for an agent as an AdditionalActivity object
"""
function stats_aggregator(additional_activity, agent_profile, DA_home, DA_work, 
                          nodes_stats, route, routingMode)

    for node_id in route
        
        if haskey(nodes_stats, node_id)
            nodes_stats[node_id].count += 1
            push!(nodes_stats[node_id].DA_home, DA_home) # push! to be replaced with something more effective?
            push!(nodes_stats[node_id].DA_work, DA_work)
            push!(nodes_stats[node_id].routing_mode, replace(string(routingMode), "OpenStreetMap." => ""))
            push!(nodes_stats[node_id].agent_profile, agent_profile)
            push!(nodes_stats[node_id].additional_activity, additional_activity)

        else
            lla = LLA(nodes[node_id], center(WinnipegMap.bounds))
            nodes_stats[node_id] = NodeStat(node_id,
                                            1, 
                                            nodes[node_id],
                                            (lla.lat, lla.lon),
                                            [DA_home],
                                            [DA_work],
                                            [replace(string(routingMode), "OpenStreetMap." => "")],
                                            [agent_profile],
                                            [additional_activity])
        end
    end
    
    return nodes_stats
end

