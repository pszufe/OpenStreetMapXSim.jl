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
    DAs_flows::SparseMatrixCSC{Float64,Int64}
end