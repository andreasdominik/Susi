# Module for a Julia-based NLU as a Snips-replacement.
#
# (c) A. Dominik, April 2019, © GPL3
#

module NLU

include("../TOML/TOML.jl")
using .TOML

include("util.jl")
include("types.jl")
include("loader.jl")

SKILLS_DIR = AbstractString
MATCHES = MatchEx[]


export setSkillDir, getSkillDir,
       loadIntents

end
