#Reading OSM map file 

function read_map_file(datapath::String,filename::String; road_levels::Set{Int} = Set(1:length(OpenStreetMap.ROAD_CLASSES)))
    #preprocessing map file
    mapdata = OpenStreetMap.parseOSM(datapath*filename)
    OpenStreetMap.crop!(mapdata,cropRelations = false)
    #preparing data for simulation
    bounds = mapdata.bounds
    nodes = OpenStreetMap.ENU(mapdata.nodes,OpenStreetMap.center(bounds))
    highways = OpenStreetMap.filterHighways(OpenStreetMap.extractHighways(mapdata.ways))
    roadways = OpenStreetMap.filterRoadways(highways, levels= road_levels)
    intersections = OpenStreetMap.findIntersections(roadways)
    segments = OpenStreetMap.findSegments(nodes,roadways,intersections)
    network = OpenStreetMap.createGraph(segments,intersections,OpenStreetMap.classifyRoadways(roadways))
	#remove unuseful nodes
	roadways_nodes = unique(vcat(collect(way.nodes for way in roadways)...))
	nodes = Dict(key => nodes[key] for key in roadways_nodes)
    return (bounds,nodes,roadways,intersections,network)
end

#get features 

function read_features_data(datapath::String,
                            filenames::Array{String,1},
                            colnames::Array{Symbol,1}) 
    features_data = DataFrames.DataFrame()
    for filename in filenames
        frame = DataFrames.readtable(datapath*filename)
        if !all(in(col, DataFrames.names(frame)) for col in colnames)
            error("$(filename) has wrong column names! Data Frame should contain $(String.(colnames).*" "... )columns!")
        end
        frame = frame[colnames]
        features_data = vcat(features_data,frame)
    end
    return features_data
end

function features_to_nodes(frame::DataFrames.DataFrame,
                            nodes::Dict{Int,OpenStreetMap.ENU},
                            bounds::OpenStreetMap.Bounds{OpenStreetMap.LLA})
    coordinates = values(nodes)
    features = Dict{Int,Tuple{String,String}}()
    sizehint!(features,DataFrames.nrow(frame))
    for i = 1:DataFrames.nrow(frame)
        loc = OpenStreetMap.ENU(OpenStreetMap.LLA(frame[:LATITUDE][i], frame[:LONGITUDE][i]), OpenStreetMap.center(bounds))
        if !OpenStreetMap.inBounds(loc,OpenStreetMap.ENU(bounds, OpenStreetMap.center(bounds)))
            loc = OpenStreetMap.boundaryPoint(loc, OpenStreetMap.ENU(center(bounds), center(bounds)), OpenStreetMap.ENU(bounds, center(bounds)))
        end
        node = OpenStreetMap.addNewNode!(nodes,loc)
        features[node] = (frame[:CATEGORY][i], frame[:NAME][i])
    end
    return features
end

function get_features_data(datapath::String, filenames::Array{String,1},
                        colnames::Array{Symbol,1},
                        nodes::Dict{Int,OpenStreetMap.ENU},
                        network::OpenStreetMap.Network, 
                        bounds::OpenStreetMap.Bounds{OpenStreetMap.LLA})
    features_dataframe = OSMSim.read_features_data(datapath, filenames,colnames)
    features = OSMSim.features_to_nodes(features_dataframe,nodes,bounds)
    feature_classes = Dict{String,Int}(zip(unique(features_dataframe[:CATEGORY]) , Set(1:length(unique(features_dataframe[:CATEGORY])))))
    feature_to_intersections = OpenStreetMap.featuresToGraph(nodes,features, network)
    return features, feature_classes, feature_to_intersections
end

#finding closest network node for each DA

function DAs_to_nodes(datapath::String, filename::String,
                    colnames::Array{Symbol,1},
                    nodes::Dict{Int,OpenStreetMap.ENU},
                    network::OpenStreetMap.Network, 
                    bounds::OpenStreetMap.Bounds{OpenStreetMap.LLA})
    DAframe = DataFrames.readtable(datapath*filename)
    if !all(in(col, DataFrames.names(DAframe)) for col in colnames)
        error("Wrong column names! Data Frame should contain $(String.(colnames).*" "... ) columns!")
    end
    DAs_to_nodes = Dict{Int,Int}()
    sizehint!(DAs_to_nodes,DataFrames.nrow(DAframe))
    for i = 1:DataFrames.nrow(DAframe)
        coords = OpenStreetMap.ENU(OpenStreetMap.LLA(DAframe[:LATITUDE][i], DAframe[:LONGITUDE][i]), OpenStreetMap.center(bounds))
        DAs_to_nodes[DAframe[:DA_ID][i]] = OpenStreetMap.nearestNode(nodes,coords,network)
    end
    return DAs_to_nodes
end

#demographic and business data

