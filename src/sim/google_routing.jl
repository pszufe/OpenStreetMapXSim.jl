#########################
### Google routing module
#########################

"""
Dictionary for Google Distances API requests:

**Keys**
* `:url` : url for google API, only JSON files outputs are accepted 
* `:mode` : transportation mode used in simulation, in the current library scope only driving is accepted
* `:avoid` : map features to avoid (to mantain compatibility with OSM routes ferries should be avoided)
* `:units` : unit system for displaing distances (changing to *imperial* needs deeper changes in both OSMsim and OpenStreetMap2 modules) 

"""
const googleAPI_parameters = Dict{Symbol,String}(
:url => "https://maps.googleapis.com/maps/api/directions/json?", 
:mode  => "driving", 
:avoid => "ferries", 
:units => "metric",
)


"""
Convert node coordinates (stored in ENU system) to string with LLA system coordinates
    
**Arguments**
* `node_id` : unique node id 
* `sim_data` : `SimData` object

"""
function node_to_string(node_id::Int,sim_data::OSMSim.SimData)
    coords = OpenStreetMap2.LLA(sim_data.nodes[node_id],sim_data.bounds)
    return string(coords.lat,",",coords.lon)
end

"""
Gets Google Distances API request url with three points (origin, destination, waypoint between)
    
**Arguments**
* `origin` : unique node id 
* `destination` : unique node id 
* `waypoint` : unique node id 
* `sim_data` : `SimData` object
* `googleapi_parameters` : dictionary with assumptions about Google Distances API request

"""
function get_googleapi_url(origin::Int,destination::Int, waypoint::Int,
                            sim_data::OSMSim.SimData;
                            googleapi_parameters::Dict{Symbol,String} = OSMSim.googleAPI_parameters)
    origin = OSMSim.node_to_string(origin, sim_data)
    destination = OSMSim.node_to_string(destination, sim_data)
    waypoint = OSMSim.node_to_string(waypoint, sim_data)   
    return googleapi_parameters[:url]*"origin="*origin*"&destination="*destination*"&waypoints="*waypoint*
    "&avoid="*googleapi_parameters[:avoid]*"&units="*googleapi_parameters[:units]*
    "&mode="*googleapi_parameters[:mode]*"&key="*sim_data.googleapi_key
end

"""
Gets Google Distances API request url with two points (origin and destination)
    
**Arguments**
* `origin` : unique node id 
* `destination` : unique node id 
* `sim_data` : `SimData` object
* `googleapi_parameters` : dictionary with assumptions about Google Distances API request

"""
function get_googleapi_url(origin::Int,destination::Int,
                            sim_data::OSMSim.SimData;
                            googleapi_parameters::Dict{Symbol,String} = OSMSim.googleAPI_parameters)
    origin = OSMSim.node_to_string(origin, sim_data)
    destination = OSMSim.node_to_string(destination, sim_data)
    return googleapi_parameters[:url]*"origin="*origin*"&destination="*destination*
    "&avoid="*googleapi_parameters[:avoid]*"&units="*googleapi_parameters[:units]*
    "&mode="*googleapi_parameters[:mode]*"&key="*sim_data.googleapi_key
end

"""
Get JSON file from Google Distances API request and extract results
    
**Arguments**
* `url` : string with proper url

"""
function parse_google_url(url::String)
    status, routes = nothing, nothing
    res_json = JSON.parse(String(HTTP.get(url).body))
    status, routes = res_json["status"], res_json["routes"]
    return status, routes
end

"""
Extract route from Google API results
    
**Arguments**
* `routes` : dictionary with informations about the route

"""
function extract_google_route(routes::Dict)
    res = Array{Tuple{Float64,Float64},1}[]
    legs = routes["legs"]
    for leg in legs
        steps = leg["steps"]
        for step in steps
            push!(res,OSMSim.decode(step["polyline"]["points"]))
        end
    end
    return vcat(res...)
end

