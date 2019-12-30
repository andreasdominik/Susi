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
        matchExpressions = extractPhrases(toml, slots, intentName)
        intent = Intent(intentName, slots, matchExpressions)
        global INTENTS
        push!(INTENTS, intent)
    end
     return(INTENTS)
end



function extractPhrases(toml, slots, intentName)

    d = toml[intentName]
    regexes = []
    phrases = []

    # make regexes from phrases:
    #
    for ph in d["exact"]
        push!(phrases, "^$ph\$")
    end
    for ph in d["exactpart"]
        push!(phrases, "$ph")
    end
    for ph in d["regex"]
        push!(phrases, ph)
    end


    # add slot-regex to phrases:
    #
    for (slotName, slot) in slots
        # for any just return all content as slot value:
        #
        if slot.type in ["any", "data", "time", "datetime"]
            matchSlot = ".+"

        # for synonyms, match all, but replace the synonyms
        # later:
        #
        elseif slot.class == "synonyms"
            matchSlot = ".+"

        # for list, match only ANY of the words in one of the
        # alternatives:
        #
        elseif slot.class == "list"
            words = []
            for (k,v) in slot.values
                append!(words, v)
            end
            matchSlot = join(words, "|")
        end

        # re matches the single slot (with named captuer group):
        #
        re = "(?<$slotName>$matchSlot)"

        for ph in phrases
            push!(regexes, replace(ph, "<$slotName>" => re ))
        end
    end
    return regexes
end







# julia> match(r".*(?<cg><e\w+>).*", s)
# RegexMatch("bla <eins> ble bla <zwei> end", cg="<eins>")
#
# julia> replace(s, r"<eins>" => "(?<eins>ein|zwe|dre)")
# "bla (?<eins>ein|zwe|dre) ble bla <zwei> end"
#
# julia> ss = replace(s, r"<eins>" => "(?<eins>ein|zwe|dre)")
# "bla (?<eins>ein|zwe|dre) ble bla <zwei> end"
#
# julia> match(Regex(ss), "bla dre ble bla <zwei> end")
# RegexMatch("bla dre ble bla <zwei> end", eins="dre")



function extractSlots(toml)

    # types:
    #
    slotTypes = Dict{AbstractString, SlotType}()
    for st in toml["inventory"]["slot_types"]
        dict = toml[st]

        if dict["class"] in ["list", "synonyms"]
            if haskey(dict, "synonyms") && dict["synonyms"] isa Dict
                synonyms = dict["synonyms"]
            else
                synonyms = Dict()
            end
            slotTypes[st] = SlotType(st, dict["class"], synonyms)
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













# # TOML loader and fixer:
# #
# function loadToml(filename)
#     toml = Main.TOML.parsefile(TOML_FILE)
#
#     # fix missing [] for one-item lists:
#     #
#     return fixToml(toml)
# end



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
