#!/usr/local/bin/julia
#
# watch he MQTT traffic of susi.
#
# © Andreas Dominik, THM, 2010
#
module Watch

using ArgParse
using JSON
using Dates

include("../../Tools/topics.sh")
include("mqtt.jl")
include("topics.jl")
include("args.jl")
include("loop.jl")


export parse_commandline, printArgs,
       watchSusi
end
