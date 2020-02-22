#!/usr/local/bin/julia --color=yes
#
# Daemon for a Julia-based NLU as a Snips-replacement.
#
# (c) A. Dominik, April 2019, © GPL3
#

# get dirs
#
const CONFIG_FILE = "/etc/susi.toml"
const NLU_DIR = @__DIR__

# const SKILLS_DIR = replace(FRAMEWORK_DIR, r"/[^/]*/?$"=>"")
include("$NLU_DIR/Modules/TOML/TOML.jl")
import Main.TOML
include("$NLU_DIR/Modules/NLU/NLU.jl")
import Main.NLU

# load config:
#
NLU.readConfig(CONFIG_FILE)
NLU.setSkillsDir()

# for each skill:
#
NLU.loadIntents()
NLU.listener()
#
# run forever ...
