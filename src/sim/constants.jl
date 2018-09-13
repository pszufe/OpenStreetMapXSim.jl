"""
Names of datasets and other objects used in simulation:

**Keys**
* `:osm` : an open street map object **(mandatory)**
* `:features` : an array of csv file names with informations about all the features (points representing crucial objects, like schools, recreation areas, shops locations, etc.) used in simulation **(mandatory)** 
* `:flows` : csv file with informations about flows from each DA to another
* `:DAs` : csv file with centroids coordinates of every DA **(mandatory)** 
* `:demo_stats` : csv file with demographic data of every DA **(mandatory)** 
* `:business_stats` : csv file with data about workplaces in simulation's area (its localisation, industry, number of workers)
* `:googleapi_key` : a string containg unique *Google Distances API* key
"""
const file_names = Dict{Symbol,Union{String,Array{String,1}}}(:osm => "Winnipeg CMA.osm",
:features => [ "df_popstores.csv",
  "df_schools.csv",
  "df_recreationComplex.csv",
  "df_shopping.csv",],
:flows =>"df_hwflows.csv",
:DAs => "df_DA_centroids.csv",
:demo_stats => "df_demostat.csv",
:business_stats => "df_business.csv",
:googleapi_key => "googleapi.key"
)
 
"""
A dictionary of dictionaries structuring the way how the demographic data will influence the demographic profile of agents in simulation. It is based on the mandatory `:demo_stats` data frame which is containing an informations about socio-demographic structure of each DA. 


The construction of `demografic_categories` dictionary is following:
* Each key is an agent's demographic attribute.
* Values of a `demografic_categories` dictionary are also the dictionaries.
* Each of this sub-dictionaries  is mapping the specified `:demo_stats` data frame columns with their possible values.

"""
const demografic_categories = Dict(
    :age_gender => Dict(
    :ECYHMA2024 => ("M", (20:24)), #"Male Household Population by Age - 20 To 24",
    :ECYHMA2529 => ("M", (25:29)), #"Male Household Population by Age - 25 To 29",
    :ECYHMA3034 => ("M", (30:34)), #"Male Household Population by Age - 30 To 34",
    :ECYHMA3539 => ("M", (35:39)), #"Male Household Population by Age - 35 To 39",
    :ECYHMA4044 => ("M", (40:44)), #"Male Household Population by Age - 40 To 44",
    :ECYHMA4549 => ("M", (45:49)), #"Male Household Population by Age - 45 To 49",
    :ECYHMA5054 => ("M", (50:54)), #"Male Household Population by Age - 50 To 54",
    :ECYHMA5559 => ("M", (55:59)), #"Male Household Population by Age - 55 To 59",
    :ECYHMA6064 => ("M", (60:64)), #"Male Household Population by Age - 60 To 64",
    :ECYHMA6569 => ("M", (65:69)), #"Male Household Population by Age - 65 To 69",
    :ECYHFA2024 => ("F", (20:24)), #"Female Household Population by Age - 20 To 24",
    :ECYHFA2529 => ("F", (25:29)), #"Female Household Population by Age - 25 To 29",
    :ECYHFA3034 => ("F", (30:34)), #"Female Household Population by Age - 30 To 34",
    :ECYHFA3539 => ("F", (35:39)), #"Female Household Population by Age - 35 To 39",
    :ECYHFA4044 => ("F", (40:44)), #"Female Household Population by Age - 40 To 44",
    :ECYHFA4549 => ("F", (45:49)), #"Female Household Population by Age - 45 To 49",
    :ECYHFA5054 => ("F", (50:54)), #"Female Household Population by Age - 50 To 54",
    :ECYHFA5559 => ("F", (55:59)), #"Female Household Population by Age - 55 To 59",
    :ECYHFA6064 => ("F", (60:64)), #"Female Household Population by Age - 60 To 64",
    :ECYHFA6569 => ("F", (65:69))  #"Female Household Population by Age - 65 To 69"
    ),
    :marital_status => Dict(
    :ECYMARMCL  => true,  #"Total Population 15 Years Or Over - Married Or Living With A Common-Law Partner",
    :ECYMARNMCL => false #"Total Population 15 Years Or Over - Not Married And Not Living With A Common-Law Partner",
    ),
    :work_industry => Dict(
    :ECYINDAGRI => "Agriculture, Forestry, Fishing And Hunting", 
    :ECYINDMINE => "Mining, Quarrying, And Oil And Gas Extraction", 
    :ECYINDUTIL => "Utilities",  
    :ECYINDCSTR => "Construction", 
    :ECYINDMANU => "Manufacturing", 
    :ECYINDWHOL => "Wholesale Trade", 
    :ECYINDRETL => "Retail Trade", 
    :ECYINDTRAN => "Transportation And Warehousing", 
    :ECYINDINFO => "Information And Cultural Industries", 
    :ECYINDFINA => "Finance And Insurance", 
    :ECYINDREAL => "Real Estate And Rental And Leasing",
    :ECYINDPROF => "Professional, Scientific And Technical Services", 
    :ECYINDMGMT => "Management Of Companies And Enterprises", 
    :ECYINDADMN => "Administrative And Support, Waste Management And Remediation Services", 
    :ECYINDEDUC => "Educational Services", 
    :ECYINDHLTH => "Health Care And Social Assistance",
    :ECYINDARTS => "Arts, Entertainment And Recreation", 
    :ECYINDACCO => "Accommodation And Food Services", 
    :ECYINDOSER => "Other Services (Except Public Administration)", 
    :ECYINDPUBL => "Public Administration"
    ),
    :household_income => Dict(
    :ECYHRI_010 => (0:9999),        #"Total Households by Income - 9,999 Or Less (Constant Year 2005 \$)",
    :ECYHRI1020 => (10000:19999),   #"Total Households by Income - 10,000 To 19,999 (Constant Year 2005 \$)",
    :ECYHRI2030 => (20000:29999),   #"Total Households by Income - 20,000 To 29,999 (Constant Year 2005 \$)",
    :ECYHRI3040 => (30000:39999),   #"Total Households by Income - 30,000 To 39,999 (Constant Year 2005 \$)",
    :ECYHRI4050 => (40000:49999),   #"Total Households by Income - 40,000 To 49,999 (Constant Year 2005 \$)",
    :ECYHRI5060 => (50000:59999),   #"Total Households by Income - 50,000 To 59,999 (Constant Year 2005 \$)",
    :ECYHRI6070 => (60000:69999),   #"Total Households by Income - 60,000 To 69,999 (Constant Year 2005 \$)",
    :ECYHRI7080 => (70000:79999),   #"Total Households by Income - 70,000 To 79,999 (Constant Year 2005 \$)",
    :ECYHRI8090 => (80000:89999),   #"Total Households by Income - 80,000 To 89,999 (Constant Year 2005 \$)",
    :ECYHRIX100 => (90000:99999),   #"Total Households by Income - 90,000 To 99,999 (Constant Year 2005 \$)",
    :ECYHRIX125 => (100000:124999), #"Total Households by Income - 100,000 To 124,999 (Constant Year 2005 \$)",
    :ECYHRIX150 => (125000:149999), #"Total Households by Income - 125,000 To 149,999 (Constant Year 2005 \$)",
    :ECYHRIX175 => (150000:174999), #"Total Households by Income - 150,000 To 174,999 (Constant Year 2005 \$)",
    :ECYHRIX200 => (175000:199999), #"Total Households by Income - 175,000 To 199,999 (Constant Year 2005 \$)",
    :ECYHRIX250 => (200000:249999), #"Total Households by Income - 200,000 To 249,999 (Constant Year 2005 \$)",
    :ECYHRI250P => (250000:1000000) #"Total Households by Income - 250,000 Or Over (Constant Year 2005 \$)",
    ),
    :household_size => Dict(
    :ECYHSZ1PER => 1, #"Total Households For Household Size - 1 Person",
    :ECYHSZ2PER => 2, #"Total Households For Household Size - 2 Persons",
    :ECYHSZ3PER => 3, #"Total Households For Household Size - 3 Persons",
    :ECYHSZ4PER => 4, #"Total Households For Household Size - 4 Persons",
    :ECYHSZ5PER => 5  #"Total Households For Household Size - 5 Persons",
    ),
    :no_of_children => Dict(
    :HouseholdsWithoutChildren => 0,
    :ECYHFSC1C  => 1, #"Total Households with Couple 1 Child", 
    :ECYHFSC2C  => 2, #"Total Households with Couple 2 Children", 
    :ECYHFSC3C  => 3, #"Total Households with Couple 3 Or More Children", 
    :ECYHFSLP1C => 1, #"Total Households with Lone-Parent 1 Child", 
    :ECYHFSLP2C => 2, #"Total Households with Lone-Parent 2 Children", 
    :ECYHFSLP3C => 3, #"Total Households with Lone-Parent 3 Or More Children", 
    ),
    :children_age => Dict(
    :ECYCHA_0_4 => (0:4),   #"Total Children At Home by Age - 0 To 4",
    :ECYCHA_5_9 => (5:9),   #"Total Children At Home by Age - 5 To 9",
    :ECYCHA1014 => (10:14), #"Total Children At Home by Age - 10 To 14",
    :ECYCHA1519 => (15:19), #"Total Children At Home by Age - 15 To 19",
    :ECYCHA2024 => (20:24), #"Total Children At Home by Age - 20 To 24",
    :ECYCHA25P  => (25:50), #"Total Children At Home by Age - 25 Or More",
    ),
    :immigrant => Dict(
    :ECYPIMNI   => false, #"Household Population - Non-Immigrants",
    :ECYPIMIM   => true,  #"Household Population - Immigrants",
    ),
    :immigrant_since => Dict(
    :ECYPIMP01  => "Before 2001",     #"Household Population For Period Of Immigration - Before 2001",
    :ECYPIM0105 => "2001 To 2005",    #"Household Population For Period Of Immigration - 2001 To 2005",
    :ECYPIM0611 => "2006 To 2011",    #"Household Population For Period Of Immigration - 2006 To 2011",
    :ECYPIM12CY => "2012 To Present", #"Household Population For Period Of Immigration - 2012 To Present",
    ),
    :immigrant_region => Dict(
    :ECYTIMNAM  => "North America",
    :ECYTIMCAM  => "Central America",
    :ECYTIMCB   => "Caribbean And Bahamas",
    :ECYTIMSAM  => "South America",
    :ECYTIMWEU  => "Western Europe",
    :ECYTIMEEU  => "Eastern Europe",
    :ECYTIMNEU  => "Northern Europe",
    :ECYTIMSEU  => "Southern Europe",
    :ECYTIMWAF  => "Western Africa",
    :ECYTIMEAF  => "Eastern Africa",
    :ECYTIMNAF  => "Northern Africa",
    :ECYTIMCAF  => "Central Africa",
    :ECYTIMSAF  => "Southern Africa",
    :ECYTIMWCA  => "West Central Asia And Middle East",
    :ECYTIMEA   => "Eastern Asia",
    :ECYTIMSEA  => "Southeastern Asia",
    :ECYTIMSA   => "Southern Asia",
    :ECYTIMOCE  => "Ocean And Other"
    ),
	:misc => Dict( #additional columns used in simulation
    :DA_ID     => "Dissemination Area id",
    :ECYPOWUSUL => "HH Pop 15 years or over by place of work - Worked At Usual Place",
    :ECYTRADRIV => "HH Pop 15 years or over with usual place of work and no fixed place of work - Travel To Work By Car As Driver",
    ),
)


