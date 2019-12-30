struct SlotType
    name
    class
    values
end

struct Slot
    name
    type
    class
    values    # depend on type and class
end

struct Skill
    slots
    intents
end

struct Intent
    name
    slots
    exacts
    exactparts
    regexs
    matchExpressions    # list of regexes to test against
    captureGroups       # list of lists names of slots to match the expresions
end
