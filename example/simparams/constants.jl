"""
Names of datasets and other objects used in simulation:

**Keys**
* `:osm` : an open street map object **(mandatory)**
* `:features` : an array of csv file names with informations about all the features (points representing crucial objects, like schools, recreation areas, shops locations, etc.) used in simulation **(mandatory)**
* `:flows` : csv file with informations about flows from each DA to another
* `:DAs` : csv file with centroids coordinates of every DA **(mandatory)**
* `:demo_stats` : csv file with demographic data of every DA **(mandatory)**
* `:googleapi_key` : a string containg unique *Google Distances API* key
"""
const filenames = Dict{Symbol,Union{String,Array{String,1}}}(:osm => "Winnipeg CMA.osm",
:flows =>"hw_flows.csv",
:DAs => "df_DA_centroids.csv",
:googleapi_key => "googleapi.key"
)

"""
A dictionary of dictionaries structuring the way how the demographic data will influence the demographic profile of agents in simulation. It is based on the mandatory `:demo_stats` data frame which is containing an informations about socio-demographic structure of each DA.

"""
const demographic_categories = Dict(
    :gender => Dict(
    :male => "Male",
    :female => "Female"
    ),
    
    :age => Dict(
    :age20to29 => (20:29), #"Household Population by Age - 20 To 29",
    :age30to39 => (30:39), #"Household Population by Age - 30 To 39",
    :age40to49 => (40:49), #"Household Population by Age - 40 To 49",
    :age50to59 => (50:59), #"Household Population by Age - 50 To 59",
    :age60to69 => (60:69), #"Household Population by Age - 60 To 69",
    ),
    
    :marital_status => Dict(
    :married  => "Married",  
    :unmarried => "Unmarried" 
    ),
    
    :household_income => Dict(
    :income_19999_or_less => (0:19999),        #"Income - 19,999 Or Less",
    :income_20000_to_39999 => (20000:39999),   #"Income - 20,000 To 39,999",
    :income_40000_to_59999 => (40000:49999),   #"Income - 40,000 To 59,999",
    :income_60000_to_79999 => (60000:79999),   #"Income - 60,000 To 79,999",
    :income_80000_to_99999 => (80000:99999),   #"Income - 80,000 To 99,999",
    :income_80000_to_124999 => (100000:124999), #"Income - 100,000 To 124,999",
    :income_125000_to_149999 => (125000:149999), #"Income - 125,000 To 149,999",
    :income_150000_to_174999 => (150000:174999), #"Income - 150,000 To 174,999",
    :income_175000_to_199999 => (175000:199999), #"Income - 175,000 To 199,999",
    :income_200000_to_249999 => (200000:249999), #"Income - 200,000 To 249,999",
    :income_250000_or_over => (250000:1000000) #"Income - 250,000 Or Over",
    ),
    
    :no_of_children => Dict(
    :nochildren => 0,
    :onechild  => 1, 
    :twochildren  => 2, 
    :threechildrem  => 3, 
    ),
    
)
