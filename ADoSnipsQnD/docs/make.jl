using Documenter

# tell Documenter, where so look for source files:
#
include("../SnipsHermesQnD/src/SnipsHermesQnD.jl")
using Main.SnipsHermesQnD


makedocs(#modules=[SOM],
         clean = false,
         #assets = ["assets/favicon.ico"],
         sitename = "ADoSnipsQnD",
         authors = "Andreas Dominik",
         pages = [
                  "Introduction" => "index.md",
                  "SnipsHermesQnD" => "snipsHermesQnD.md",
                  "New skill tutorial" => "makeskill.md",
                  "Some Details" => "details.md",
                  "API Documentation" => "api/api.md",
                  "License" => "LICENSE.md"
                  ],
                  # Use clean URLs, unless built as a "local" build
          format = Documenter.HTML(prettyurls = !("local" in ARGS),
                   canonical = "https://andreasdominik.github.io/ADoSnipsQnD/dev/"),
         )

deploydocs(repo   = "github.com/andreasdominik/ADoSnipsQnD.git",
           target = "build",
           branch = "gh-pages",
           deps = nothing,
           make = nothing)
