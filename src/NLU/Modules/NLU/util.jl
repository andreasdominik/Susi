function setSkillDir(d)
    global SKILLS_DIR = d
end


function getSkillDir()
    return SKILLS_DIR
end


function getMatches()
    return MATCHES
end


function readConfig(configName)

    global CONFIG = TOML.parsefile(configName)
    global LANG = CONFIG["assistant"]["language"]
    global DUCKLING_HOST = CONFIG["duckling"]["host"]
    global DUCKLING_PORT = CONFIG["duckling"]["port"]


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
