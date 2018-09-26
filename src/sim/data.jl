####################################
### Data preparation's functions ###
####################################


"""
The `colnames` dictionary is used to create the `SimData` object. The role of this dictionary is to ensure that the included files contains proper data.


* `:features` : a list of columns in the csv file (or files) with the informations about the features:
    * `:CATEGORY` : a category of a feature (e.g. primary school, recreation complex, shopping centre)
    * `:NAME` : name of a feature
    * `:LONGITUDE`: longitude of a feature location
    * `:LATITUDE`: latitude of a feature location

* `:DAs` : a list of columns  in the csv file describing DAs:
    * `:DA_ID` : ID of a DA
    * `:LONGITUDE` : longitude of a DA's centroid
    * `:LATITUDE` : latitude of a DA's centroid

* `demo_stats` : a list of columns which must be included in the csv file with the demographic data used in simulation. **Warning:** Columns must be described in a separate `demografic_categories` dictionary.

* `:business_stats` : a list of columns in the csv file with the business data used in simulation.
    * `:ICLS_DESC` : name of industry of each company
    * `:DA_ID` : ID of a DA where company is located
    * `:IEMP_DESC` : number of employees intervals, stored as a string, e.g. "1:4"

* `:flows`  : a list of columns  in the csv file with the flows between DAs.
    * `:DA_I` : ID of start DA
    * `:DA_J` : ID of finish DA
    * `:Flow_Volume` : flow volume
"""
 const colnames = Dict(
 :features => [:CATEGORY, :NAME, :LONGITUDE, :LATITUDE],
 :DAs => [:DA_ID, :LONGITUDE, :LATITUDE],
 :demo_stats => vcat([collect(keys(value)) for (key,value) in demografic_categories]...,),
 :business_stats => [:ICLS_DESC, :DA_ID , :IEMP_DESC],
 :flows  => [:DA_I, :DA_J, :Flow_Volume]
 )


"""
Parse .osm file and create the road network based on the map data.

**Arguments**
* `datapath` : path with an .osm file
* `filename` : name of .osm file
* `road_levels` : a set with the road categories (see: OpenStreetMap.ROAD_CLASSES for more informations)
"""
function read_map_file(datapath::String,filename::String; road_levels::Set{Int} = Set(1:length(OpenStreetMap.ROAD_CLASSES)))
    #preprocessing map file
	cachefile = joinpath(datapath,filename*".cache")
	if isfile(cachefile)
		f=open(cachefile,"r");
		res=Serialization.deserialize(f);
		close(f);
		@info "Read map data from cache $cachefile"
	else
		mapdata = OpenStreetMap.parseOSM(joinpath(datapath,filename))
		OpenStreetMap.crop!(mapdata,crop_relations = false)
		#preparing data for simulation
		bounds = mapdata.bounds
		nodes = OpenStreetMap.ENU(mapdata.nodes,OpenStreetMap.center(bounds))
		highways = OpenStreetMap.filter_highways(OpenStreetMap.extract_highways(mapdata.ways))
		roadways = OpenStreetMap.filter_roadways(highways, levels= road_levels)
		intersections = OpenStreetMap.find_intersections(roadways)
		segments = OpenStreetMap.find_segments(nodes,roadways,intersections)
		network = OpenStreetMap.create_graph(segments,intersections,OpenStreetMap.classify_roadways(roadways))
		#remove unuseful nodes
		roadways_nodes = unique(vcat(collect(way.nodes for way in roadways)...))
		nodes = Dict(key => nodes[key] for key in roadways_nodes)
		res = (bounds,nodes,roadways,intersections,network)
		f=open(cachefile,"w");
		Serialization.serialize(f,res);
		@info "Saved map data to cache $cachefile"
		close(f);
	end

    return res
end

#get features
"""
Read csv files with informations about features and create a joint data frame.

**Arguments**
* `datapath` : path with csv files
* `filename` : names of csv files
* `colnames` : an array of columns which must be included in each file
"""
function read_features_data(datapath::String,
                            filenames::Array{String,1},
                            colnames::Array{Symbol,1})
    features_data = DataFrames.DataFrame[]
    for filename in filenames
        frame = Nanocsv.read_csv(joinpath(datapath,filename))
		   #DataFrame(CSVFiles.load(joinpath(datapath,filename)))
        if !all(in(col, DataFrames.names(frame)) for col in colnames)
            error("$(filename) has wrong column names! Data Frame should contain $(String.(colnames).*" "... )columns!")
        end
        frame = frame[colnames]
        push!(features_data,frame)
    end
    return vcat(features_data...)
end

