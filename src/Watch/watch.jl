#!/usr/local/bin/julia
#
# watch he MQTT traffic of susi.
#
# © Andreas Dominik, THM, 2010
#
const WATCHER_DIR = @__DIR__
include("$WATCHER_DIR/Watch/Watch.jl")
using Main.Watch


function main()
    args = parse_commandline()
    printArgs(args)
end

main()
