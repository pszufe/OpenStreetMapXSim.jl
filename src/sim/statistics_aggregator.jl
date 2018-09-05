
###################################
# Statistics aggregator
###################################


function node_statistics(sim_data::OSMSim.SimData)::Dict{Int,OSMSim.NodeStat}
    nodes_stats = Dict{Int,OSMSim.NodeStat}()
    for (key,value) in sim_data.intersections
        coords = OpenStreetMap.LLA(sim_data.nodes[key],OpenStreetMap.center(sim_data.bounds))
        latitude, longitude = coords.lat, coords.lon
        nodes_stats[key] = OSMSim.NodeStat(0,latitude,longitude,nothing)
    end
    return nodes_stats
end


"""
Statistics aggregator

Aggregates data for each intersection and returns dictionary with keys as unique nodes_id 
and values as NodeStat struct.
    
**Arguments**
* `nodes_stats` : dictionary with keys as unique nodes_id and values as NodeStat struct
* `agent_profile` : selected agent profile as a DemoProfile object
* `route` : route represented by nodes ids

"""
function stats_aggregator!(nodes_stats::Dict{Int,OSMSim.NodeStat}, 
                        agent_profile::DataFrames.DataFrame, 
                        route::Array{Int,1} )
    for indice in route
        node = nodes_stats[indice]
        node.count += 1
		if isa(node.agents_data,Nothing)		    
			node.agents_data = deepcopy(agent_profile)
		else
			append!(node.agents_data,agent_profile)
		end
    end
end

