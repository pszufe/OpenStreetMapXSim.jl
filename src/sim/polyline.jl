function encode_one(val::Int)
    val <<= 1
    val = val < 0 ? ~val : val
    res = ""
    while val >= 0x20
        res *= Char((0x20 | (val & 0x1f)) + 63)
        val >>= 5
    end
    res *= Char(val + 63)
end

function encode(coords::Tuple{Float64,Float64}...)
    prev_lat, prev_lon = 0,0
    res = ""
    for coord in coords
        lat,lon = trunc(Int, coord[1] *1e5), trunc(Int, coord[2]  *1e5) 
        res *= OSMSim.encode_one(lat - prev_lat) * encode_one(lon - prev_lon)
        prev_lat, prev_lon = lat,lon
    end
    return res
end

function decode_one(polyline::Array{Char,1}, index::Int)
    byte = nothing
    res = 0
    shift = 0
    while isa(byte, Void) || byte >= 0x20
        byte = Int(polyline[index]) - 63
        index += 1
        res |= (byte & 0x1f) << shift
        shift += 5
    end
    res = Bool(res & 1) ? ~(res >> 1) : (res >> 1)
    return res, index
end

function decode(polyline::String)
    polyline = collect(polyline)
    coords = Tuple{Float64,Float64}[]
    index = 1 
    lat, lon = 0.0,0.0
    while index < length(polyline)
        lat_change, index = OSMSim.decode_one(polyline,index)
        lon_change, index = OSMSim.decode_one(polyline,index)
        lat += lat_change
        lon += lon_change
        push!(coords, (lat/1e5,lon/1e5))
    end
    return coords
end