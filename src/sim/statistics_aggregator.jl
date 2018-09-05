
###################################
# Statistics aggregator
###################################


function node_statistics(sim_data::OSMSim.SimData,profile::Type{OSMSim.AgentProfile} = OSMSim.AgentProfile)::Dict{Int,OSMSim.NodeStat}
    fields = collect(fieldnames(profile))
    types = [fieldtype(profile, t) for t in fields]
    agents_data = DataFrames.DataFrame(types,fields,0)
    nodes_stats = Dict{Int,OSMSim.NodeStat}()
    for (key,value) in sim_data.intersections
        coords = OpenStreetMap.LLA(sim_data.nodes[key],OpenStreetMap.center(sim_data.bounds))
        latitude, longitude = coords.lat, coords.lon
        nodes_stats[key] = OSMSim.NodeStat(0,latitude,longitude,deepcopy(agents_data))
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
                        agent_profile::OSMSim.AgentProfile, 
                        route::Array{Int,1} )
    profile = [getfield(agent_profile,field) for field in fieldnames(typeof(agent_profile))]
    for indice in route
        node = nodes_stats[indice]
        node.count += 1
        push!(node.agents_data,profile)
    end
    return nothing
end

