#!/usr/local/bin/julia
#
# watch he MQTT traffic of susi.
#
# © Andreas Dominik, THM, 2010
#
module Watch

using ArgParse
include("mqtt.jl")
include("topics.jl")
include("args.jl")


export parse_commandline, printArgs

end
