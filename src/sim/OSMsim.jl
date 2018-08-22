module OSMSim 

using DataFrames
using StatsBase
using OpenStreetMap

export get_sim_data
export start_location
export demographic_profile
export additional_activity
export destination_location!

include("types.jl")
include("constants.jl")
include("data.jl")
include("start_location.jl")
include("agent_profile.jl")
include("additional_activity.jl")
include("destination_location.jl")

end