"""
Find the nearest node for every feature

**Arguments**
* `frame` : data frame with all features
* `nodes` : a list of nodes from .osm file
* `bounds` : map bounds
"""
function features_to_nodes(frame::DataFrames.DataFrame,
                            nodes::Dict{Int,OpenStreetMap.ENU},
                            bounds::OpenStreetMap.Bounds{OpenStreetMap.LLA})
    coordinates = values(nodes)
    features = Dict{Int,Tuple{String,String}}()
    sizehint!(features,DataFrames.nrow(frame))
    for i = 1:DataFrames.nrow(frame)
        loc = OpenStreetMap.ENU(OpenStreetMap.LLA(frame[:LATITUDE][i], frame[:LONGITUDE][i]), OpenStreetMap.center(bounds))
        if !OpenStreetMap.inbounds(loc,OpenStreetMap.ENU(bounds, OpenStreetMap.center(bounds)))
            loc = OpenStreetMap.boundary_point(loc, OpenStreetMap.ENU(center(bounds), center(bounds)), OpenStreetMap.ENU(bounds, center(bounds)))
        end
        node = OpenStreetMap.add_new_node!(nodes,loc)
        features[node] = (frame[:CATEGORY][i], frame[:NAME][i])
    end
    return features
end

"""
Prepare features data objects.

**Arguments**
* `datapath` : path with csv files
* `filenames` : names of csv files
* `colnames` : an array of columns which must be included in each file
* `nodes` : a list of nodes from .osm file
* `network` : route network graph.
* `bounds` : map bounds
"""
function get_features_data(datapath::String, filenames::Array{String,1},
                        colnames::Array{Symbol,1},
                        nodes::Dict{Int,OpenStreetMap.ENU},
                        network::OpenStreetMap.Network,
                        bounds::OpenStreetMap.Bounds{OpenStreetMap.LLA})
    features_dataframe = OSMSim.read_features_data(datapath, filenames,colnames)
    features = OSMSim.features_to_nodes(features_dataframe,nodes,bounds)
    feature_classes = Dict{String,Int}(zip(unique(features_dataframe[:CATEGORY]) , Set(1:length(unique(features_dataframe[:CATEGORY])))))
    feature_to_intersections = OpenStreetMap.features_to_graph(nodes,features, network)
    return features, feature_classes, feature_to_intersections
end

#finding closest network node for each DA
"""
Read a csv file with informations about DAs and then for each DA find the nearest route network node.

**Arguments**
* `datapath` : path with csv files
* `filename` : name of csv file
* `colnames` : an array of columns which must be included in each file
* `nodes` : a list of nodes from .osm file
* `network` : route network graph.
* `bounds` : map bounds
"""
function DAs_to_nodes(datapath::String, filename::String,
                    colnames::Array{Symbol,1},
                    nodes::Dict{Int,OpenStreetMap.ENU},
                    network::OpenStreetMap.Network,
                    bounds::OpenStreetMap.Bounds{OpenStreetMap.LLA})
    DAframe = Nanocsv.read_csv(joinpath(datapath,filename))
	  #DataFrame(CSVFiles.load(joinpath(datapath,filename)))
    if !all(in(col, DataFrames.names(DAframe)) for col in colnames)
        error("Wrong column names! Data Frame should contain $(String.(colnames).*" "... ) columns!")
    end
    DAs_to_nodes = Dict{Int,Int}()
    sizehint!(DAs_to_nodes,DataFrames.nrow(DAframe))
    for i = 1:DataFrames.nrow(DAframe)
        coords = OpenStreetMap.ENU(OpenStreetMap.LLA(DAframe[:LATITUDE][i], DAframe[:LONGITUDE][i]), OpenStreetMap.center(bounds))
        DAs_to_nodes[DAframe[:DA_ID][i]] = OpenStreetMap.nearest_node(nodes,coords,network)
    end
    return DAs_to_nodes
end


"""
Convert data frame to dictionary

**Arguments**
* `dataframe` : DataFrames.DataFrame object
* `id_col` : id of the data frame column used as the keys of dictionary
"""
function dataframe_to_dict(dataframe::DataFrames.DataFrame, id_col::Symbol)
    colnames = filter!(x->x != id_col,names(dataframe))
    dict = Dict{Int,Dict{Symbol,Int}}()
    for row = 1:nrow(dataframe)
        dict[dataframe[id_col][row]] = Dict{Symbol,Int}(cn => dataframe[row,cn] for cn in colnames)
    end
    return dict
end

"""
Include demographic data

**Arguments**
* `datapath` : path with csv files
* `filename` : name of csv file
* `colnames` : an array of columns which must be included in each file
"""
function get_demographic_data(datapath::String, filename::String, colnames::Array{Symbol,1})::Dict{Int,Dict{Symbol,Int}}

    demostats = Nanocsv.read_csv(joinpath(datapath,filename))
	    #DataFrame(CSVFiles.load(joinpath(datapath,filename)))
    dfcolnames = names(demostats)
    for col in colnames
        in(col, dfcolnames) || error("Wrong column names! DataFrame demostats does not contain $col")
    end
    demostats = demostats[colnames]
    return OSMSim.dataframe_to_dict(demostats, :DA_ID)
end

"""
Extract numeric values from a string_to_range

**Arguments**
* `string` : string
"""
extract_numbers(string::AbstractString) = join(s for s in collect(string) if isnumeric(s))

"""
Convert strings to ranges

**Arguments**
* `string` : string
"""
function string_to_range(string::AbstractString)
    if uppercase(string) == "N/A" || string == ""
        return (0:0)
    else
        elements = split(string)
		numbers = [OSMSim.extract_numbers(element) for element in elements if !isempty(OSMSim.extract_numbers(element))]
        return (parse(Int,numbers[1]): parse(Int,numbers[2]))
    end
