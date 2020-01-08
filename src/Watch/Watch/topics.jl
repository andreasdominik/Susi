function showStartSession(payload)


    println(" ")
    println(" ")
    print("Session ($(payload[:init][:type])) started at site")
    printstyled(" $(payload[:siteId])", bold=true, color=:red)
    println(" with sessionId: $(payload[:sessionId])")

end
