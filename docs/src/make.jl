using Documenter

# tell Documenter, where so look for source files:
#

makedocs(#modules=[SOM],
         clean = false,
         #assets = ["assets/favicon.ico"],
         sitename = "Susi",
         authors = "Andreas Dominik",
         pages = [
                  "Introduction" => "pages/index.md",
                  "Installation" => "pages/install.md",
                  "NLU" => "pages/nlu.md",
                  "Configuration" => "configuration.md",
                  "Components" => "pages/components.md",
                  "Payloads" => "pages/payloads.md",
                  "Topics" => "pages/topics.md",
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
