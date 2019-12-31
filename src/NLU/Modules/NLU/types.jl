mutable struct Slot
    name
    type
    synonyms    # depend on type and class
    regex
end

struct Skill
    slots
    intents
end

mutable struct Intent
    name
    slots
    matchExpressions    # list of regexes to test against
end