function dataframe_to_dict(dataframe::DataFrames.DataFrame, id_col::Symbol)
    colnames = filter!(x->x != id_col,names(dataframe))
    dict = Dict{Int,Dict{Symbol,Int}}()
    for row = 1:nrow(dataframe)
        dict[dataframe[id_col][row]] = Dict{Symbol,Int}(cn => dataframe[row,cn] for cn in colnames)
    end
    return dict
end

function get_demographic_data(datapath::String, filename::String, colnames::Array{Symbol,1})::Dict{Int,Dict{Symbol,Int}}
    demostats = DataFrames.readtable(datapath*filename)
    if !all(in(col, DataFrames.names(demostats)) for col in colnames)
        error("Wrong column names! Data Frame should contain $(String.(colnames).*" "... ) columns!")
    end
    demostats = demostats[colnames]
    return OSMSim.dataframe_to_dict(demostats, :DA_ID)
end
 
function string_to_range(string::String)
    if uppercase(string) == "N/A" || string == ""
        return (0:0)
    else
        punct =[s for s in  collect(string) if ispunct(s)]
        numbers = split(replace.(string,[punct],"")[1])
        return (parse(Int,numbers[1]): parse(Int,numbers[2]))
    end
end
 
function get_business_data(datapath::String, filename::String, colnames::Array{Symbol,1})
    buss_stats = DataFrames.readtable(datapath*filename)
    if !all(in(col, DataFrames.names(buss_stats)) for col in colnames)
        error("Wrong column names! Data Frame should contain $(String.(colnames).*" "... ) columns!")
    end
    buss_stats = buss_stats[colnames]
	buss_stats[:IEMP_DESC] = [OSMSim.string_to_range(range) for range in buss_stats[:IEMP_DESC]]
	buss_stats[:no_of_workers] = 0
    business_array = Array{Dict{Symbol,Union{String, Int,UnitRange{Int}}},1}()
    sizehint!(business_array,DataFrames.nrow(buss_stats))
    for i = 1:DataFrames.nrow(buss_stats)
        business = Dict{Symbol,Union{String, Int,UnitRange{Int}}}(colname => buss_stats[colname][i] for colname in DataFrames.names(buss_stats))
        push!(business_array, business)
    end
    return business_array
end

function get_flow_data(datapath::String, filename::String, colnames::Array{Symbol,1})
    flows = DataFrames.readtable(datapath*filename)
    if !all(in(col, DataFrames.names(flows)) for col in colnames)
        error("Wrong column names! Data Frame should contain $(String.(colnames).*" "... ) columns!")
    end
    flows = flows[colnames]
    vals = unique(vcat(flows[:DA_I],flows[:DA_J]))
    flow_dictionary =  Dict(vals[i] => i for i = 1:length(vals))
    flow_matrix = sparse([flow_dictionary[val] for  val in flows[:DA_I]],[flow_dictionary[val] for  val in flows[:DA_J]],flows[:Flow_Volume])
    return flow_dictionary, flow_matrix
end

function get_sim_data(datapath::String;
                    filenames::Dict{Symbol,Union{String,Array{String,1}}} = OSMSim.file_names,
                    colnames::Dict{Symbol,Array{Symbol,1}} = OSMSim.colnames, 
                    road_levels::Set{Int} = Set(1:length(OpenStreetMap.ROAD_CLASSES)))::OSMSim.SimData
    files = collect(values(filenames))
    files = vcat(files...)
    if !all(in(file, readdir(datapath)) for file in files)
        error("file or files not in specified directory!")
    end
    mapfile = filenames[:osm]
    bounds,nodes,roadways,intersections,network = OSMSim.read_map_file(datapath, mapfile; road_levels = road_levels)
    features_data = filenames[:features]
    features, feature_classes, feature_to_intersections = OSMSim.get_features_data(datapath, features_data, colnames[:features], nodes,network,bounds)
    DAs_data = filenames[:DAs]
    DAs_to_intersection = OSMSim.DAs_to_nodes(datapath, DAs_data, colnames[:DAs], nodes,network, bounds)
    demo_stats = filenames[:demo_stats]
    demographic_data = OSMSim.get_demographic_data(datapath, demo_stats, colnames[:demo_stats])
	business_stats = filenames[:business_stats]
    business_data = OSMSim.get_business_data(datapath, business_stats, colnames[:business_stats])
	flow_stats = filenames[:flows]
	flow_dictionary, flow_matrix = OSMSim.get_flow_data(datapath,flow_stats, colnames[:flows])
    return OSMSim.SimData(bounds, nodes,
                    roadways, intersections,
                    network,features, feature_classes, 
                    feature_to_intersections, 
                    DAs_to_intersection,
					demographic_data,
					business_data,
					flow_dictionary, 
					flow_matrix) 
end