
###################################
# Destination location selectors
###################################

"""
Destination location selector based on DP (Demographic Profile)

Selects destination DA_work for an agent by randomly choosing the company he works in
    
**Arguments**
* `agent_profile` : agent demographic profile
* `business_data` : dictionary  with business location, industry and estimated number of employees
* `industry` : dictionary matching industry demographic data from business_data with the ones selected 

**Assumptions based on agent demographic profile
- agents work in the business in accordance with their work_industry
- exact number of employess in businesses is estimated in each iteration based on "Number of employees" intervals and cannot exceed the maximum of this interval
"""

function destination_location!(agent_profile::OSMSim.AgentProfile,
                            business_data::Dict{Int64,Dict{Symbol,Union{Int64, String, UnitRange{Int64}}}};
                            industry::Dict{String,Array{String,1}} = OSMSim.industry)
    index  = findin([ds[:ICLS_DESC] for ds in collect(values(business_data))], Set(industry[agent_profile.work_industry]))
    DA_work = collect(keys(business_data))[rand(index)]
    if business_data[DA_work][:no_of_workers] + 1 > maximum(business_data[DA_work][:IEMP_DESC])
        OSMSim.destination_location!(agent_profile,business_data,industry)
    else
        business_data[DA_work][:no_of_workers] += 1
        agent_profile.DA_work = DA_work
    end
    return nothing 
end

###################################
## Selection based on Journey Matrix 

"""
Destination location selector based on JM (Jurney Matrix)

Selects destination DA_work for an agent randomly weighted by Pij Journey Matrix
    
**Arguments**
* `agent_profile` : agent demographic profile
* `flow_dictionary ` :  Dictionary mapping Pij Journey Matrix columns to DAs
* `flow_matrix ` :  Pij Journey Matrix with *FlowVolume* from *DA_home* to *DA_work*
"""

function destination_location!(agent_profile::OSMSim.AgentProfile,
                                flow_dictionary::Dict{Int,Int},
                                flow_matrix::SparseMatrixCSC{Int,Int})
    row = flow_dictionary[agent_profile.DA_home]
    column = StatsBase.sample(StatsBase.fweights(flow_matrix[row,:]))
    agent_profile.DA_work = collect(keys(flow_dictionary))[findfirst(collect(values(flow_dictionary)), column)]
    return nothing
end