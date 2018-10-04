pth = "C:\\Users\\p\\Desktop\\OpenStreetMapXSim.jl\\src\\osm"
path = "C:\\Users\\p\\Desktop\\OpenStreetMapXSim.jl\\src\\sim"
datapath = "C:\\Users\\p\\Desktop\\datasets\\"

datafile = "SAMPLE_WinnipegCMA_TRAFCAN2017Q1.csv"
sim_results = "counts.csv"
mapfile = "Winnipeg CMA.osm"

include(joinpath(path,"OpenStreetMapXSim.jl"))

using Main.OpenStreetMapXSim
using DataFrames
using Nanocsv
using GLM
using Plots; pyplot()
using StatPlots


function compare_data(datapath::String,mapfile::String,resultfile::String, testfile::String, counttype::Union{Nothing,String}, save::Bool = true)
    map_data = OpenStreetMapX.get_map_data(datapath,mapfile)
    frame = DataFrames.DataFrame(Node_ID = Int[],latitude = Float64[], longitude = Float64[], empirical = Int[],simulation = Int[])
    traffic = Nanocsv.read_csv(joinpath(datapath,testfile))
    if !isa(counttype,Nothing)
        traffic = traffic[traffic[:CNTTYPE1] .== counttype,:]
    end
    nodes = Dict(key => value for (key,value) in map_data.nodes if haskey(map_data.network.v, key))
    traffic_data = Dict() 
    for i in 1:nrow(traffic)
        key = OpenStreetMapX.nearest_node(map_data.nodes,OpenStreetMapX.ENU(OpenStreetMapX.LLA(traffic[:LATITUDE][i],traffic[:LONGITUDE][i]),map_data.bounds),collect(keys(nodes)))
        if haskey(traffic_data, key)
            traffic_data[key][:TRAFFIC1][1] += traffic[i,:TRAFFIC1]
        else
            traffic_data[key] = traffic[i,[:LATITUDE,:LONGITUDE,:TRAFFIC1]]
        end
    end
    lines = readlines(open(joinpath(datapath,resultfile)))
    for line in lines
        x = parse.(Int,split(line))
        if haskey(traffic_data, x[1])
            push!(frame,(x[1],traffic_data[x[1]][:LATITUDE][1], traffic_data[x[1]][:LONGITUDE][1],traffic_data[x[1]][:TRAFFIC1][1], x[2]))
        end
    end
    model = GLM.lm(@formula(simulation ~ empirical - 1),frame)
    frame[:scaled_empirical] = GLM.predict(model)
    if !isa(counttype,Nothing)
        save && write_csv(joinpath(datapath,"traffic_data_comparision_$counttype.csv"),frame)
    else
        save && Nanocsv.write_csv(joinpath(datapath,"traffic_data_comparision.csv"),frame)
    end
    return frame, model
end

function get_comparision_dataset(datapath::String,mapfile::String,resultfile::String, testfile::String, save::Bool = true)
    counttypes= ["AADT", "ADT", "AWDT"]
    dataframe = DataFrames.DataFrame(Node_ID = Int[],latitude = Float64[], longitude = Float64[], empirical = Int[],simulation = Int[], scaled_empirical = Float64[], count_type = String[])
    for count in counttypes
        dframe, regression = compare_data(datapath,mapfile,resultfile,testfile, count,save)
        dframe[:count_type] = count
        append!(dataframe,dframe)
    end
    dataframe[:approximation_error] = abs.(dataframe[:scaled_empirical] .- dataframe[:simulation])./dataframe[:scaled_empirical]
    return dataframe
end

function get_grouped_hist(dataframe::DataFrames.DataFrame,nbars::Int, title::String)
    columns =  [:scaled_empirical,:simulation]
    min_val = minimum(vcat(dataframe[:scaled_empirical],dataframe[:simulation]))
    max_val = maximum(vcat(dataframe[:scaled_empirical],dataframe[:simulation]))
    tresholds = Int.(round.(range(min_val, stop = max_val, length = nbars+1))) |> collect
    categories = [UnitRange(tresholds[i],tresholds[i+1]) for i in 1:nbars]
    count_table = zeros(nbars,2)
    for i = 1:length(columns)
        for j = 1:nbars
            count_table[j,i] = sum(round(val) in categories[j] for val in dataframe[columns[i]])
        end
    end
    ctg = repeat(["Scaled Empirical","Simulation"], inner = nbars)
    nam = repeat([(minimum(c),maximum(c)) for c in categories], outer = length(columns))
    groupedbar(nam, count_table, group = ctg, xlabel = "Number of Cars at the Intersection", xrotation = 90.0, legendfont = Plots.font(18), ylabel = "Number of Intersections",
        title = title, bar_width = 0.67, 
        lw = 0, framestyle = :box)
 
end

dataframe = get_comparision_dataset(datapath,mapfile,sim_results,datafile,false);

get_grouped_hist(dataframe,20, "Overall Traffic Count")
get_grouped_hist(dataframe[dataframe[:count_type] .== "AADT",:],20, "Traffic Count - AADT Only")
get_grouped_hist(dataframe[dataframe[:count_type] .== "ADT",:],20, "Traffic Count - ADT Only")
get_grouped_hist(dataframe[dataframe[:count_type] .== "AWDT",:],20, "Traffic Count - AWDT Only")

p = histogram(dataframe[dataframe[:approximation_error] .< 2.45,:][:approximation_error], nbins = 25, title = "Distribution of Approximation Errors After Removing Outlying Points\n - Overall Traffic", legend = :none)
p1 = histogram(dataframe[(dataframe[:approximation_error] .< 2.45) .& (dataframe[:count_type] .== "AWDT"),:][:approximation_error], nbins = 25, title = "Distribution of Approximation Errors After Removing Outlying Points\n - AWDT Points Only", legend = :none)
p2 = histogram(dataframe[(dataframe[:approximation_error] .< 2.45) .& (dataframe[:count_type] .== "AADT"),:][:approximation_error], nbins = 25, title = "Distribution of Approximation Errors After Removing Outlying Points\n - AADT Points Only", legend = :none)
p3 = histogram(dataframe[(dataframe[:approximation_error] .< 2.45) .& (dataframe[:count_type] .== "ADT"),:][:approximation_error], nbins = 25, title = "Distribution of Approximation Errors After Removing Outlying Points\n - ADT Points Only", legend = :none)
plot(p,p1,p2,p3)