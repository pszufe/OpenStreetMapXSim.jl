####################################
### Types used in OSMsim package ###
####################################

"""
The `SimData` type is the type used to store all the crucial data  used in the OSM simulation module:
     
**Fields**
* `bounds` :  bounds of the area map (stored as a OpenStreetMap.Bounds object)
* `nodes` :  dictionary of nodes representing all the objects on the map (with coordinates in East, North, Up system)
* `roadways` :  unique roads stored as a OpenStreetMap.Way objects
* `intersections` : roads intersections
* `network` : graph representing a road network in the area limited by *bounds* (with intersections used as vertices)
* `features` : dictionary of all features (shops, schools, etc.)   
* `feature_classes` : dictionary mapping all features with the proper classes
* `feature_to_intersections` : dictionary mapping all features with the nearest intersection
* `DAs_to_intersection` : dictionary mapping all DA's with the nearest intersection
* `demographic_data` : dictionary containing a demographic data about each DA's
* `business_data` : array of dictionaries with a description of each business in the area
* `DAs_flow_dictionary` : dictionary mapping all DA's ID's with columns and rows of journey matrix
* `DAs_flow_matrix` : Journey matrix 
* `googleapi_key` : non obligatory key for using a *Google Distances API*
"""
mutable struct SimData
    bounds::OpenStreetMap.Bounds{OpenStreetMap.LLA}
    nodes::Dict{Int,OpenStreetMap.ENU} 
    roadways::Array{OpenStreetMap.Way,1}
    intersections::Dict{Int,Set{Int}}
    network::OpenStreetMap.Network
    features::Dict{Int,Tuple{String,String}}
    feature_classes::Dict{String,Int}
    feature_to_intersections::Dict{Int,Int}
    DAs_to_intersection::Dict{Int,Int}
	demographic_data::Dict{Int,Dict{Symbol,Int}}
	business_data::Array{Dict{Symbol,Union{String, Int,UnitRange{Int}}},1}
	DAs_flow_dictionary::Dict{Int,Int}
    DAs_flow_matrix::SparseArrays.SparseMatrixCSC{Int,Int}
	googleapi_key::Union{Nothing,String} 
end

"""
The `Road` type is the type used to store the informations about the roads chosen by agents during the simulation
     
**Fields**
* `start_node` :  starting point of a road
* `fin_node` :  finish point of a road
* `waypoint` :  type of waypoint (school, recreation, etc.) chosen by agent during his trip (if exist)
* `mode` : field describing the way how agent selects the road (he can choose either fastest, shortest or based on Google Distances API road)
* `route` : list of intersections crossed during agent's trip
* `count` : how many agents choose this particular way
"""
mutable struct Road
    start_node::Int
    fin_node::Int
    waypoint::Union{String,Nothing}
    mode::String
    route::Array{Int,1}
    count::Int
end

"""
The `NodeStat` type is the type used to store the informations about each intersection (graph vertex) in simulation and  demographic profiles of agents crossing this particular intersection.
     
**Fields**
* `count` : indicates how many agents had crossed this intersection
* `latitude` : latitude of the vertex
* `longitude` : longitude of the vertex
* `agents_data` : a data frame with demographic profiles of agents
"""
mutable struct NodeStat
    count::Int
    latitude::Float64
    longitude::Float64
    agents_data::Union{DataFrames.DataFrame, Nothing}
end