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
	business_data::Dict{Int,Dict{Symbol,String}}
    DAs_flows::SparseMatrixCSC{Float64,Int64}
end

mutable struct AgentProfile
    DA_home::Int         
    DA_work::Int         
    gender::String          
    age::Int             
    marital_status::Bool #true if married or living with a common-law partner, false otherwise
    work_industry::String 
    household_income::Int #household data
    household_size::Int #household data 
    no_of_children::Int #household data  
    children_age::Union{Bool,Array{Int,1}} #household data - returns array of children's ages if no_of_children >0, false otherwise
    imigrant::Bool #true if immigrant, false if not 
    imigrant_since::String
    imigrant_region::String #household data
end