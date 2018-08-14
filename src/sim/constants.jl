 # work_industry
const work_industry = Dict(
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
)


# household_income
const hh_income = Dict(
    :ECYHRI_010 => [0, 9999], 
    :ECYHRI1020 => [10000, 19999], 
    :ECYHRI2030 => [20000, 29999], 
    :ECYHRI3040 => [30000, 39999], 
    :ECYHRI4050 => [40000, 49999], 
    :ECYHRI5060 => [50000, 59999], 
    :ECYHRI6070 => [60000, 69999], 
    :ECYHRI7080 => [70000, 79999], 
    :ECYHRI8090 => [80000, 89999], 
    :ECYHRIX100 => [90000, 99999], 
    :ECYHRIX125 => [100000, 124999], 
    :ECYHRIX150 => [125000, 149999], 
    :ECYHRIX175 => [150000, 174999], 
    :ECYHRIX200 => [175000, 199999], 
    :ECYHRIX250 => [200000, 249999], 
    :ECYHRI250P => [250000, 1000000]
)


# children_number_of
const children_number_of = Dict(
    :HouseholdsWithoutChildren => 0,
    :ECYHFSC1C => 1, 
    :ECYHFSC2C => 2, 
    :ECYHFSC3C => 3, # 3+
    :ECYHFSLP1C => 1, 
    :ECYHFSLP2C => 2, 
    :ECYHFSLP3C => 3 # 3+
)


# imigrant_region
const imigrant_region = Dict(
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
)

