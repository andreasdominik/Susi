function showStartedSession(payload)
    println("\n\n")
    printTime()
    print("[Session] ")
    printstyled("Session of type $(payload[:init][:type]) started",
                bold=true, color=:green)
    print(" at site "); printSiteId(payload)
    print(" with sessionId: ")
    printSessionId(payload)
    println()
    printIntentFilter(payload[:init])
end

function showEndedSession(payload)
    printTime()
    print("[Session] ")
    printstyled("Session ended", bold=true, color=:green)
    print(" at site "); printSiteId(payload)
    print(" with sessionId: ")
    printSessionId(payload)
    println()

    if haskey(payload, :termination) && haskey(payload[:termination], :reason)
        dateIndent(); sessionIndent()
        printError("Reason: $(payload[:termination][:reason])")
        println()
    end
    println()
end

function showStartSession(payload)
    println("\n\n")
    printTime()
    print("[User] ")
    printstyled("Request to start session of type $(payload[:init][:type])",
                bold=true, color=:green)
    print(" from site "); printSiteId(payload)
    println()
    printIntentFilter(payload[:init])
end

function showHotwordDetected(payload)
    printTime()
    print("[Hotword] Hotword detected at site "); printSiteId(payload)
    println()
end

function showHotwordOn(payload)
    printTime()
    print("[Session] Request to start hotword daemon at site "); printSiteId(payload)
    println()
end


function showAudioRequest(payload)
    printTime()
    sessionIndent(); print("[Session] Request command recording for site ");
    printSiteId(payload)
    println();
end
function showAudioRecorded(payload)
    printTime()
    sessionIndent(); print("[Record] Audio received from site "); printSiteId(payload)
    println();
    if !haskey(payload, :audio) || length(payload[:audio]) < 10
        dateIndent(); sessionIndent()
        printError("Audio recording not valid!")
        println()
    end
end



function showSTTRequest(payload)
    printTime()
    sessionIndent()
    println("[Session] Transscription of audio requested.")
    end

function showTransscript(payload)
    printTime()
    sessionIndent()
    println("[STT] Transscript received:")
    dateIndent(); sessionIndent()
    if haskey(payload, :transscript) && length(payload[:transscript]) > 1
        sessionIndent()
        printText(payload[:transscript])
    else
        printError("No transscript received!")
    end
    println()
end



function showNLURequest(payload)
    printTime()
    sessionIndent(); println("[Session] Request NLU for transscript.");
end

function showNLUError(payload)
    printTime()
    sessionIndent(); print("[NLU]")
    printError("Error parsing the transsript into an intent!")
    println();
end

function showNLUResult(payload)
    printTime()
    sessionIndent(); println("[NLU] Transscript parsed:")

    dateIndent(); sessionIndent(); sessionIndent()
    print("Intent:"); printIntent(payload); println()

    dateIndent(); sessionIndent(); sessionIndent()
    println("Slots:")
    if haskey(payload, :slots) && length(payload[:slots]) > 0
        for slot in payload[:slots]
            if haskey(slot, :entity) && haskey(slot, :slotName) &&
               haskey(slot, :value) && haskey(slot[:value], :value) &&
               haskey(slot, :rawValue)
                dateIndent(); sessionIndent(); sessionIndent()
                printstyled("$(slot[:slotName]): $(slot[:value][:value])",
                            bold=true, color=:yellow)
                print(" (of type ")
                printstyled(slot[:entity], bold=false, color=:yellow)
                print(" read from raw ")
                printstyled("\"$(slot[:rawValue])\"", bold=false, color=:yellow)
                println(")")
            end
        end
    end
end


function showIntentPublished(payload)
    printTime()
    sessionIndent();
    print("[Session] Intent published: ")
    printIntent(payload); println()
end


function showEndSession(payload)
    printTime()
    sessionIndent();
    println("[User] Request to end session with message: ")
    if haskey(payload, :text)
        dateIndent(); sessionIndent()
        printText(payload[:text])
        println()
    end
end

function showContSession(payload)
    printTime()
    sessionIndent();
    println("[User] Request to continue session with message: ")
    if haskey(payload, :text)
        dateIndent(); sessionIndent()
        printText(payload[:text])
        println()
    end
    printIntentFilter(payload)
end

function showSay(payload)
    printTime()
    sessionIndent();
    print("[User] Request to say text at site ")
    printSiteId(payload); println(":")

    if haskey(payload, :text)
        dateIndent(); sessionIndent()
        printText(payload[:text])
        println()
    end
end

function showTTSRequest(payload)
    printTime()
    sessionIndent();
    println("[Session] Requesting audio for text:")

    if haskey(payload, :input)
        dateIndent(); sessionIndent()
        printText(payload[:input])
        println()
    end
end

function showTTSAudio(payload)
    printTime()
    sessionIndent();
    println("[TTS] Sending requested audio.")
end

function showPlay(payload)
    printTime()
    sessionIndent();
    print("[Session] Ask play daemon at site ")
    printSiteId(payload)
    println(" to play an audio file.")
end

function showPlayFinished(payload)
    printTime()
    sessionIndent();
    print("[play] Playing of audio file finished at site ")
    printSiteId(payload)
    println(".")
end







# helpers:
#
#
printSiteId(payload) = printstyled("$(payload[:siteId])", color=:light_blue)
printSessionId(payload) = printstyled("$(payload[:sessionId])", bold=false, color=:light_green)
printText(text) = printstyled("\"$text\"", bold=false, color=:magenta)

printTime() = printstyled("$(Dates.format(now(), "HH:MM:SS yyyy uuu dd")) ",
                          color = :light_black)
printError(msg) = printstyled(msg, bold=true, color=:red)
sessionIndent() = print("    ")
dateIndent() = print("                     ")


function printIntent(payload)
    if haskey(payload, :intent) && haskey(payload[:intent], :intentName)
        printstyled(payload[:intent][:intentName], bold=true, color=:yellow)
    end
end

function printIntentFilter(dict)
    if haskey(dict, :intentFilter) &&
       dict[:intentFilter] isa AbstractArray && length(dict[:intentFilter]) > 0
        dateIndent(); sessionIndent(); sessionIndent()
        println("Intents filtered and limited to:")
        for intentName in dict[:intentFilter]
            dateIndent(); sessionIndent(); sessionIndent(); sessionIndent()
            println(intentName)
        end
    end
end
