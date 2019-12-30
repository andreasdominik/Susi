#
# API function goes here, to be called by the
# skill-actions:
#

# Scheduler functions:
#
#
# The db looks like:
# [
#   {
#     "topic" : "qnd/trigger/andreasdominik:ADoSnipsLights",
#     "create_time" : "2019-08-25T10:01:35.399"
#     "execute_time" : "2019-08-26T10:12:13.177"
#     "trigger" :
#     {
#       "room" : "default",
#       "device" : "floor_lamp",
#       "onOrOff" : "ON",
#       "settings" : "undefined"
#     }
#   },
#   {
#     ...
#   }
# ]
#
# The db is always sorted; i.e. the entry with the oldest scheduled
# execution time is first.
#


function readScheduleDb()

    if !Snips.dbHasEntry(:scheduler)
        return Dict[]
    end

    db = Snips.dbReadValue(:scheduler, :db)
    if db == nothing
        return Dict[]
    else
        return db
    end
end

function addAction!(db, action)

    action[:create_time] = Dates.now()
    if !haskey(action, :topic)
        action[:topic] = "qnd/trigger/andreasdominik:ADoSnipsScheduler"
    end
    if !haskey(action, :origin)
        action[:origin] = "ADoSnipsScheduler"
    end
    push!(db, action)
    sort!(db, by = x->x[:execute_time])
    Snips.dbWriteValue(:scheduler, :db, db)
    return db
end


function rm1stAction!(db)

    if length(db) > 0
        deleteat!(db, 1)
    end
    Snips.dbWriteValue(:scheduler, :db, db)
    return db
end


function rmActions!(db, deletion)

    if deletion[:mode] == "delete all"
        mask = [true for x in db]

    elseif deletion[:mode] == "delete by topic"
        mask = [x[:topic] == deletion[:topic] for x in db]

    elseif deletion[:mode] == "delete by origin"
        mask = [x[:origin] == deletion[:origin] for x in db]

    else
        mask = [false for x in db]
    end

    deleteat!(db, mask)
    Snips.dbWriteValue(:scheduler, :db, db)
    return db
end

"""
    function isDue(action)

Check, if the scheduled execution stime of action is in the past
and return `true` or `false` if not.
"""
function isDue(action)

    if haskey(action, :execute_time)
        return Dates.DateTime(action[:execute_time]) < Dates.now()
    else
        return false
    end
end


function runAction(action)

    Snips.printLog("SystemTrigger $(action[:topic]) published by scheduler.")
    Snips.publishSystemTrigger(action[:topic], action[:trigger][:trigger])
end
