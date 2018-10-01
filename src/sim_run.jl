#

using Distributed
#w = 2
#Distributed.addprocs(w)

#seq 20 40 | xargs --max-args=1 --max-procs=4 julia sim_run.jl &>> runlog1.txt

#@everywhere begin
begin
    using Random
    using Dates
    using Distributed
    using Printf
    using Nanocsv
    using OpenStreetMapX
    using DataFrames
    path = "sim/";
    datapath = "../datasets/";
    include(joinpath(path,"OSMSim.jl"))
    using Main.OSMSim
    sim_mode = "flows";
    version="002"
    resultspath="/home/ubuntu/results/"

    function s3copy(filepath,filename)
        s3path="s3://eag-ca-bucket-1/SimResults/gz"
        cmd = `gzip $(joinpath(filepath,filename))`
        res = read(cmd,String)
        cmd = `aws s3 --region ca-central-1 cp $(joinpath(filepath,filename)).gz $(s3path)/$(version)/$(filename).gz`
        res = read(cmd,String)
        @info "S3 $(filename): $(res)"
    end
    N = 100;
    max_jobs_worker=1
end

include("simparamswinni/_loadparams.jl")
sim_data = get_sim_data(datapath);

#nodes, buffer,routes = run_simulation(sim_data, mode, 1, 3,demographic_profile,additional_activity,weight_var);

OSMSim.run_dist_sim(resultspath,version,1,N,max_jobs_worker,sim_data, sim_mode,demographic_profile,additional_activity,weight_var,s3action=nothing)
