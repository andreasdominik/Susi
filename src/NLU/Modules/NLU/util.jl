function setSkillsDir()
    setSkillsDir(CONFIG["skills"]["skills_dir"])
end

function setSkillsDir(d)

    global SKILLS_DIR = d
end


function getSkillsDir()
    return SKILLS_DIR
end


function getMatches()
    return MATCHES
end


function readConfig(configName)

    global CONFIG = TOML.parsefile(configName)
    global LANGCODE = CONFIG["assistant"]["language"]
    global LANG = lowercase(LANGCODE[1:2])
end




"""
    tryrun(cmd; wait = true)

Try to run an external command and returns true if successful
or false if not.

## Arguments:
* cmd: command to be executed on the shell
* wait: if `true`, wait until the command has finished
"""
function tryrun(cmd; wait = true)

    result = true
    try
        run(cmd; wait = wait)
    catch
        result = false
    end
    return result
end

"""
    tryParseJSONfile(fname)

Parse a JSON file and return a hierarchy of Dicts with
the content.
* keys are changed to Symbol
* on error, an empty Dict() is returned

## Arguments:
- fname: filename
"""
function tryParseJSONfile(fname)

    try
        json = JSON.parsefile( fname)
    catch
        println("[NLU] tryParseJSONfile error for $fname")
        json = Dict()
    end

    json = key2symbol(json)
    return json
end



"""
    key2symbol(arr::Array)

Wrapper for key2symbol, if 1st hierarchy is an Array
"""
function key2symbol(arr::Array)

    return [key2symbol(elem) for elem in arr]
end


"""
    key2symbol(dict::Dict)

Return a new Dict() with all keys replaced by Symbols.
d is scanned hierarchically.
"""
function key2symbol(dict::Dict)

    mkSymbol(s) = Symbol(replace(s, r"[^a-zA-Z0-9]"=>"_"))

    d = Dict{Symbol}{Any}()
    for (k,v) in dict

        if v isa Dict
            d[mkSymbol(k)] = key2symbol(v)
        elseif v isa Array
            d[mkSymbol(k)] = [(elem isa Dict) ? key2symbol(elem) : elem for elem in v]
        else
            d[mkSymbol(k)] = v
        end
    end
    return d
end

"""
    tryMkJSON(payload)

Create a JSON representation of the input (nested Dict or Array)
or return an empty string if not possible.
"""
function tryMkJSON(payload)

    json = Dict()
    try
        json = JSON.json(payload)
    catch
        json = ""
    end

    return json
end


function printDict(dict)

    print(json(dict, 2))
end
