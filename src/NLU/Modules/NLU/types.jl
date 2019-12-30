struct SlotType
    name
    class
    values
end

mutable struct Slot
    name
    type
    class
    values    # depend on type and class
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