"""
Industry dictionary for agent_profile:
* `key` : industry from agent's demographic profile
* `value` : industry from business_data dataset
"""
const industry = Dict(
    "Manufacturing"                       => ["Manufacturing", "Unassigned"], 
    "Transportation And Warehousing"      => ["Transportation And Warehousing", "Unassigned"], 
    "Arts, Entertainment And Recreation"  => ["Arts, Entertainment and Recreation", "Unassigned"], 
    "Construction"                        => ["Construction", "Unassigned"], 
    "Other Services (Except Public Administration)" => 
        ["Other Services (Except Public Administration)", "Unassigned"], 
    "Retail Trade"                        => ["Retail Trade", "Unassigned"], 
    "Wholesale Trade"                     => ["Wholesale Trade", "Unassigned"], 
    "Professional, Scientific And Technical Services" => 
        ["Professional, Scientific and Technical Services", "Unassigned"], 
    "Accommodation And Food Services"     => ["Accommodation and Food Services", "Unassigned"], 
    "Finance And Insurance"               => ["Finance, Insurance and Real Estate", "Unassigned"], 
    "Educational Services"                => ["Educational, Health and Social Services", "Unassigned"], 
    "Agriculture, Forestry, Fishing And Hunting" => 
        ["Agricultural & Natural Resources", "Unassigned"], 
    "Administrative And Support, Waste Management And Remediation Services" => 
        ["Administrative and Support and Waste Management", "Unassigned"], 
    "Public Administration"               => ["Public Administration", "Unassigned"], 
    "Information And Cultural Industries" => ["Information", "Unassigned"], 
    "Management Of Companies And Enterprises" => 
        ["Management", "Unassigned"], 
    "Utilities"                           => 
        ["Other Services (Except Public Administration)", "Professional, Scientific and Technical Services", 
        "Agricultural & Natural Resources", "Agricultural & Natural Resources"], 
    "Real Estate And Rental And Leasing"  => ["Finance, Insurance and Real Estate", "Unassigned"], 
    "Health Care And Social Assistance"   => ["Educational, Health and Social Services", "Unassigned"], 
    "Mining, Quarrying, And Oil And Gas Extraction" => 
        ["Agricultural & Natural Resources", "Unassigned"]
)

 
"""
Dictionary mapping children age with school category
* `key` : children age intervals 
* `value` : correspoding school category
"""
const school_category = Dict(
    (0:3) => "Child Care Facility",
    (4:5) => "Pre School",
    (6:14) => "School",
    #(15:40) => "too old",
)

# working-out probabilities - TO BE CONFIRMED
const recreation_probabilities = Dict{Symbol,Dict{Union{String,UnitRange{Int}},Float64}}(
    :when => Dict("before" => 0.4, "after" => 1.0), # before or after work
    :gender => Dict("M" => 0.7, "F" => 0.5),        #for males or females
    :age =>  Dict((15:55) => 0.8, (56:100) => 0.2),
    :household_income => Dict((0:100000) => 0.2, (100001:1000000) => 0.9)
)

# shopping probabilities - assuming no differences between females and males 
"""
Dictionary mapping different types of stores with probabilities
* `key` : types of store 
* `value` : probability
"""
const shopping_probabilities = Dict("shopping centre" => 1/28, # once a month
"drugstore" => 1/21, # every three weeks
"petrol station" => 1/7,
"supermarket" => 1/7,
"convinience" => 1/7,
"other retail" => 1/28,    
"grocery" => 2/7,  
"discount" => 1/7,
"mass merchandise" => 1/14)


const school_probability = .41

const weight_var = :ECYTRADRIV
