

function node_to_string(node_id::Int,sim_data::OSMSim.SimData)
    coords = OpenStreetMap.LLA(sim_data.nodes[node_id],sim_data.bounds)
    return string(coords.lat,",",coords.lon)
end

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

function get_googleapi_url(origin::Int,destination::Int,
                            sim_data::OSMSim.SimData;
                            googleapi_parameters::Dict{Symbol,String} = OSMSim.googleAPI_parameters)
    origin = OSMSim.node_to_string(origin, sim_data)
    destination = OSMSim.node_to_string(destination, sim_data)
    return googleapi_parameters[:url]*"origin="*origin*"&destination="*destination*
    "&avoid="*googleapi_parameters[:avoid]*"&units="*googleapi_parameters[:units]*
    "&mode="*googleapi_parameters[:mode]*"&key="*sim_data.googleapi_key
end