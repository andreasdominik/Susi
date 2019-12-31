# Module for a Julia-based NLU as a Snips-replacement.
#
# (c) A. Dominik, April 2019, © GPL3
#

module NLU

# include("../TOML/TOML.jl")
# using Main.TOML
# TOML = Main.TOML

include("util.jl")
include("types.jl")
include("loader.jl")

INTENTS = Intent[]


export Slot, Skill, Intent,
       setSkillDir, getSkillDir,
       fixToml,
       addIntents

end
