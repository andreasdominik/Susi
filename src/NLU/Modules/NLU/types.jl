mutable struct Slot
    name
    type
    allowEmpty
    synonyms    # depend on type and class
    regex
    postfun     # function to postprocess slot value
end


mutable struct MatchEx
    skill
    intent
    match
    slots
    raw
    matchExpression    # ONE regex to test against
end
