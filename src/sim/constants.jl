 const file_names = Dict{Symbol,Union{String,Array{String,1}}}(:osm => "Winnipeg CMA.osm",
:features => [ "df_popstores.csv",
  "df_schools.csv",
  "df_recreationComplex.csv",
  "df_shopping.csv",],
:flows =>"df_hwflows.csv",
:DAs => "df_DA_centroids.csv",
:dem_stats => "df_demostat.csv",
:work_stats => "df_business.csv"
)
 
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


###################################
### Demographics data dictionary

desc_df_demographics = Dict(
    :DA_ID     => "Dissemination Area id",
    :ECYBASHHD  => "Total Households",
    :ECYBASHPOP => "Total Household Population",
    :ECYBAS15HP => "Total Household Population 15 Years Or Over",
    :ECYBAS18HP => "Total Household Population 18 Years Or Over",
    :ECYBASKID  => "Total Children Living In Households (Children At Home)",
    :ECYBASLF   => "In The Labour Force",
    :ECYHTA_0_4 => "Household Population by Age - 0 To 4",
    :ECYHTA_5_9 => "Household Population by Age - 5 To 9",
    :ECYHTA1014 => "Household Population by Age - 10 To 14",
    :ECYHTA1519 => "Household Population by Age - 15 To 19",
    :ECYHTA2024 => "Household Population by Age - 20 To 24",
    :ECYHTA2529 => "Household Population by Age - 25 To 29",
    :ECYHTA3034 => "Household Population by Age - 30 To 34",
    :ECYHTA3539 => "Household Population by Age - 35 To 39",
    :ECYHTA4044 => "Household Population by Age - 40 To 44",
    :ECYHTA4549 => "Household Population by Age - 45 To 49",
    :ECYHTA5054 => "Household Population by Age - 50 To 54",
    :ECYHTA5559 => "Household Population by Age - 55 To 59",
    :ECYHTA6064 => "Household Population by Age - 60 To 64",
    :ECYHTA6569 => "Household Population by Age - 65 To 69",
    :ECYHTA7074 => "Household Population by Age - 70 To 74",
    :ECYHTA7579 => "Household Population by Age - 75 To 79",
    :ECYHTA8084 => "Household Population by Age - 80 To 84",
    :ECYHTA85P  => "Household Population by Age - 85 Or Older",
    :ECYHTAAVG  => "Average Age Of Total Household Population",
    :ECYHTAMED  => "Median Age Of Total Household Population",
    :ECYHMAHPOP => "Household Population Male",
    :ECYHMA_0_4 => "Male Household Population by Age - 0 To 4",
    :ECYHMA_5_9 => "Male Household Population by Age - 5 To 9",
    :ECYHMA1014 => "Male Household Population by Age - 10 To 14",
    :ECYHMA1519 => "Male Household Population by Age - 15 To 19",
    :ECYHMA2024 => "Male Household Population by Age - 20 To 24",
    :ECYHMA2529 => "Male Household Population by Age - 25 To 29",
    :ECYHMA3034 => "Male Household Population by Age - 30 To 34",
    :ECYHMA3539 => "Male Household Population by Age - 35 To 39",
    :ECYHMA4044 => "Male Household Population by Age - 40 To 44",
    :ECYHMA4549 => "Male Household Population by Age - 45 To 49",
    :ECYHMA5054 => "Male Household Population by Age - 55 To 59",
    :ECYHMA5559 => "Male Household Population by Age - 50 To 54",
    :ECYHMA6064 => "Male Household Population by Age - 60 To 64",
    :ECYHMA6569 => "Male Household Population by Age - 65 To 69",
    :ECYHMA7074 => "Male Household Population by Age - 70 To 74",
    :ECYHMA7579 => "Male Household Population by Age - 75 To 79",
    :ECYHMA8084 => "Male Household Population by Age - 80 To 84",
    :ECYHMA85P  => "Male Household Population by Age - 85 Or Older",
    :ECYHMAAVG  => "Average Age Of Household Population Male",
    :ECYHMAMED  => "Median Age Of Household Population Male",
    :ECYHFAHPOP => "Household Population Female",
    :ECYHFA_0_4 => "Female Household Population by Age - 0 To 4",
    :ECYHFA_5_9 => "Female Household Population by Age - 5 To 9",
    :ECYHFA1014 => "Female Household Population by Age - 10 To 14",
    :ECYHFA1519 => "Female Household Population by Age - 15 To 19",
    :ECYHFA2024 => "Female Household Population by Age - 20 To 24",
    :ECYHFA2529 => "Female Household Population by Age - 25 To 29",
    :ECYHFA3034 => "Female Household Population by Age - 30 To 34",
    :ECYHFA3539 => "Female Household Population by Age - 35 To 39",
    :ECYHFA4044 => "Female Household Population by Age - 40 To 44",
    :ECYHFA4549 => "Female Household Population by Age - 45 To 49",
    :ECYHFA5054 => "Female Household Population by Age - 50 To 54",
    :ECYHFA5559 => "Female Household Population by Age - 55 To 59",
    :ECYHFA6064 => "Female Household Population by Age - 60 To 64",
    :ECYHFA6569 => "Female Household Population by Age - 65 To 69",
    :ECYHFA7074 => "Female Household Population by Age - 70 To 74",
    :ECYHFA7579 => "Female Household Population by Age - 75 To 79",
    :ECYHFA8084 => "Female Household Population by Age - 80 To 84",
    :ECYHFA85P  => "Female Household Population by Age - 85 Or Older",
    :ECYHFAAVG  => "Average Age Of Household Population Female",
    :ECYHFAMED  => "Median Age Of Household Population Female",
    :ECYHSZ1PER => "Total Households For Household Size - 1 Person",
    :ECYHSZ2PER => "Total Households For Household Size - 2 Persons",
    :ECYHSZ3PER => "Total Households For Household Size - 3 Persons",
    :ECYHSZ4PER => "Total Households For Household Size - 4 Persons",
    :ECYHSZ5PER => "Total Households For Household Size - 5 Persons",
    :ECYMARMCL  => "Total Population 15 Years Or Over - Married Or Living With A Common-Law Partner",
    :ECYMARNMCL => "Total Population 15 Years Or Over - Not Married And Not Living With A Common-Law Partner",
    :ECYHFSCNC  => "Total Households with Couple Without Children At Home", 
    :ECYHFSCWC  => "Total Households with Couple With Children At Home", 
    :ECYHFSC1C  => "Total Households with Couple 1 Child", 
    :ECYHFSC2C  => "Total Households with Couple 2 Children", 
    :ECYHFSC3C  => "Total Households with Couple 3 Or More Children", 
    :ECYHFSLP   => "Total Households with Lone-Parent Total Lone-Parent Family Households", 
    :ECYHFSLP1C => "Total Households with Lone-Parent 1 Child", 
    :ECYHFSLP2C => "Total Households with Lone-Parent 2 Children", 
    :ECYHFSLP3C => "Total Households with Lone-Parent 3 Or More Children", 
    :ECYCHA_0_4 => "Total Children At Home by Age - 0 To 4",
    :ECYCHA_5_9 => "Total Children At Home by Age - 5 To 9",
    :ECYCHA1014 => "Total Children At Home by Age - 10 To 14",
    :ECYCHA1519 => "Total Children At Home by Age - 15 To 19",
    :ECYCHA2024 => "Total Children At Home by Age - 20 To 24",
    :ECYCHA25P  => "Total Children At Home by Age - 25 Or More",
    :ECYHRI_010 => "Total Households by Income - ",
    :ECYHRI1020 => "Total Households by Income - 10,000 To 19,999 (Constant Year 2005 \$)",
    :ECYHRI2030 => "Total Households by Income - 20,000 To 29,999 (Constant Year 2005 \$)",
    :ECYHRI3040 => "Total Households by Income - 30,000 To 39,999 (Constant Year 2005 \$)",
    :ECYHRI4050 => "Total Households by Income - 40,000 To 49,999 (Constant Year 2005 \$)",
    :ECYHRI5060 => "Total Households by Income - 50,000 To 59,999 (Constant Year 2005 \$)",
    :ECYHRI6070 => "Total Households by Income - 60,000 To 69,999 (Constant Year 2005 \$)",
    :ECYHRI7080 => "Total Households by Income - 70,000 To 79,999 (Constant Year 2005 \$)",
    :ECYHRI8090 => "Total Households by Income - 80,000 To 89,999 (Constant Year 2005 \$)",
    :ECYHRIX100 => "Total Households by Income - 90,000 To 99,999 (Constant Year 2005 \$)",
    :ECYHRIX125 => "Total Households by Income - 100,000 To 124,999 (Constant Year 2005 \$)",
    :ECYHRIX150 => "Total Households by Income - 125,000 To 149,999 (Constant Year 2005 \$)",
    :ECYHRIX175 => "Total Households by Income - 150,000 To 174,999 (Constant Year 2005 \$)",
    :ECYHRIX200 => "Total Households by Income - 175,000 To 199,999 (Constant Year 2005 \$)",
    :ECYHRIX250 => "Total Households by Income - 200,000 To 249,999 (Constant Year 2005 \$)",
    :ECYHRI250P => "Total Households by Income - 250,000 Or Over (Constant Year 2005 \$)",
    :ECYHRIAVG  => "Average Household Income (Constant Year 2005 \$)",
    :ECYHRIMED  => "Median Household Income (Constant Year 2005 \$)",
    :ECYOCCNA   => "HH Pop 15 years or over in Labour Force - Occupation Not Applicable",
    :ECYOCCMGMT => "HH Pop 15 years or over in Labour Force - Management",
    :ECYOCCBFAD => "HH Pop 15 years or over in Labour Force - Business Finance Administration",
    :ECYOCCNSCI => "HH Pop 15 years or over in Labour Force - Occupations In Sciences",
    :ECYOCCHLTH => "HH Pop 15 years or over in Labour Force - Occupations In Health",
    :ECYOCCSSER => "HH Pop 15 years or over in Labour Force - Occupations In Social Science, Education, Government, Religion",
    :ECYOCCARTS => "HH Pop 15 years or over in Labour Force - Occupations In Art, Culture, Recreation, Sport",
    :ECYOCCSERV => "HH Pop 15 years or over in Labour Force - Occupations In Sales And Service",
    :ECYOCCTRAD => "HH Pop 15 years or over in Labour Force - Occupations In Trades, Transport, Operators",
    :ECYOCCPRIM => "HH Pop 15 years or over in Labour Force - Occupations Unique To Primary Industries",
    :ECYOCCSCND => "HH Pop 15 years or over in Labour Force - Occupations Unique To Manufacture And Utilities",
    :ECYINDINLF => "HH Pop 15 years or over by industry - ",
    :ECYINDNA   => "HH Pop 15 years or over by industry - Industry - Not Applicable",
    :ECYINDAGRI => "HH Pop 15 years or over by industry - 11 Agriculture, Forestry, Fishing And Hunting",
    :ECYINDMINE => "HH Pop 15 years or over by industry - 21 Mining, Quarrying, And Oil And Gas Extraction",
    :ECYINDUTIL => "HH Pop 15 years or over by industry - 22 Utilities",
    :ECYINDCSTR => "HH Pop 15 years or over by industry - 23 Construction",
    :ECYINDMANU => "HH Pop 15 years or over by industry - 31-33 Manufacturing",
    :ECYINDWHOL => "HH Pop 15 years or over by industry - 41 Wholesale Trade",
    :ECYINDRETL => "HH Pop 15 years or over by industry - 44-45 Retail Trade",
    :ECYINDTRAN => "HH Pop 15 years or over by industry - 48-49 Transportation And Warehousing",
    :ECYINDINFO => "HH Pop 15 years or over by industry - 51 Information And Cultural Industries",
    :ECYINDFINA => "HH Pop 15 years or over by industry - 52 Finance And Insurance",
    :ECYINDREAL => "HH Pop 15 years or over by industry - 53 Real Estate And Rental And Leasing",
    :ECYINDPROF => "HH Pop 15 years or over by industry - 54 Professional, Scientific And Technical Services",
    :ECYINDMGMT => "HH Pop 15 years or over by industry - 55 Management Of Companies And Enterprises",
    :ECYINDADMN => "HH Pop 15 years or over by industry - 56 Administrative And Support, Waste Management And Remediation Services",
    :ECYINDEDUC => "HH Pop 15 years or over by industry - 61 Educational Services",
    :ECYINDHLTH => "HH Pop 15 years or over by industry - 62 Health Care And Social Assistance",
    :ECYINDARTS => "HH Pop 15 years or over by industry - 71 Arts, Entertainment And Recreation",
    :ECYINDACCO => "HH Pop 15 years or over by industry - 72 Accommodation And Food Services",
    :ECYINDOSER => "HH Pop 15 years or over by industry - 81 Other Services (Except Public Administration)",
    :ECYINDPUBL => "HH Pop 15 years or over by industry - 91 Public Administration",
    :ECYPOWEMP  => "HH Pop 15 years or over by place of work - Employed",
    :ECYPOWHOME => "HH Pop 15 years or over by place of work - Worked At Home",
    :ECYPOWOSCA => "HH Pop 15 years or over by place of work - Worked Outside Canada",
    :ECYPOWNFIX => "HH Pop 15 years or over by place of work - No Fixed Workplace Address",
    :ECYPOWUSUL => "HH Pop 15 years or over by place of work - Worked At Usual Place",
    :ECYTRAALL  => "HH Pop 15 years or over with usual place of work and no fixed place of work - ",
    :ECYTRADRIV => "HH Pop 15 years or over with usual place of work and no fixed place of work - Travel To Work By Car As Driver",
    :ECYTRAPSGR => "HH Pop 15 years or over with usual place of work and no fixed place of work - Travel To Work By Car As Passenger",
    :ECYTRAPUBL => "HH Pop 15 years or over with usual place of work and no fixed place of work - Travel To Work By Public Transit",
    :ECYTRAWALK => "HH Pop 15 years or over with usual place of work and no fixed place of work - Travel To Work By Walked",
    :ECYTRABIKE => "HH Pop 15 years or over with usual place of work and no fixed place of work - Travel To Work By Bicycle",
    :ECYTRAOTHE => "HH Pop 15 years or over with usual place of work and no fixed place of work - Travel To Work By Other Method",
    :ECYVISVM   => "Household Population - Visible Minority Total",
    :ECYVISCHIN => "Household Population - Visible Minority Chinese",
    :ECYVISSA   => "Household Population - Visible Minority South Asian",
    :ECYVISBLCK => "Household Population - Visible Minority Black",
    :ECYVISFILI => "Household Population - Visible Minority Filipino",
    :ECYVISLAM  => "Household Population - Visible Minority Latin American",
    :ECYVISSEA  => "Household Population - Visible Minority Southeast Asian",
    :ECYVISARAB => "Household Population - Visible Minority Arab",
    :ECYVISWA   => "Household Population - Visible Minority West Asian",
    :ECYVISKOR  => "Household Population - Visible Minority Korean",
    :ECYVISJAPA => "Household Population - Visible Minority Japanese",
    :ECYVISOVM  => "Household Population - Visible Minority All Other Visible Minorities",
    :ECYVISMVM  => "Household Population - Visible Minority Multiple Visible Minorities",
    :ECYVISNVM  => "Household Population - Visible Minority Not A Visible Minority",
    :ECYPIMNI   => "Household Population - Non-Immigrants",
    :ECYPIMIM   => "Household Population - Immigrants",
    :ECYPIMP01  => "Household Population For Period Of Immigration - Before 2001",
    :ECYPIM0105 => "Household Population For Period Of Immigration - 2001 To 2005",
    :ECYPIM0611 => "Household Population For Period Of Immigration - 2006 To 2011",
    :ECYPIM12CY => "Household Population For Period Of Immigration - 2012 To Present",
	:ECYTIMNAM  => "North America",
	:ECYTIMCB   => "Caribbean And Bahamas",
	:ECYTIMCAM  => "Central America",
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


# shopping probabilities - assuming no differences between females and males 
shopping_probabilities = Dict(:shoppingcentre => 1/28, # once a month
:drugstore => 1/21, # every three weeks
:petrol_station => 1/7,
:supermarket => 1/7,
:convinience => 1/7,
:other_retail => 1/28,    
:grocery => 2/7,  
:discount => 1/7,
:mass_merchandise => 1/14)


