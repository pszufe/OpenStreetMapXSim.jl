# module simulation

using OpenStreetMap
using CSV
using DataFrames, DataFramesMeta
using Base.Dates
using Distributions
using FreqTables 
using HTTP, HttpCommon
using JSON
using Query 
using Revise
using Shapefile
using StatsBase

#=
export start_location_selector
export destination_location_selectorJM, destination_location_selectorDP
export demographic_profile_generator
export additional_activity_schools
export additional_activity_popularstores
export additional_activity_shoppingcentre
export additional_activity_recreation
export additional_activity_selector
export create_map
export findroutes, findroutes_waypoints # fastest and shortest routes
export googlemapsroute, changeCoordToString
export route_module_selector
export stats_aggregator
=#

include("datasets_desc_dict.jl") # datasets variables description dictionaries
# include("datasets_parse.jl") # can be run only once to process and export datasets
include("datasets_import.jl") # import datasets processed with datasets_parse.jl
include("starting_location.jl") # starting location selector
include("agent_profile.jl") # agent demographic profile generator
include("destination_location.jl") # destination location selectors
include("additional_activity.jl") # additional activities selectors as waypoints
include("routing_module.jl") # routing modes: fastest route, shortest route, googlemaps route
include("statistics_aggregator.jl") # intersections statistics aggregator

# end 
