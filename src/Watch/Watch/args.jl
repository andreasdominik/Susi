
function parse_commandline()

    s = ArgParseSettings()
    @add_arg_table s begin
        "--host", "-H"
            help = "hostname of MQTT-server; default = nothing"
            default = nothing
        "--port", "-P"
            help = "port of MQTT-server; default = nothing"
            default = nothing
        "--user", "-u"
            help = "username for MQTT-server; default = nothing"
            default = nothing
        "--password", "-p"
            help = "password for MQTT-server; default = nothing"
            default = nothing
    end

    return parse_args(ARGS, s, as_symbols = true)
end


function printArgs(args)

    println("Parsed args:")
    for (arg,val) in args
        if val === nothing
            val = "nothing"
        end
        println("  $arg  =>  $val")
    end
end
