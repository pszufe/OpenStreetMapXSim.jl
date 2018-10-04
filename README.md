# OpenStreetMapXSim.jl

OpenStreetMapXSim - map simulations library

This is a proof-of-concept beta version.

## Installation

The current version uses Julia 1.0.0

Before using the library you need to install Julia packages, press `]` to go to package manager:

```julia
add DataFrames StatsBase SparseArrays Serialization Distributed Dates Random Printf
```

Additionally OpenStreetMapX and Nanocsv are used:

```julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/pszufe/OpenStreetMapX.jl"))
Pkg.add(PackageSpec(url="https://github.com/bkamins/Nanocsv.jl"))
#optionally add for plotting:
Pkg.add(PackageSpec(url="https://github.com/pszufe/OpenStreetMapXPlot.jl"))
```

