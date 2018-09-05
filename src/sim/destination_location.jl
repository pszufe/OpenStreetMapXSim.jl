
###################################
# Destination location selectors
###################################

"""
Destination location selector based on DP (Demographic Profile)

Selects destination DA_work for an agent by randomly choosing the company he works in
    
**Arguments**
* `agent_profile` : agent demographic profile
* `business_data` : array with dictionaries  with business location, industry and estimated number of employees
* `industry` : dictionary matching industry demographic data from business_data with the ones selected 

**Assumptions based on agent demographic profile
- agents work in the business in accordance with their work_industry
- exact number of employess in businesses is estimated in each iteration based on "Number of employees" intervals
- differences between maximum number of employees and actual number of employees are used as a probability weights for each DA_work
"""
function destination_location!(agent_profile::DataFrames.DataFrame,
                            business_data::Array{Dict{Symbol,Union{String, Int,UnitRange{Int}}},1};
                            industry::Dict{String,Array{String,1}} = OSMSim.industry)
    indices  = findall((in)(Set(industry[agent_profile.work_industry[1]])),[ds[:ICLS_DESC] for ds in business_data])
    weights = StatsBase.fweights([maximum(business_data[i][:IEMP_DESC]) - business_data[i][:no_of_workers] for i in indices])
    index = StatsBase.sample(indices,weights)
    DA_work = business_data[index][:DA_ID]
    business_data[index][:no_of_workers] += 1
    agent_profile.DA_work[1] = DA_work
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
function destination_location!(agent_profile::DataFrames.DataFrame,
                                flow_dictionary::Dict{Int,Int},
                                flow_matrix::SparseMatrixCSC{Int,Int})
    row = flow_dictionary[agent_profile.DA_home[1]]
    column = StatsBase.sample(StatsBase.fweights(flow_matrix[row,:]))
    agent_profile.DA_work[1] = collect(keys(flow_dictionary))[something(findfirst(isequal(column), collect(values(flow_dictionary))),rand(1:length(flow_dictionary)))]
    return nothing
end

###################################
## Selection based on Both Journey Matrix and DP (Demographic Profile)

"""
Destination location selector based on both, JM (Jurney Matrix) and DP (Demographic Profile)

Selects destination DA_work for an agent choosing a proper industry and then by randomly weighted DAs with Pij Journey Matrix
    
**Arguments**
* `agent_profile` : agent demographic profile
* `sim_data ` :  simulation data with all important data 
* `industry` : dictionary matching industry demographic data from business_data with the ones selected 

**Assumptions based on agent demographic profile
- agents work in the business in accordance with their work_industry
- list of possible businesses is returned based on agent's work_industry
- then probability of selecting one of possible businesses is weighted by flows from DA_home to DA corresponding with each business
"""
function destination_location!(agent_profile::DataFrames.DataFrame,
                            sim_data::OSMSim.SimData;
                            industry::Dict{String,Array{String,1}} = OSMSim.industry)
    row = sim_data.DAs_flow_dictionary[agent_profile.DA_home[1]]
    indices  = findall((in)(Set(industry[agent_profile.work_industry[1]])), [ds[:ICLS_DESC] for ds in sim_data.business_data])
    columns = [sim_data.DAs_flow_dictionary[sim_data.business_data[index][:DA_ID]] for index in indices if haskey(sim_data.DAs_flow_dictionary,sim_data.business_data[index][:DA_ID])]
    weights = StatsBase.fweights([sim_data.DAs_flow_matrix[row,column] for column in columns])
    index = StatsBase.sample(indices,weights)
    DA_work = sim_data.business_data[index][:DA_ID]
    sim_data.business_data[index][:no_of_workers] += 1
    agent_profile.DA_work[1] = DA_work
    return nothing
end
    