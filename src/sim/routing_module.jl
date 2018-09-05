
###################################
# Routing module
###################################

###################################
# Route module selector


function get_route(start_node::Int,
					waypoint::Union{Int,Nothing},
					fin_node::Int, 
					activity::Union{String,Nothing},
                    sim_data::OSMSim.SimData,
                    buffer::Array{OSMSim.Road,1},
                    routing_mode::String)
    if routing_mode == "fastest"
		if isa(waypoint,Nothing)
			route_nodes, distance, route_time = OpenStreetMap.fastest_route(sim_data.network, start_node, fin_node)
		else
			route_nodes, distance, route_time = OpenStreetMap.fastest_route(sim_data.network, start_node, waypoint, fin_node)
		end
        road = OSMSim.Road(start_node,fin_node, activity, routing_mode,route_nodes, 1)
        push!(buffer,road)
        return route_nodes
    elseif routing_mode == "shortest"
		if isa(waypoint,Nothing)
			route_nodes, distance, route_time = OpenStreetMap.shortest_route(sim_data.network, start_node, fin_node)
		else
			route_nodes, distance, route_time = OpenStreetMap.shortest_route(sim_data.network, start_node, waypoint, fin_node)
		end
        road = OSMSim.Road(start_node,fin_node, activity, routing_mode,route_nodes, 1)
        push!(buffer,road)
        return route_nodes
	else 
		if isa(waypoint,Nothing)
			route_nodes,routing_mode = OSMSim.get_google_route(start_node, fin_node, sim_data)
		else
			route_nodes,routing_mode = OSMSim.get_google_route(start_node, fin_node, waypoint, sim_data)
		end
        road = OSMSim.Road(start_node,fin_node, activity, routing_mode,route_nodes, 1)
        push!(buffer,road)
        return route_nodes
    end
end

function get_waypoint(start_node::Int,
					fin_node::Int,
					activity::String,
					sim_data::OSMSim.SimData,
					exact::Bool)
	waypoints = OpenStreetMap.filter_graph_features(sim_data.features, sim_data.feature_to_intersections,sim_data.feature_classes,activity)
	if exact
		return waypoint = OpenStreetMap.find_optimal_waypoint_exact(sim_data.network, sim_data.network.w, start_node, fin_node, waypoints)
	else
		return waypoint = OpenStreetMap.find_optimal_waypoint_approx(sim_data.network, sim_data.network.w, start_node, fin_node, waypoints)
	end
end

"""
Route module selector

Selects routing mode for two points from the following options: fastest route, shortest route  and returns a route
    
**Arguments**
* `DA_start` : DA_start unique id selected for an agent
* `DA_fin` : DA_fin unique id selected for an agent
* `sim_data` : simulation data struct
* `DAs_to_intersection` : dictionary mapping each DA to nearest graph node 
* `buffer` : array with already chosen routes 

**Assumptions**
- the probability of selecting each routing mode is equal

**To Do **
-add google maps route 

"""
function select_route(DA_start::Int, DA_fin::Int, 
                    sim_data::OSMSim.SimData,
                    buffer::Array{OSMSim.Road,1}; google::Bool = false)
    start_node = sim_data.DAs_to_intersection[DA_start]
    fin_node = sim_data.DAs_to_intersection[DA_fin]
    waypoint = activity = nothing
    if google
		routing_mode = rand(["shortest", "fastest", "google"])
	else
		routing_mode = rand(["shortest", "fastest"])
	end
	indice = findfirst(road -> (road.start_node == start_node) &&  (road.fin_node == fin_node) && (road.waypoint == waypoint)  && (road.mode == routing_mode), buffer)
    if isa(indice,Nothing)
		return OSMSim.get_route(start_node, waypoint, fin_node, activity, sim_data, buffer, routing_mode)
    else
		buffer[indice].count += 1
		return buffer[indice].route
    end          
end

"""
Route module selector for three

Selects routing mode for three points from the following options: fastest route, shortest route  and returns a route
    
**Arguments**
* `DA_start` : DA_start unique id selected for an agent
* `DA_fin` : DA_fin unique id selected for an agent
* `network` : routing network based on OSM data
* `DAs_to_intersection` : dictionary mapping each DA to nearest graph node 
* `features` : dictionary with all features existing in simulation
* `feature_classes` : dictionary mapping each category to proper integer number
* `feature_to_intersections` : dictionary mapping each feature to nearest graph node 
* `buffer` : array with already chosen routes 

**Assumptions**
- the probability of selecting each routing mode is equal
-agent is choosing a waypoint based on previously selected activity
-waypoint is approximately minimizing the distance of the route from pointA to waypoint and pointB

**To Do **
-add google maps route 

"""					
function select_route(DA_start::Int, DA_fin::Int, 
                    activity::String,
                    sim_data::OSMSim.SimData,
                    buffer::Array{OSMSim.Road,1}; google::Bool = false)
    start_node = sim_data.DAs_to_intersection[DA_start]
    fin_node = sim_data.DAs_to_intersection[DA_fin]
	if google
		routing_mode = rand(["shortest", "fastest", "google"])
	else
		routing_mode = rand(["shortest", "fastest"])
	end
    indice = findfirst(road -> (road.start_node == start_node) &&  (road.fin_node == fin_node) && (road.waypoint == activity)  && (road.mode == routing_mode), buffer)
    if isa(indice,Nothing)
		waypoint = OSMSim.get_waypoint(start_node,fin_node,activity,sim_data,false)
		return OSMSim.get_route(start_node, waypoint, fin_node, activity, sim_data, buffer, routing_mode)
    else
		buffer[indice].count += 1
		return buffer[indice].route
    end
end