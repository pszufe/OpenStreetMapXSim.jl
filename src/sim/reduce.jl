###############################
### Result reduction functions
###############################

"""
Reduce buffers

Join buffers returned by multiple runs of simulation
    
**Arguments**
* `buffer` : list of `OSMSim.Road` objects containing informations about routes selected during the simulation run.

"""
function reduce_results(buffer::Array{OSMSim.Road,1}...)::Array{OSMSim.Road,1}
    reduced_buffer = OSMSim.Road[]
    buffer = vcat(buffer...)
    buffer  = [(Tuple(getfield(buffer[i],field) for field in fieldnames(typeof(buffer[i]))[1:end-1]), buffer[i].count) for i = 1:length(buffer)]
    unique_roads = Set(map(road -> road[1], buffer))
    for road in unique_roads
        count = sum(buffer[i][2] for i in findall(x->(x[1] == road), buffer))
        push!(reduced_buffer,OSMSim.Road(road...,count))
    end
    return reduced_buffer
end

"""
Reduce nodes statistics

Join nodes statistics returned by multiple runs of simulation
    
**Arguments**
* `nodes` : dictionary of `OSMSim.NodeStat` objects containing informations about each intersection in simulation.

"""
function reduce_results(nodes::Dict{Int64,OSMSim.NodeStat}...)::Dict{Int64,OSMSim.NodeStat}
    reduced_nodes = Dict{Int64,OSMSim.NodeStat}()
    ids = keys(merge(nodes...))
    for id in ids
        count = sum(node[id].count for node in nodes)
        lat = unique(node[id].latitude for node in nodes)[1]
        lon = unique(node[id].longitude for node in nodes)[1]
        agents_data = vcat([node[id].agents_data for node in nodes]...)
        reduced_nodes[id] = OSMSim.NodeStat(count,lat,lon,agents_data)
    end
    return reduced_nodes
end
