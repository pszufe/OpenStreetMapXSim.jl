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
    return (bounds,nodes,roadways,intersections,network)
end

function read_features_data(datapath::String, filenames::Array{String,1})
    colnames = [:CATEGORY, :NAME, :LONGITUDE, :LATITUDE]
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
                        nodes::Dict{Int,OpenStreetMap.ENU},
                        network::OpenStreetMap.Network, 
                        bounds::OpenStreetMap.Bounds{OpenStreetMap.LLA})
    features_dataframe = read_features_data(datapath, filenames)
    features = features_to_nodes(features_dataframe,nodes,bounds)
    feature_classes = Dict{String,Int}(zip(unique(features_dataframe[:CATEGORY]) , Set(1:length(unique(features_dataframe[:CATEGORY])))))
    feature_to_intersections = OpenStreetMap.featuresToGraph(nodes,features, network)
    return features, feature_classes, feature_to_intersections
end

function DAs_to_nodes(datapath::String, filename::String,
                    nodes::Dict{Int,OpenStreetMap.ENU},
                    network::OpenStreetMap.Network, 
                    bounds::OpenStreetMap.Bounds{OpenStreetMap.LLA})
    DAframe = DataFrames.readtable(datapath*filename)
    colnames = [:DA_ID, :LONGITUDE, :LATITUDE]
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

function get_sim_data(datapath::String,filenames::Dict{Symbol,Union{String,Array{String,1}}}; road_levels::Set{Int} = Set(1:length(OpenStreetMap.ROAD_CLASSES)))::SimData
    files = collect(values(filenames))
    files = vcat(files...)
    if !all(in(file, readdir(datapath)) for file in files)
        error("file or files not in specified directory!")
    end
    mapfile = filenames[:osm]
    bounds,nodes,roadways,intersections,network = read_map_file(datapath,mapfile; road_levels = road_levels)
    features_data = filenames[:features]
    features, feature_classes, feature_to_intersections = get_features_data(datapath, features_data,nodes,network,bounds)
    DAs_data = filenames[:DAs]
    DAs_to_intersection = DAs_to_nodes(datapath, DAs_data, nodes,network, bounds)
    datasets = filenames[:stats]
    return SimData(bounds, nodes,
                    roadways, intersections,
                    network,features, feature_classes, 
                    feature_to_intersections, 
                    DAs_to_intersection) 
end
