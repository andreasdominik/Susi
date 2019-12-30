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
    slots
    exacts
    exactparts
    regexs
end
