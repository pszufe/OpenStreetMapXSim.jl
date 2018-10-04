
datapath = "/home/ubuntu/datasets/"
using OpenStreetMapX
using OpenStreetMapXSim

mutable struct RouteData
    shortest_route
    fastest_route
    google_route
end


function find_routes(sim_data::OpenStreetMapXSim.SimData,demographic_profile::Function,google = false)::RouteData
    loc = OpenStreetMapXSim.start_location(sim_data.demographic_data)
    agent = demographic_profile(loc, sim_data.demographic_data[loc])
    OpenStreetMapXSim.destination_location!(agent,sim_data.business_data)
    activity = additional_activity(agent,true,sim_data)
    start_node = sim_data.DAs_to_intersection[agent.DA_home[1]]
    fin_node = sim_data.DAs_to_intersection[agent.DA_work[1]]
    shortest_route,fastest_route,google_route = nothing,nothing,nothing
    if isa(activity,Nothing)
        if google
            google_route, mode = OpenStreetMapXSim.get_google_route(start_node,fin_node,sim_data.map_data)
        end
        shortest_route, shortest_distance, shortest_time = OpenStreetMapX.shortest_route(sim_data.map_data.network, start_node,fin_node)
        fastest_route, fastest_distance, fastest_time = OpenStreetMapX.fastest_route(sim_data.map_data.network, start_node,fin_node)
    else
        waypoint = OpenStreetMapXSim.get_waypoint(start_node,fin_node,activity,sim_data,false)
        if google
            google_route, mode = OpenStreetMapXSim.get_google_route(start_node,fin_node,waypoint,sim_data.map_data)
        end
        shortest_route, shortest_distance, shortest_time = OpenStreetMapX.shortest_route(sim_data.map_data.network, start_node, waypoint,fin_node)
        fastest_route, fastest_distance, fastest_time = OpenStreetMapX.fastest_route(sim_data.map_data.network, start_node, waypoint,fin_node)
    end

    return RouteData(shortest_route,
    fastest_route,
    google_route)

end

include("simparams/_loadparams.jl")
sim_data = get_sim_data(datapath);
r = find_routes(sim_data,demographic_profile, true)
