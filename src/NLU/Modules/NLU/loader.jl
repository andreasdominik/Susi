function loadIntents()

    # search all skill dir tree for files nlu.toml
    #
    skills = AbstractString[]
    for (root, dirs, files) in walkdir(SKILLS_DIR)

        files = filter(f->f=="nlu.toml", files)
        paths = root .* "/" .* files
        append!(skills, paths)
    end

    println("[NLU loader]: $(length(skills)) skills found to recognise.")

    for skill in skills
        println("[NLU loader]: loading nlu.toml for $skill.")
        toml = loadToml(skill)
        addIntents(toml)
    end
end


function addIntents(toml)


    slots = extractSlots(toml)

    for intentName in toml["inventory"]["intents"]
        (exacts, parts, regexs) = extractPhrases(toml, intent)
        intent = Intent(slots, exacts, parts, regexs)
        global INTENTS
        push!(INTENTS, intent)
    end
end


function extractSlots(toml)

    # types:
    #
    slotTypes = Dict{AbstractString, SlotType}()
    for st in toml["inventory"]["slot_types"]
        dict = toml[st]

        if dict["class"] in ["any", "synonyms"]
            if haskey(dict, "synonyms") && dict["synonyms"] isa Dict
                synonyms = dict["synonyms"]
            else
                synonyms = Dict()
            end
            slotTypes[st] = SlotType(st, dict["class"], synonyms)

        elseif dict["class"] == "datetime"
        end
    end

    # slots:
    #
    slots = Dict{AbstractString, Slot}()
    for s in toml["inventory"]["slots"]
        t = toml[s]["slot_type"]
        slots[s] = Slot(deepcopy(s),
                        deepcopy(t),
                        deepcopy(slotTypes[t].class),
                        deepcopy(slotTypes[t].values))
    end
    return slots
end













# TOML loader and fixer:
#
function loadToml(filename)
    toml = TOML.parsefile(TOML_FILE)

    # fix missing [] for one-item lists:
    #
    return fixToml(toml)
end



function fixToml(dict)

    for (key, val) in dict
        if key in ["slot_types", "slots", "intents"]
            val = fixOne(val)

        elseif key in ["exact", "regex", "exactpart"]
            val = fixOne(val)

        elseif (key == "synonyms") && (val isa Dict)
            val = Dict(k=>fixOne(v) for (k,v) in val)

        elseif val isa Dict
            val = fixToml(val)
        end
        dict[key] = val
    end
    return dict
end



function fixOne(val)
    if val isa AbstractString
        println("fixing $val")
        return [val]
    else
        return val
    end
end