end

"""
Include and process data about businesses

**Arguments**
* `datapath` : path with csv files
* `filename` : name of csv file
* `colnames` : an array of columns which must be included in each file
"""
function get_business_data(datapath::String, filename::String, colnames::Array{Symbol,1})
    buss_stats = Nanocsv.read_csv(joinpath(datapath,filename))
	   #DataFrame(CSVFiles.load(joinpath(datapath,filename)))
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

"""
Include csv file with flow data and create a flow matrix

**Arguments**
* `datapath` : path with csv files
* `filename` : name of csv file
* `colnames` : an array of columns which must be included in each file
"""
function get_flow_data(datapath::String, filename::String, colnames::Array{Symbol,1})
    flows = Nanocsv.read_csv(joinpath(datapath,filename))
	  #DataFrame(CSVFiles.load(joinpath(datapath,filename)))

    if !all(in(col, DataFrames.names(flows)) for col in colnames)
        error("Wrong column names! Data Frame should contain $(String.(colnames).*" "... ) columns!")
    end
    flows = flows[colnames]
    vals = unique(vcat(flows[:DA_I],flows[:DA_J]))
    flow_dictionary =  Dict(vals[i] => i for i = 1:length(vals))
    flow_matrix = sparse([flow_dictionary[val] for  val in flows[:DA_I]],[flow_dictionary[val] for  val in flows[:DA_J]],flows[:Flow_Volume])
    return flow_dictionary, flow_matrix
end

function elapsed(startt::Dates.DateTime)::Int
    Int(round((Dates.now()-startt).value/1000))
end

"""
Read data files and create a `SimData` object

**Arguments**
* `datapath` : path with csv files
* `filename` : name of csv file
* `colnames` : an array of columns which must be included in each file
* `road_levels` : a set with the road categories (see: OpenStreetMap.ROAD_CLASSES for more informations)
* `google` : boolean variable; indicate whether google Distances API key will be included
"""
function get_sim_data(datapath::String;
                    filenames::Dict{Symbol,Union{String,Array{String,1}}} = OSMSim.file_names,
                    colnames::Dict{Symbol,Array{Symbol,1}} = OSMSim.colnames,
                    road_levels::Set{Int} = Set(1:length(OpenStreetMap.ROAD_CLASSES)),
					google::Bool = false)::OSMSim.SimData
    startt = Dates.now()
    files = collect(values(filenames))
    files = vcat(files...)
	files_in_dir = Set(readdir(datapath))
	found_error = false
	for filename in files
		check = filename != filenames[:googleapi_key] || (filename == filenames[:googleapi_key] && google)
		if !in(filename, files_in_dir) && check
			@error "The file $filename is missing in the directory $datapath"
			found_error = true
		end
	end
	found_error && error("Some file(s) not found in $datapath")
    @info "All config files found [$(elapsed(startt))s]"
    mapfile = filenames[:osm]
    bounds,nodes,roadways,intersections,network = OSMSim.read_map_file(datapath, mapfile; road_levels = road_levels)
    @info "Got read_map_file data [$(elapsed(startt))s]"
    demo_stats = filenames[:demo_stats]
    demographic_data = OSMSim.get_demographic_data(datapath, demo_stats, colnames[:demo_stats])
    @info "Got demo_stats data [$(elapsed(startt))s]"
    features_data = filenames[:features]
    features, feature_classes, feature_to_intersections = OSMSim.get_features_data(datapath, features_data, colnames[:features], nodes,network,bounds)
    @info "Got feature_to_intersections data [$(elapsed(startt))s]"
    DAs_data = filenames[:DAs]
    DAs_to_intersection = OSMSim.DAs_to_nodes(datapath, DAs_data, colnames[:DAs], nodes,network, bounds)
    @info "Got DAs_to_nodes data [$(elapsed(startt))s]"
	business_stats = filenames[:business_stats]
    business_data = OSMSim.get_business_data(datapath, business_stats, colnames[:business_stats])
    @info "Got business_stats data [$(elapsed(startt))s]"
	flow_stats = filenames[:flows]
	flow_dictionary, flow_matrix = OSMSim.get_flow_data(datapath,flow_stats, colnames[:flows])
	@info "Got flow_matrix data [$(elapsed(startt))s]"
	googleapi_key = nothing
	if google
		if !haskey(filenames, :googleapi_key)
			error("Google API key not defined! Declare one or run simulation based on OSM Data only!")
		end
		apikey = filenames[:googleapi_key]
		googleapi_key = open(datapath*apikey) do file
			read(file, String)
		end
	end
	@info "All data have been read with total of $(length(nodes)) map nodes  [$(elapsed(startt))s]"
    return OSMSim.SimData(bounds, nodes,
                    roadways, intersections,
                    network,features, feature_classes,
                    feature_to_intersections,
                    DAs_to_intersection,
					demographic_data,
					business_data,
					flow_dictionary,
					flow_matrix,
					googleapi_key)

end
