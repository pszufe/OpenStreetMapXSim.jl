

# The recommended way to prallelize the simulation is to
# run the following bash command:
#seq 20 40 | xargs --max-args=1 --max-procs=4 julia sim_run.jl &>> runlog1.txt

#Parallelization for multiprocessing (optional)
#using Distributed
#w = 2
#Distributed.addprocs(w)
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
    datapath = "../datasetsos/";
    include(joinpath(path,"OSMSim.jl"))
    using Main.OSMSim
    sim_mode = "flows";
    version="002"
    resultspath="/home/ubuntu/results/"


    N = 100;
    max_jobs_worker=1
end

include("simparams/_loadparams.jl")
sim_data = get_sim_data(datapath);

OSMSim.run_dist_sim(resultspath,version,1,N,max_jobs_worker,sim_data, sim_mode,demographic_profile,additional_activity,nothing,s3action=nothing)
