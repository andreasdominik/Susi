#
# functions to read and write status db
#
# The db looks like:
# {
#     "irrigation" :
#     {
#         "time" : <modification time>,
#         "writer" : "ADoSnipsIrrigation",
#         "payload" :
#         {
#             "status" : "on",
#             "next_status" : "off"
#         }
#     }
# }
#

"""
    dbWritePayload(key, payload)

Write a complete payload to a database entry.
The payload is overwitten if the entry already exists,
or created otherwise.

## Arguments
- `key`: unique key of the database entry of
         type `AbstractString` or `Symbol`
- `payload`: payload of the entry with key `key`
         to be written.
- `value`: value to be stored in the field.
"""
function dbWritePayload(key, payload)

    if ! (key isa Symbol)
        key = Symbol(key)
    end

    if !dbLock()
        return false
    end

    db = dbRead()

    if haskey(db, key)
        entry = db[key]
    else
        entry = Dict()
        db[key] = entry
    end

    entry[:time] = Dates.now()
    entry[:writer] = CURRENT_APP_NAME
    entry[:payload] = payload

    dbWrite(db)
    dbUnlock()
end

"""
    dbWriteValue(key, field, value)

Write a field=>value pair to the payload of a database entry.
The field is overwitten if the entry already exists,
or created elsewise.

## Arguments
- `key`: unique key of the database entry of
         type `AbstractString` or `Symbol`
- `field`: database field of the payload of the entry with key `key`
         to be written (`AbstractString` or `Symbol`).
- `value`: value to be stored in the field.
"""
function dbWriteValue(key, field, value)

    if ! (key isa Symbol)
        key = Symbol(key)
    end
    if ! (field isa Symbol)
        field = Symbol(field)
    end

    if !dbLock()
        return false
    end

    db = dbRead()
    if haskey(db, key)
        entry = db[key]
    else
        entry = Dict()
    end

    if !haskey(entry, :payload)
        entry[:payload] = Dict()
    end

    entry[:payload][field] = value
    entry[:time] = Dates.now()
    entry[:writer] = CURRENT_APP_NAME

    db[key] = entry
    dbWrite(db)
    dbUnlock()
end


"""
    dbHasEntry(key)

Check if the database has an entry with the key `key`
and return `true` or `false` otherwise.

## Arguments
- `key`: unique key of the database entry of
         type `AbstractString` or `Symbol`
"""
function dbHasEntry(key)

    if ! (key isa Symbol)
        key = Symbol(key)
    end

    db = dbRead()
    return haskey(db, key)
end



"""
    dbReadEntry(key)

Read the complete entry with the key `key` from the
status database
and return the entry as `Dict()` or nothing if not in the database.

## Arguments
- `key`: unique key of the database entry of
         type `AbstractString` or `Symbol`
"""
function dbReadEntry(key)

    if ! (key isa Symbol)
        key = Symbol(key)
    end

    db = dbRead()
    if haskey(db, key)
        return db[key]
    else
        printLog("Try to read entry for unknown key $key from status database.")
        return nothing
    end
end


"""
    dbReadValue(key, field)

Read the field `field` of the  entry with the key `key` from the
status database
and return the value or nothing if not in the database.

## Arguments
- `key`: unique key of the database entry of
         type `AbstractString` or `Symbol`
- `field`: database field of the payload of the entry with key `key`
         (`AbstractString` or `Symbol`).
"""
function dbReadValue(key, field)

    if ! (key isa Symbol)
        key = Symbol(key)
    end
    if ! (field isa Symbol)
        field = Symbol(field)
    end

    db = dbRead()
    if haskey(db, key) &&
       haskey(db[key],:payload) &&
       haskey(db[key][:payload],field)
        return db[key][:payload][field]
    else
        printLog("Try to read value for unknown key $key from status database.")
        return nothing
    end
end






"""
    dbRead()

Read the status db from file.
Path is constructed from `config.ini` values
`<application_dir>/ADoSnipsQnD/<database>`.
"""
function dbRead()

    db = tryParseJSONfile(dbName(), quiet = true)
    if length(db) == 0
        printLog("Empty status DB read: $(dbName()).")
        db = Dict()
    end

    return db
end


"""
    dbWrite()

Write the status db to a file.
Path is constructed from `config.ini` values
`<application_dir>/ADoSnipsQnD/<database>`.
"""
function dbWrite(db)

    if !ispath( dbPath())
        mkpath( dbPath())
    end

    fname = dbName()
    open(fname, "w") do f
        JSON.print(f, db, 2)
    end
end




function dbLock()

    if !ispath( dbPath())
        mkpath( dbPath())
    end
    lockName = dbName() * ".lock"

    # wait until unlocked:
    #
    waitSecs = 10
    while isfile(lockName) && waitSecs > 0
        waitSecs -= 1
        sleep(1)
    end

    if waitSecs == 0
        printLog("ERROR: unable to lock home database file: $dbName")
        return false
    else
        open(lockName, "w") do f
            println(f, "database is locked")
        end
        return true
    end
end

function dbUnlock()

    lockName = dbName() * ".lock"
    rm(lockName, force = true)
end



function dbName()

    name = getConfig(:database_file)
    if name ==  nothing
        name = "$(dbPath())/home.json"
    else
        name = "$(dbPath())/$name"
    end
    return name
end



function dbPath()

    path = getConfig(:application_data_dir)
    if path ==  nothing
        path = "./ADoSnipsQnD"
    else
        path = "$path/ADoSnipsQnD"
    end
    return path
end
