function loadIntents()

    # search all skill dir tree for files nlu.toml
    #
    skills = AbstractString[]
    for (root, dirs, files) in walkdir(SKILLS_DIR)

        files = filter(f->f=="nlu.toml", files)
        paths = joinpath(root, files)
        append!(skills, paths)
    end

    println("[NLU loader]: $(length(skills)) skills found to recognise.")

    for skill in skills
        println("[NLU loader]: loading nlu.toml for $skill.")

        toml = TOML.parse(skill)
        slots = extractSlots(toml)
        for intentName in toml["inventory"]["intents"]
            extractPhrases(toml, slots, intentName)
        end
    end
end



"""
Extract the match expressions and add them to global list of MATCHES.
"""
function extractPhrases(toml, slots, intent)

    skill = toml["skill"]
    all = toml[intent]
    global MATCHES

    # make regexes from phrases:
    #
    for (name, raw) in all

        # add optional word:
        #
        raw = replace(raw, "<>" => " [^\\s]* ")

        # add slots as named capture groups:
        #
        for sl in slots
            raw = replace(raw, "<$(sl.name)>" => sl.regex )
        end

        # get type from first word and skip if unknown type:
        #
        (type, phrase) = split( raw, " ", limit = 2)

        # clean whitespaces:
        #
        phrase = strip(phrase)
        phrase = replace(phrase, r"\s{2,}" => " ")

        # make regex:
        #
        if type == "exact:"
            type = :exact
            push!(MATCHES, MatchEx(skill, intent, name, slots, Regex("^$phrase\$")))
        elseif type == "partial:"
            type = :partial
            push!(MATCHES, MatchEx(skill, intent, name, slots, Regex(phrase)))
        elseif type == "regex:"
            type = :regex
            push!(MATCHES, MatchEx(skill, intent, name, slots, Regex(phrase)))
        else
            type = :unknown
        end
    end
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

    # slots:
    #
    slots = Dict{AbstractString, Slot}()
    for s in toml["inventory"]["slots"]

        type = toml[s]["slot_type"]
        if haskey(toml[s], "synonyms")
            syns = toml[s]["synonyms"]
        else
            syns = Dict{AbstractString, AbstractArray}()
        end

        # add regex that matches the slot:
        #
        # for list, match only ANY of the words in one of the
        # alternatives:
        #
        if type  == "list"
            words = []
            for (k,v) in syns
                append!(words, v)
            end
            matchSlot = join(words, "|")

        # for any just return all content as slot value:
        #
        elseif type in ["any", "list", "datetime", "currency",
                    "number", "ordinal"]
            matchSlot = ".+"
        else
            matchSlot = nothing
        end

        if matchSlot != nothing
            # re matches the single slot (with named capture group):
            #
            re = "(?P<$s>$matchSlot)"

            # define function for postprocessind:
            #
            if type in ["any","list"]
                fun = function(slotParsed)
                    for (synName,synWords) in syns
                        synRe = Regex("^$(join(synWords,"|"))\$")
                        if occursin(synRe, slotParsed)
                            return(synName)
                        end
                    end
                end
            elseif type == "datetime"
                fun = function(slotParsed)
                    return askDuckling(:time, slotParsed)
                end
            elseif type == "number"
                fun = function(slotParsed)
                    return askDuckling(:number, slotParsed)
                end
            elseif type == "ordinal"
                fun = function(slotParsed)
                    return askDuckling(:ordinal, slotParsed)
                end
            elseif type == "duration"
                fun = function(slotParsed)
                    return askDuckling(:duration, slotParsed)
                end
            else
                fun = function(slotParsed)
                    return slotParsed
                end
            end

            slots[s] = Slot(deepcopy(s),
                            deepcopy(type),
                            deepcopy(syns),
                            deepcopy(re),
                            fun)
        end
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
