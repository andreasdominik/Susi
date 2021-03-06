function loadIntents()

    # search all skill dir tree for files nlu.toml
    #
    skills = AbstractString[]
    for (root, dirs, files) in walkdir(SKILLS_DIR)

        files = filter(f->occursin(Regex("^nlu.$LANG.toml\$"), f), files)
        paths = joinpath.(root, files)
        append!(skills, paths)
    end

    println("[NLU loader]: $(length(skills)) skills found to recognise in $SKILLS_DIR.")

    for skill in skills
        println("[NLU loader]:     loading $skill.")

        toml = TOML.parsefile(skill)
        toml = fixToml(toml)
        # printDict(toml)

        slots = extractSlots(toml)
        for intentName in toml["inventory"]["intents"]
            config = toml[intentName]
            phrases = removeConfig(toml["developer"], intentName, config)
            extractPhrases(toml, slots, intentName, phrases)
        end
    end

    # sort match expressions by skill, intent and name:
    #
    global MATCHES = sort(MATCHES, by=x->x.skill*x.intent*x.match)
end



"""
Extract the match expressions and add them to global list of MATCHES.
"""
function extractPhrases(toml, slots, intentName, phrases)

    skill = toml["skill"]
    global MATCHES
    fullIntent = "$(toml["developer"]):$intentName"

    # make regexes from phrases:
    #
    for (name, raw) in phrases

        # get type from first word:
        #
        (type, phrase) = split( raw, " ", limit = 2)

        # add slots as named capture groups:
        #
        for (slotName,slot) in slots
            phrase = replace(phrase, "<<$(slot.name)>>" => "$(slot.regex)\\b ?")
        end

        # not for Regex-type:
        # add optional word with space behind
        # and w/o space behind:
        #
        if type != "regex:"
            phrase = replace(phrase, " <<" => "  ?<<")
            phrase = replace(phrase, ">> " => ">>\\b ?")
            phrase = replace(phrase, "<<>>" => "\\S*")

            # word alternatives
            # can be defined as <<word1|word2|>>
            # match all chars in list but NOT greedy (.*?):
            #
            phrase = replace(phrase, r"<<(?P<aword>.*?)>>" => s"(?:\g<aword>)")



            # clean whitespaces:
            #
            phrase = replace(phrase, r"^ \?" => "")
            phrase = replace(phrase, r"^\?" => "")
            phrase = replace(phrase, r" \?$" => "")
            phrase = strip(phrase)
            phrase = replace(phrase, r"\s{2,}" => " ")
            phrase = replace(phrase, r"( \?){2,}" => " ?")
            phrase = replace(phrase, r"\? " => "?")
            phrase = replace(phrase, r"\) \(" => ") ?(")   # make space between two slots optional (in case slots are optinal)
        end

        if type == "regex:"
            re = Regex(phrase, "is")

        elseif type == "exact:"
            re = Regex("^$phrase\$", "is")

        elseif type == "partial:"
            re = Regex(phrase, "is")

        elseif type == "ordered:"
            # regex to match all whitespace ouside ():
            #
            ws = r"\s(?:(?=(?:(?![\)]).)*[\(])|(?!.*[\)]))"
            phrase = replace(phrase, ws => ".* .*")
            # phrase = ".*$phrase.*"
            re = Regex(phrase, "is")

        else
            re = "unknwon type of expression"
        end


        # println(name)
        # println("raw:     $raw")
        # println("phrase:  $phrase")
        # println("regex:  $(Regex(phrase))")
        # println()

         if re == "unknwon type of expression"
             println("NLU loader error: unable to process match expression $name")
         else
             push!(MATCHES, MatchEx(skill, fullIntent, name, slots, raw, re))
         end
    end
end


"""
find config settings in the list for an intent
i.e.: "disable_on_startup = true/false"
and remove from thelist, so that only match expressions are
in the list
"""
function removeConfig(developerName, intentName, config)

    global intentFilter
    for (key, val) in config

        if key == "disable_on_start"
            if val isa Bool && val
                push!(intentFilter, ("#", "$developerName:$intentName"))
            end

            delete!(config, key)
        end
    end
    return config
end






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

        if haskey(toml[s], "allow_empty")
            allowEmpty = toml[s]["allow_empty"]
        else
            allowEmpty = false
        end

        # add regex that matches the slot:
        #
        # for list, match only ANY of the words in one of the
        # alternatives:
        #
        if type  == "ListOfValues"
            words = []
            for (k,v) in syns
                append!(words, v)
            end
            matchSlot = join(words, "|")

        # for any just return all content as slot value:
        #
        elseif type in ["Number", "Ordinal"]
            matchSlot = "\\S+"
        elseif type in ["Any", "Time", "Duration", "Currency"]
            matchSlot = ".*\\S+.*"   # minimum one non-space
        else
            matchSlot = nothing
        end

        if matchSlot != nothing

            if allowEmpty
                matchSlot = matchSlot * "|"
            end

            # re matches the single slot (with named capture group):
            #
            re = "(?P<$s>$matchSlot)"

            # define function for postprocessind:
            #
            if type in ["Any","ListOfValues"]
                fun = function(slotParsed)
                    for (synName,synWords) in syns
                        synRe = Regex("^$(join(synWords,"|"))\$", "i")
                        if occursin(synRe, slotParsed)
                            return(synName)
                        end
                    end
                    return slotParsed
                end
            elseif type in ["Time", "Duration", "Number",
                            "Ordinal", "Currency"]
                fun = function(slotParsed)
                    return askDuckling(type, slotParsed)
                end
            else
                fun = function(slotParsed)
                    return slotParsed
                end
            end

            slots[s] = Slot(deepcopy(s),
                            deepcopy(type),
                            allowEmpty,
                            deepcopy(syns),
                            deepcopy(re),
                            fun)
        end
    end
    return slots
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
        # println("fixing $val")
        return [val]
    else
        return val
    end
end
