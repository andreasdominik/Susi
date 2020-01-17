# Module for a Julia-based NLU as a Snips-replacement.
#
# (c) A. Dominik, April 2019, © GPL3
#

module NLU

include("../TOML/TOML.jl")
using .TOML
using JSON

include("util.jl")
include("types.jl")
include("loader.jl")
include("mqtt.jl")
include("filter.jl")
include("nluengine.jl")

CONFIG = Dict()
SKILLS_DIR = AbstractString
MATCHES = MatchEx[]
intentFilter = Dict{Tuple{AbstractString,AbstractString}, Bool}()

LANG = "en"
DUCKLING_HOST = "localhost"
DUCKLING_PORT = "8000"

# read topics from susi utils script:
#
include("../../../Tools/topics.sh")

export setSkillDir, getSkillDir,
       loadIntents

end
