function setSkillDir(d)
    global SKILLS_DIR = d
end


function getSkillDir()
    return SKILLS_DIR
end


function getMatches()
    return MATCHES
end


function readConfig(configName)

    CONFIG = TOML.parsefile(configName)

end
