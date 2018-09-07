###################################
# Agent demographic profile generator
###################################

"""
Demographic profile generator

Creates socio-demographic profile of an agent based on demostats distributions per DA
    
**Arguments**
* `DA_home` : unique id of home location selected for an agent
* `demografic_categories` : dictionary with demografic categories used in genereting agent's profile
* `DA_demostat` : dictionary  with population statistics for specific DA
*

"""
function demographic_profile(DA_home::Int, DA_demostat::Dict{Symbol,Int};
							demografic_categories = OSMSim.demografic_categories)::DataFrames.DataFrame
    # age and gender
    categories = demografic_categories[:age_gender]
    weights = StatsBase.fweights(get.(Ref(DA_demostat), collect(keys(categories)), 0))
    gender_age = StatsBase.sample(collect(values(categories)), weights)
    gender, age = gender_age[1], rand(gender_age[2])
    # marital_status (household population aged 15+)
    categories = demografic_categories[:marital_status]
    weights = StatsBase.fweights(get.(Ref(DA_demostat), collect(keys(categories)), 0))
    marital_status = StatsBase.sample(collect(values(categories)), weights)
    # work_industry
    categories = demografic_categories[:work_industry]
    weights = StatsBase.fweights(get.(Ref(DA_demostat), collect(keys(categories)), 0))
    work_industry = StatsBase.sample(collect(values(categories)), weights)
    #household_income
    categories = demografic_categories[:household_income]
    weights = StatsBase.fweights(get.(Ref(DA_demostat), collect(keys(categories)), 0))
    household_income = rand(StatsBase.sample(collect(values(categories)), weights))
    #household_size
    categories = demografic_categories[:household_size]
    weights = StatsBase.fweights(get.(Ref(DA_demostat), collect(keys(categories)), 0))
    collect(values(categories))
    household_size = StatsBase.sample(collect(values(categories)), weights)
    #no_of_children
    categories = demografic_categories[:no_of_children]
    weights = StatsBase.fweights(get.(Ref(DA_demostat), collect(keys(categories)), 0))
    no_of_children = StatsBase.sample(collect(values(categories)), weights)
    no_of_children = min(no_of_children, max(0, household_size - 1 - marital_status))
    #children_age
    categories = demografic_categories[:children_age]
    weights = StatsBase.fweights(get.(Ref(DA_demostat), collect(keys(categories)), 0))
    children_age = no_of_children > 0 ? [rand(StatsBase.sample(collect(values(categories)), weights)) for i = 1: no_of_children] : Int64[]
    #immigrant
    categories = demografic_categories[:immigrant]
    weights = StatsBase.fweights(get.(Ref(DA_demostat), collect(keys(categories)), 0))
    immigrant = StatsBase.sample(collect(values(categories)), weights)
    if !immigrant
        immigrant_since = ""
        immigrant_region = ""
    else
        categories = demografic_categories[:immigrant_since]
        weights = StatsBase.fweights(get.(Ref(DA_demostat), collect(keys(categories)), 0))
        immigrant_since = StatsBase.sample(collect(values(categories)), weights)
        categories = demografic_categories[:immigrant_region]
        weights = StatsBase.fweights(get.(Ref(DA_demostat), collect(keys(categories)), 0))
        immigrant_region = StatsBase.sample(collect(values(categories)), weights)
    end
    return DataFrames.DataFrame(DA_home=DA_home, DA_work=0, 
                        gender=gender,age=age, marital_status=marital_status,
                        work_industry=work_industry, household_income=household_income, 
                        household_size=household_size,no_of_children=no_of_children,
                        children_age=[children_age], imigrant=immigrant, 
                        imigrant_since=immigrant_since, imigrant_region=immigrant_region)
end