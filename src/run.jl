######################
### Run simulation ###
######################

"""
Run one simulation iteration

**Arguments**
* `sim_data` : `SimData` object
* `buffer` : list of `OpenStreetMapXSim.Road` objects containing informations about routes selected during the simulation run.
* `nodes_stats` : dictionary of `OpenStreetMapXSim.NodeStat` objects containing informations about each intersection in simulation.
* `destination_selector` : string determining a way how the destination (workplace) will be selected (based on journey matrix, business data or on both)
* `weight_var` : weighting variable name (or nothing)
* `google` : boolean variable; if true simulation will generates routes based on Google Distances API
"""
function run_once!(sim_data::OpenStreetMapXSim.SimData,
                            buffer::Array{OpenStreetMapXSim.Road,1},
                            nodes_stats::Dict{Int,OpenStreetMapXSim.NodeStat},
                            destination_selector::String,
							agentid::Int,demographic_profile::Function,
							additional_activity::Function;
							weight_var:: Union{Symbol,Nothing} = nothing,
							google::Bool = false
							)
    loc = OpenStreetMapXSim.start_location(sim_data.demographic_data, weight_var = weight_var)
    agent = demographic_profile(loc, sim_data.demographic_data[loc])
    agent[:id]=agentid
    if destination_selector == "flows"
        OpenStreetMapXSim.destination_location!(agent,sim_data.DAs_flow_dictionary,sim_data.DAs_flow_matrix)
    elseif destination_selector == "business"
        OpenStreetMapXSim.destination_location!(agent,sim_data.business_data)
	else
		OpenStreetMapXSim.destination_location!(agent,sim_data)
    end
    #before work
    activity = additional_activity(agent,true,sim_data)
    if isa(activity,Nothing)
        routebefore = OpenStreetMapXSim.select_route(agent.DA_home[1], agent.DA_work[1],sim_data, buffer, google = google)
    else
        routebefore = OpenStreetMapXSim.select_route(agent.DA_home[1], agent.DA_work[1], activity,sim_data, buffer,google = google)
    end
    OpenStreetMapXSim.stats_aggregator!(nodes_stats, agent, routebefore)
    local routeafter
    #after work
    activity = additional_activity(agent,false,sim_data)
    if isa(activity,Nothing)
        routeafter = OpenStreetMapXSim.select_route(agent.DA_work[1], agent.DA_home[1], sim_data, buffer,google = google)
    else
        routeafter = OpenStreetMapXSim.select_route(agent.DA_work[1], agent.DA_home[1], activity, sim_data, buffer,google = google)
    end
    OpenStreetMapXSim.stats_aggregator!(nodes_stats, agent, routeafter)
    return (routebefore,routeafter)
end

"""
Run simulation

Run simulation for data stored in `SimData` object

**Arguments**
* `sim_data` : `SimData` object
* `destination_selector` : string determining a way how the destination (workplace) will be selected (based on journey matrix, business data or on both)
* `N` : number of iterations
* `demographic_profile` : function generating a demographic profile on the base of DA_home and DA_demostat
* `additional_activity` : function generating an additional_activity on the base agents profile and direction
* `weight_var` : weighting variable name (or nothing)
* `google` : boolean variable; if true simulation will generates routes based on Google Distances API
"""
function run_simulation(sim_data::OpenStreetMapXSim.SimData,
            destination_selector::String,
			job::Int,
            N::Int,
			demographic_profile::Function,
			additional_activity::Function,
			weight_var::Union{Symbol,Nothing};
			google::Bool = false)
	if !in(destination_selector,["flows","business","both"])
		error("destination_selector not declared properly! It can only takes flows, business or both values!")
	end
    nodes_stats = OpenStreetMapXSim.node_statistics(sim_data)
    buffer = Array{OpenStreetMapXSim.Road,1}()
    routes = Dict()
	startt = Dates.now()
	@info "Worker $(myid()) Starting simulation for seed $job at $startt"
    Random.seed!(job);
    for i = 1:N
        agentid = (job*1000000) + i
        routes[agentid] = OpenStreetMapXSim.run_once!(sim_data,buffer,nodes_stats,destination_selector,agentid,demographic_profile,additional_activity, weight_var = weight_var, google = google)
		i == 1 && @info "Worker: $(Distributed.myid()) First out of $N simulation completed"
    end
    #$(Distributed.myid())
	@info "Worker: $(Distributed.myid()) All $N sims completed with time per sim = $((Dates.now()-startt).value/N)ms"
    return nodes_stats,buffer,routes
end




function run_dist_sim(resultspath,version::String,master_ID::Int,N::Int,max_jobs_worker::Int,
					  sim_data::OpenStreetMapXSim.SimData, mode::String,
					  demographic_profile,additional_activity,weight_var;
					  s3action::Union{Function,Nothing}=nothing)
	for ii in 1:max_jobs_worker
	    d = master_ID*max_jobs_worker+ii;
	    nodes, buffer,routes = run_simulation(sim_data, mode, d, N,
		        demographic_profile,additional_activity,weight_var);

		# add nodeids and distributed.myid to nodes statistics
		nodeids = collect(keys(nodes));
		for i in nodeids
			if nodes[i].agents_data != nothing
				insert!(nodes[i].agents_data, 1, nodes[i].latitude, :latitude)
				insert!(nodes[i].agents_data, 1, nodes[i].longitude, :longitude)
				insert!(nodes[i].agents_data, 1, i, :NODE_ID)
				insert!(nodes[i].agents_data, 1, Distributed.myid(), :DISTRIBUTED_ID)
			else
				delete!(nodes, i)
			end
		end

	    # merge results
		results = collect(values(nodes))[1].agents_data
		for df in collect(values(nodes))[2:end]
	       append!(results, df.agents_data)
	    end
	    filenamebase="res_V$(version)_M$(mode)_W$(@sprintf("%04d", Distributed.myid()))_S$(@sprintf("%05d",d))"
	    filenodes  = "$(filenamebase)_nodes.csv"
	    targetfile=joinpath(resultspath,filenodes)
		Nanocsv.write_csv(targetfile,results, delim = ';')
		s3action != nothing && s3action(resultspath, filenodes)
	    fileroutes = "$(filenamebase)_routes.csv"
	    f = open(joinpath(resultspath, fileroutes),"w")
	    for agentid in keys(routes)
	        mode = "towork"
	        for rset in routes[agentid]
	            print(f,"$(agentid);$(mode)")
	            for nn in rset
	               print(f,";$nn")
	            end
	            println(f,"")
	            mode = "tohome"
	        end
	    end
	    close(f)
	    s3action != nothing && s3action(resultspath, fileroutes)
		@info "Results exported for worker $(myid()) seed $d to: $targetfile"
	    #1
	end
end