"""
Match Google route with vertices of map network  
    
**Arguments**
* `route` : array with LLA coordinates of crucial route points
* `sim_data` : `SimData` object

"""
function google_route_to_network(route::Array{Tuple{Float64,Float64},1},sim_data::OSMSim.SimData)
    route = [OpenStreetMap2.ENU(OpenStreetMap2.LLA(coords[1], coords[2]),sim_data.bounds) for coords in route]
    res = [OpenStreetMap2.nearest_node(sim_data.nodes, route[1], sim_data.network)]
    index = 2
    for i = 2:length(route)
        node = OpenStreetMap2.nearest_node(sim_data.nodes, route[i], sim_data.network)
        if node != res[index-1]
            push!(res,node)
            index += 1
        end
    end
    return res
end

"""
Get route based on Google Distances API with three points (origin, destination, waypoint between)
    
**Arguments**
* `origin` : unique node id 
* `destination` : unique node id 
* `waypoint` : unique node id 
* `sim_data` : `SimData` object
* `googleapi_parameters` : dictionary with assumptions about Google Distances API request

"""
function get_google_route(origin::Int,destination::Int,waypoint::Int,
                            sim_data::OSMSim.SimData;
                            googleapi_parameters::Dict{Symbol,String} = OSMSim.googleAPI_parameters)
    url = OSMSim.get_googleapi_url(origin, destination, waypoint,sim_data;googleapi_parameters = googleapi_parameters)
    status, routes = OSMSim.parse_google_url(url)
    if status == "OK"
        route = OSMSim.extract_google_route(routes[1])
        return OSMSim.google_route_to_network(route,sim_data), "google"
    elseif status =="ZERO_RESULTS"
        return Int[], "google"
    elseif status == "OVER_QUERY_LIMIT"
        sleep(0.5)
        return OSMSim.get_google_route(origin,destination,waypoint,sim_data,googleapi_parameters = googleapi_parameters)
    else
        #get route based on OSM routing
        warn("Google Distances API cannot get a proper results - route will be calculated with OSMSim Routing module")
		if rand() < 0.5
			route_nodes, distance, route_time = OpenStreetMap2.shortest_route(sim_data.network, origin, waypoint, destination)
			return route_nodes, "shortest"
		else
			route_nodes, distance, route_time = OpenStreetMap2.fastest_route(sim_data.network, origin, waypoint, destination)
			return route_nodes, "fastest"
		end
    end
end

"""
Get route based on Google Distances API with two points (origin and destination)
    
**Arguments**
* `origin` : unique node id 
* `destination` : unique node id 
* `sim_data` : `SimData` object
* `googleapi_parameters` : dictionary with assumptions about Google Distances API request

"""
function get_google_route(origin::Int,destination::Int,
                            sim_data::OSMSim.SimData;
                            googleapi_parameters::Dict{Symbol,String} = OSMSim.googleAPI_parameters)
    url = OSMSim.get_googleapi_url(origin, destination,sim_data;googleapi_parameters = googleapi_parameters)
    status, routes = OSMSim.parse_google_url(url)
    if status == "OK"
        route = OSMSim.extract_google_route(routes[1])
        return OSMSim.google_route_to_network(route,sim_data), "google"
    elseif status =="ZERO_RESULTS"
        return Int[],"google"
    elseif status == "OVER_QUERY_LIMIT"
        sleep(0.5)
        return OSMSim.get_google_route(origin,destination,sim_data,googleapi_parameters = googleapi_parameters)
    else
        #get route based on OSM routing
        warn("Google Distances API cannot get a proper results - route will be calculated with OSMSim Routing module")
		if rand() < 0.5
			route_nodes, distance, route_time = OpenStreetMap2.shortest_route(sim_data.network, origin, destination)
			return route_nodes, "shortest"
		else
			route_nodes, distance, route_time = OpenStreetMap2.fastest_route(sim_data.network, origin, destination)
			return route_nodes, "fastest"
		end
    end
end
