####################################
### Data preparation's functions ###
####################################


"""
The `colnames` dictionary is used to create the `SimData` object. The role of this dictionary is to ensure that the included files contains proper data.


* `:DAs` : a list of columns  in the csv file describing DAs:
    * `:DA_ID` : ID of a DA
    * `:LONGITUDE` : longitude of a DA's centroid
    * `:LATITUDE` : latitude of a DA's centroid

* `demo_stats` : a list of columns which must be included in the csv file with the demographic data used in simulation. **Warning:** Columns must be described in a separate 

* `:flows`  : a list of columns  in the csv file with the flows between DAs.
    * `:DA_home` : ID of start DA
    * `:DA_work` : ID of finish DA
    * `:Flow_Volume` : flow volume
"""
 const colnames = Dict(
 :DAs => [:DA_ID, :LONGITUDE, :LATITUDE],
 :flows  => [:DA_home, :DA_work, :FlowVolume]
 )

#get features
"""
Find the nearest node for every feature

**Arguments**
* `frame` : data frame with all features
* `nodes` : a list of nodes from .osm file
* `bounds` : map bounds
"""
function features_to_nodes(frame::DataFrames.DataFrame,
                            nodes::Dict{Int,OpenStreetMapX.ENU},
                            bounds::OpenStreetMapX.Bounds{OpenStreetMapX.LLA})
    coordinates = values(nodes)
    features = Dict{Int,Tuple{String,String}}()
    sizehint!(features,DataFrames.nrow(frame))
    for i = 1:DataFrames.nrow(frame)
        loc = OpenStreetMapX.ENU(OpenStreetMapX.LLA(frame[:LATITUDE][i], frame[:LONGITUDE][i]), OpenStreetMapX.center(bounds))
        if !OpenStreetMapX.inbounds(loc,OpenStreetMapX.ENU(bounds, OpenStreetMapX.center(bounds)))
            loc = OpenStreetMapX.boundary_point(loc, OpenStreetMapX.ENU(center(bounds), center(bounds)), OpenStreetMapX.ENU(bounds, center(bounds)))
        end
        node = OpenStreetMapX.add_new_node!(nodes,loc)
        features[node] = (frame[:CATEGORY][i], frame[:NAME][i])
    end
    return features
end

"""
Prepare features data objects.

**Arguments**
* `datapath` : path with osm file
* `mapfile` : a `map file name 
"""
function get_features_data(datapath::String, mapfile::String, map_data::OpenStreetMapX.MapData ;use_cache::Bool = true)
	cachefile = joinpath(datapath,"features.cache")
	if use_cache && isfile(cachefile)
		f=open(cachefile,"r");
		res=Serialization.deserialize(f);
		close(f);
		@info "Read features data from cache $cachefile"
	else
		mapdata = OpenStreetMapX.parseOSM(joinpath(datapath,mapfile))
		OpenStreetMapX.crop!(mapdata,crop_relations = false)
		feature_classes = Dict("amenity" => 3, "leisure" => 13,"shop" => 23, "tourism" => 25)
		features = OpenStreetMapX.filter_features(mapdata.features, levels = Set(values(feature_classes)))
		feature_to_intersections = OpenStreetMapX.features_to_graph(merge(OpenStreetMapX.ENU(mapdata.nodes,map_data.bounds),map_data.nodes), features, map_data.network)
		res = (features, feature_classes, feature_to_intersections)
		if use_cache
				f=open(cachefile,"w");
				Serialization.serialize(f,res);
				@info "Saved features data to cache $cachefile"
				close(f);
		end
	end
    return res
end

#finding closest network node for each DA
"""
Read a csv file with informations about DAs and then for each DA find the nearest route network node.

**Arguments**
* `datapath` : path with csv files
* `filename` : name of csv file
* `colnames` : an array of columns which must be included in each file
* `map_data` : a `OpenStreetMapX.MapData` object
"""
function DAs_to_nodes(datapath::String, filename::String,
                    colnames::Array{Symbol,1},
                    map_data::OpenStreetMapX.MapData)
    DAframe = Nanocsv.read_csv(joinpath(datapath,filename))
	  #DataFrame(CSVFiles.load(joinpath(datapath,filename)))
    if !all(in(col, DataFrames.names(DAframe)) for col in colnames)
        error("Wrong column names! Data Frame should contain $(String.(colnames).*" "... ) columns!")
    end
    DAs_to_nodes = Dict{Int,Int}()
    sizehint!(DAs_to_nodes,DataFrames.nrow(DAframe))
    for i = 1:DataFrames.nrow(DAframe)
        coords = OpenStreetMapX.ENU(OpenStreetMapX.LLA(DAframe[:LATITUDE][i], DAframe[:LONGITUDE][i]), OpenStreetMapX.center(map_data.bounds))
        DAs_to_nodes[DAframe[:DA_ID][i]] = OpenStreetMapX.nearest_node(map_data.nodes,coords,map_data.network)
    end
    return DAs_to_nodes
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

    if !all(in(col, DataFrames.names(flows)) for col in colnames)
        error("Wrong column names! Data Frame should contain $(String.(colnames).*" "... ) columns!")
    end
    flows = flows[colnames]
    vals = unique(vcat(flows[:DA_home],flows[:DA_work]))
    flow_dictionary =  Dict(vals[i] => i for i = 1:length(vals))
    flow_matrix = sparse([flow_dictionary[val] for  val in flows[:DA_home]],[flow_dictionary[val] for  val in flows[:DA_work]],flows[:FlowVolume])
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
* `road_levels` : a set with the road categories (see: OpenStreetMapX.ROAD_CLASSES for more informations)
* `google` : boolean variable; indicate whether google Distances API key will be included
"""
function get_sim_data(datapath::String;
                    road_levels::Set{Int} = Set(1:length(OpenStreetMapX.ROAD_CLASSES)),
					google::Bool = false)::OpenStreetMapXSim.SimData
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
    map_data = OpenStreetMapX.get_map_data(datapath, mapfile; road_levels = road_levels)
    @info "Got map_data( data [$(elapsed(startt))s]"
    features, feature_classes, feature_to_intersections = get_features_data(datapath, mapfile, map_data)
    @info "Got feature_to_intersections data [$(elapsed(startt))s]"
    DAs_data = filenames[:DAs]
    DAs_to_intersection = DAs_to_nodes(datapath, DAs_data, colnames[:DAs], map_data)
	demographic_data = Dict(key => nothing for key in keys(DAs_to_intersection))
    @info "Got DAs_to_nodes data [$(elapsed(startt))s]"
	flow_stats = filenames[:flows]
	flow_dictionary, flow_matrix = get_flow_data(datapath,flow_stats, colnames[:flows])
	@info "Got flow_matrix data [$(elapsed(startt))s]"
	googleapi_key = nothing
	if google
		if !haskey(filenames, :googleapi_key)
			error("Google API key not defined! Declare one or run simulation based on OSM Data only!")
		end
		apikey = filenames[:googleapi_key]
		googleapi_key = open(joinpath(datapath,apikey)) do file
			read(file, String)
		end
	end
	@info "All data have been read with total of $(length(map_data.nodes)) map nodes  [$(elapsed(startt))s]"
    return OpenStreetMapXSim.SimData(map_data,
					features, feature_classes,
                    feature_to_intersections,
                    DAs_to_intersection,
					demographic_data,
					nothing,
					flow_dictionary,
					flow_matrix,
					googleapi_key)

end
