#
# actions called by the main callback()
# provide one function for each intent, defined in the Snips Console.
#
# ... and link the function with the intent name as shown in config.jl
#
# The functions will be called by the main callback function with
# 2 arguments:
# * MQTT-Topic as String
# * MQTT-Payload (The JSON part) as a nested dictionary, with all keys
#   as Symbols (Julia-style)
#
"""
function ignoreDevice(topic, payload)

    Ignore (i.e. end session) when unified OnOff-Intent is recognised for
    a unhandled device.
"""
function ignoreDevice(topic, payload)

    Snips.printLog("action ignoreDevice() started.")
    # find the device in payload:
    #
    device = Snips.extractSlotValue(payload, SLOT_DEVICE)

    # test if is in list of devices to be handled:
    #
    if !(device isa AbstractString)
        Snips.printLog("no device: ignored and session ended.")
        Snips.publishEndSession("$(TEXTS[:not_handled])")
        return true     # no hotword needed for next command

    elseif !Snips.matchConfig(INI_NAMES, device)
        # Snips.printDebug("Device: $device, List: $(Snips.getConfig(INI_NAMES))")
        Snips.printLog("device $device ignored and session ended.")
        Snips.publishEndSession("$(TEXTS[:not_handled]) $device")
        return true     # no hotword needed for next command
    else
        # just ignore and let another app deal with the session...
        #
        return false    # hotword needed for next command
    end
end


"""
    schedulerAction(topic, payload)

Trigger action for the scheduler. Each schedulerTrigger must
contain a trigger and an execution time for the trigger.

## Trigger: add new schedule

A scheduler trigger addresses the scheduler (as target) and must
include a list of complete trigger objects as payload (i.e. trigger):
```
{
  "origin": "Main.ADoSnipsAuto",
  "topic": "qnd/trigger/andreasdominik:ADoSnipsSchedule",
  "siteId": "default",
  "sessionId": "7dab7a26-84fb-4855-8ad0-acd955408072",
  "trigger": {
    "mode": "add schedules",
    "sessionId": "7dab7a26-84fb-4855-8ad0-acd955408072",
    "siteId": "default",
    "time": "2019-08-26T14:07:55.623",
    "origin": "ADoSnipsAuto",
    "actions": [
      {
        "topic": "qnd/trigger/andreasdominik:ADoSnipsLights",
        "origin": "ADoSnipsAuto",
        "execute_time": "2019-08-28T10:00:20.534",
        "trigger": {
          "settings": "undefined",
          "device": "floor_light",
          "onOrOff": "OFF1",
          "room": "default"
        }
      },
      {
        "topic": "qnd/trigger/andreasdominik:ADoSnipsLights",
        "origin": "ADoSnipsAuto",
        "execute_time": "2019-08-28T10:00:20.534",
        "trigger": {
          "settings": "undefined",
          "device": "floor_light",
          "onOrOff": "OFF2",
          "room": "default"
        }
      }
    ]
  }
}
```

## Trigger: delete schedules

The trigger can delete **all** schedules or all schedules
for a specific trigger. The field `topic` is ignored for `mode == all`:
```
{
  "origin": "Main.ADoSnipsTemplate",
  "topic": "qnd/trigger/andreasdominik:ADoSnipsSchedule",
  "siteId": "default",
  "sessionId": "7dab7a26-84fb-4855-8ad0-acd955408072",
  "trigger": {
    "mode": "delete all",
    "sessionId": "7dab7a26-84fb-4855-8ad0-acd955408072",
    "siteId": "default",
    "topic": "dummy",
    "origin": "dummy",
    "time": "2019-08-26T14:07:55.623"
  }
}
```
"""
function schedulerAction(topic, payload)

    global actionChannel

    Snips.printLog("trigger action schedulerAction() started.")


    if !haskey(payload, :trigger)
        Snips.printLog("ERROR: Trigger for ADoSnipsScheduler has no payload trigger!")
        return false
    end
    trigger = payload[:trigger]
    if !haskey(trigger, :origin)
        trigger[:origin] = payload[:origin]
    end

    if !haskey(trigger, :mode)
        Snips.printLog("ERROR: Trigger for ADoSnipsScheduler has no mode!")
        return false
    end

    # if mode == add new schedules:
    #
    if trigger[:mode] == "add schedules"
        if !haskey(trigger, :actions) || !(trigger[:actions] isa AbstractArray)
            Snips.printLog("ERROR: Trigger for ADoSnipsScheduler has no actions!")
            return false
        end

        for action in trigger[:actions]
            if !haskey(action, :topic) ||
               !haskey(action, :execute_time) ||
               !haskey(action, :trigger)
                Snips.printLog("ERROR: Trigger for ADoSnipsScheduler is incomplete!")
                return false
            end
            if !haskey(action, :origin)
                action[:origin] = trigger[:origin]
            end

            Snips.printDebug("new action found. $action")
            put!(actionChannel, action)
        end

    # else delete ...
    #
    elseif trigger[:mode] == "delete by topic"
        if !haskey(trigger, :topic)
            Snips.printLog("ERROR: ADoSnipsScheduler delete by topic but no topic in trigger!")
            return false
        end
        Snips.printLog("New delete schedule by topic trigger found: $trigger)")
        put!(deleteChannel, trigger)

    elseif trigger[:mode] == "delete by origin"
        if !haskey(trigger, :origin)
            Snips.printLog("ERROR: ADoSnipsScheduler delete by origin but no origin in trigger!")
            return false
        end
        Snips.printLog("New delete schedule by origin trigger found: $trigger)")
        put!(deleteChannel, trigger)

    elseif trigger[:mode] == "delete all"
        Snips.printLog("New delete all schedules: $trigger)")
        put!(deleteChannel, trigger)

    else
        Snips.printLog("Trigger has no valid mode: $trigger)")
    end
    return false
end
