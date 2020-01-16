#!/usr/local/bin/julia --color=yes
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
    # printArgs(args)

    sayHello(args[:h], args[:p])

    watchSusi()
    # watchSusi(args[:host], args[:port], args[:user], args[:password])
end




function sayHello(host, port)

    if host === nothing
        host = "localhost"
    end
    if port === nothing
        port = "1883"
    end
    printstyled("Watching the Susi assistant on host $host:$port\n\n",
            bold=true, color=:green)
    # println(" ")
end


main()
