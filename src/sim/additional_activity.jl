
###################################
# Additional activity selectors
###################################


###################################
# schools 


"""
Additional activity selector - schools

Checks if an agent has small children and drives them to school and if so, it returns the probability of driving children to school 
and dictionary with suitable school category (child care facility/pre school/school) for children of agent .

**Arguments**
* `agent_profile` : agent demographic profile::DemoProfile with city_region, children_number_of and children_age
* `school_probability`  : given probability of driving children to school 
* `school_category`  : dictionary mapping children age with school category

             
**Assumptions**
- kids in the same age go to the same school
- kids aged 0-3 go to Child Care Facility, kids aged 4-5 go to Pre School, kids aged 6-14 go to School
**To Do**
-connect the probability of driving children to school with agent demographic profile
"""

function get_school_probability(agent_profile::OSMSim.AgentProfile, 
                                school_probability::Float64, 
                                school_category::Dict{UnitRange{Int64},String})
    if agent_profile.no_of_children != 0
        occurences = Dict(key => sum(age in key for age in agent_profile.children_age) for key in keys(school_category))
        if sum(values(occurences)) == 0
            return 0, nothing
        else
            return school_probability, occurences
        end
    else
        return 0, nothing
    end
end

###################################
# recreation complexes 

"""
Additional activity selector - recreation complexes

Checks if an agent goes to the recreaton complex based on his demographic profile.
If he goes, a recreation complex is selected based on it's distance from home / work

**Arguments**
* `agent_profile` : agent demographic profile 
* `recreation_probabilities` : dictionary with probabilities for different agent demographic characteristics 
* `before` : boolean variable; true if agent is going to work, false otherwise 

             
**Assumptions**
- the probability of working out is calculated based on agent age, gender, income and whether agent is going to work or return from it. 
Younger, males and richer people work out more often.
**To Do**
-finding a better way to generate overall probability of going to recreation complex
"""

function get_recreation_probability(agent_profile::OSMSim.AgentProfile,
                                     recreation_probabilities::Dict{Symbol,Dict{Union{String,UnitRange{Int}},Float64}},
                                     before::Bool)
    probability = 1
    for key in keys(recreation_probabilities)
        if key == :when
            if before
                probability *= recreation_probabilities[key]["before"]
            else
                 probability *= recreation_probabilities[key]["after"]
            end
        else
            field_value = getfield(agent_profile,key)
            if typeof(field_value) == String
                probability *= recreation_probabilities[key][field_value]
            else
                range = filter(range -> (field_value in range), collect(keys(recreation_probabilities[key])))[1]
                probability *= recreation_probabilities[key][range]
            end
        end
    end
    return probability
end


###################################
# additional activity selector

"""
Additional activity selector

returns a category of additional activity choosen by agent.

**Arguments**   
* `agent_profile` : agent demographic profile
* `before` : boolean variable; true if agent is going to work, false otherwise 
* `school_probability`  : given probability of driving children to school 
* `school_category`  : dictionary mapping children age with school category
* `recreation_probabilities` : dictionary with probabilities for different agent demographic characteristics 
* `shopping_probabilities` : dictionary with probabilities for shopping in different types of stores 

 
** Assumptions
 - there is maximum one waypoint 
 -agents drive children to school only before work and does shopping only after work
 -probability of driving children to school is given as a variable, probability of recreation is calculated based on demographic profile of agent
 -probability of driving directly to work is calculated as a: 1 - (probability_of_driving_children_to_school + probability_of_recreation)
 -when agent is returning from work probabilities of shopping and driving directly are calculated as: (1 - probability_of_recreation) / 2
 -when agents is driving children to school a proper school category is chosen based on agent's children age
 -when agents is shopping a proper store category is chosen based on shopping_probabilities dictionary
"""
function additional_activity(agent_profile::AgentProfile, before::Bool, 
                            school_probability::Float64; 
                            school_category::Dict{UnitRange{Int64},String} = OSMSim.school_category,
                            recreation_probabilities::Dict{Symbol,Dict{Union{String,UnitRange{Int}},Float64}} = OSMSim.recreation_probabilities,
                            shopping_probabilities::Dict{String,Float64} = OSMSim.shopping_probabilities)
    activities = Dict{String,Float64}()
    school_weights = nothing 
    if before
        activities["school"], school_weights = OSMSim.get_school_probability(agent_profile, school_probability, school_category)
        activities["recreation"] = OSMSim.get_recreation_probability(agent_profile,recreation_probabilities, before)
        activities["directly"] =  1 - (activities["school"] + activities["recreation"])
        weights = StatsBase.pweights(collect(values(activities)))
        activity = StatsBase.sample(collect(keys(activities)), weights)
        if activity == "directly"
            return nothing 
        elseif activity == "recreation"
            return "recreation"
        else
            weights = StatsBase.fweights(collect(values(school_weights)))
            return school_category[StatsBase.sample(collect(keys(school_weights)), weights)]
        end
    else
        activities["recreation"] = OSMSim.get_recreation_probability(agent_profile,recreation_probabilities, before)
        activities["shopping"] = activities["directly"]  = (1 - activities["recreation"]) / 2
        weights = StatsBase.pweights(collect(values(activities)))
        activity = StatsBase.sample(collect(keys(activities)), weights)
        if activity == "directly"
            return nothing 
        elseif activity == "recreation"
            return "recreation"
        else
            weights = StatsBase.pweights(collect(values(shopping_probabilities)))
            return StatsBase.sample(collect(keys(shopping_probabilities)), weights)
        end
    end
end
