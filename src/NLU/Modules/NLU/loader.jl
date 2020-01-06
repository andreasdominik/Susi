function loadIntents()

    # search all skill dir tree for files nlu.toml
    #
    skills = AbstractString[]
    for (root, dirs, files) in walkdir(SKILLS_DIR)

        files = filter(f->f=="nlu.toml", files)
        paths = joinpath.(root, files)
        append!(skills, paths)
    end

    println("[NLU loader]: $(length(skills)) skills found to recognise.")

    for skill in skills
        println("[NLU loader]: loading nlu.toml for $skill.")

        toml = TOML.parsefile(skill)
        toml = fixToml(toml)
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

        # add optional word with space behind
        # and w/o space behind:
        #
        phrase = raw
        phrase = replace(phrase, " <<" => "  ?<<")
        phrase = replace(phrase, ">> " => ">>  ?")
        phrase = replace(phrase, "<<>>" => "\\S*")

        # word alternatives.
        # or "none" can be defined as <<word1|word2|>>
        #
        phrase = replace(phrase, r"<<(?P<aword>\S*)>>" => s"(?:\g<aword>)")

        # add slots as named capture groups:
        #
        for (slotName,slot) in slots
            phrase = replace(phrase, "<$(slot.name)>" => slot.regex )
        end

        # get type from first word and skip if unknown type:
        #
        (type, phrase) = split( phrase, " ", limit = 2)

        # clean whitespaces:
        #
        phrase = replace(phrase, r"^ \?" => "")
        phrase = replace(phrase, r"^\?" => "")
        phrase = replace(phrase, r" \?$" => "")
        phrase = strip(phrase)
        phrase = replace(phrase, r"\s{2,}" => " ")
        phrase = replace(phrase, r"( \?){2,}" => " ?")

        # println("raw:     $raw")
        # println("phrase:  $phrase")
        # println("regex:  $(Regex(phrase))")

        # make regex:
        #
        if type == "exact:"
            type = :exact
            push!(MATCHES, MatchEx(skill, intent, name, slots, raw, Regex("^$phrase\$", "i")))
        elseif type == "partial:"
            type = :partial
            push!(MATCHES, MatchEx(skill, intent, name, slots, raw, Regex(phrase, "i")))
        elseif type == "regex:"
            type = :regex
            push!(MATCHES, MatchEx(skill, intent, name, slots, raw, Regex(phrase, "i")))
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
            if type in ["Any","ListOfValues"]
                fun = function(slotParsed)
                    for (synName,synWords) in syns
                        synRe = Regex("^$(join(synWords,"|"))\$")
                        if occursin(synRe, slotParsed)
                            return(synName)
                        end
                    end
                end
            elseif type == "InstantTime"
                fun = function(slotParsed)
                    return askDuckling(:time, slotParsed)
                end
            elseif type == "Number"
                fun = function(slotParsed)
                    return askDuckling(:number, slotParsed)
                end
            elseif type == "Ordinal"
                fun = function(slotParsed)
                    return askDuckling(:ordinal, slotParsed)
                end
            elseif type == "Duration"
                fun = function(slotParsed)
                    return askDuckling(:duration, slotParsed)
                end
            elseif type == "Currency"
                fun = function(slotParsed)
                    return askDuckling(:currency, slotParsed)
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
