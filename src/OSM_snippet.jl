path = "sim/";
datapath = "../../datasets/";
using OpenStreetMapX

include(path*"OSMSim.jl")

using Main.OSMSim

mutable struct RouteData
    shortest_route
    fastest_route
    google_route
end

 const files = Dict{Symbol,Union{String,Array{String,1}}}(:osm => "map.osm", #smaller map
:features => [ "df_popstores.csv",
  "df_schools.csv",
  "df_recreationComplex.csv",
  "df_shopping.csv",],
:flows =>"df_hwflows.csv",
:DAs => "df_DA_centroids.csv",
:demo_stats => "df_demostat.csv",
:business_stats => "df_business.csv",
:googleapi_key => "googleapi.key"
)


function find_routes(sim_data::OSMSim.SimData,google = false)::RouteData
    loc = OSMSim.start_location(sim_data.demographic_data)
    agent = OSMSim.demographic_profile(loc, sim_data.demographic_data[loc])
    OSMSim.destination_location!(agent,sim_data.business_data)
    activity = OSMSim.additional_activity(sim_data.feature_classes)
    start_node = sim_data.DAs_to_intersection[agent.DA_home[1]]
    fin_node = sim_data.DAs_to_intersection[agent.DA_work[1]]
    shortest_route,fastest_route,google_route = nothing,nothing,nothing
    if isa(activity,Nothing)
        if google
            google_route, mode = OSMSim.get_google_route(start_node,fin_node,sim_data.map_data)
        end
        shortest_route, shortest_distance, shortest_time = OpenStreetMapX.shortest_route(sim_data.map_data.network, start_node,fin_node)
        fastest_route, fastest_distance, fastest_time = OpenStreetMapX.fastest_route(sim_data.map_data.network, start_node,fin_node)
    else
        waypoint = OSMSim.get_waypoint(start_node,fin_node,activity,sim_data,false)
        if google
            google_route, mode = OSMSim.get_google_route(start_node,fin_node,waypoint,sim_data.map_data)
        end
        shortest_route, shortest_distance, shortest_time = OpenStreetMapX.shortest_route(sim_data.map_data.network, start_node, waypoint,fin_node)
        fastest_route, fastest_distance, fastest_time = OpenStreetMapX.fastest_route(sim_data.map_data.network, start_node, waypoint,fin_node)
    end

    return RouteData(shortest_route,
    fastest_route,
    google_route)

end


sim_data = get_sim_data(datapath, filenames = files, google = true);
r = find_routes(sim_data, true)
