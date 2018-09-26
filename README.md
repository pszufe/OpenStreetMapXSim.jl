# OSMsim.jl
OSMsim- map simulations library

## Installation

The current version uses Julia 1.0.0

Before using the library you need to install Julia packages, press `]` to go to package manager:

```julia
add Plots
add Distributions
add DataFrames
add DataFramesMeta
add FreqTables
add HTTP
add Query
add Shapefile
add LibExpat
add LightGraphs
```

Additionally OpenStreetMapX and Nanocsv are used:

```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/pszufe/OpenStreetMapX.jl"))
Pkg.add(PackageSpec(url="https://github.com/bkamins/Nanocsv.jl"))
#optionally add for plotting:
Pkg.add(PackageSpec(url="https://github.com/pszufe/OpenStreetMapXPlot.jl"))
```




