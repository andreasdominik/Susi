# functions for the QnD scheduler
#
#


"""
    schedulerAddAction(executeTime, topic, trigger;
            sessionId = CURRENT_SESSION_ID,
            origin = CURRENT_APP_NAME,
            siteId = CURRENT_SITE_ID)

Add the `trigger` to the database of scheduled actions for
execution at `executeTime`.

## Arguments:
- `executeTime`: DateTime object
- `topic`: topic to which the system trigger will be published.
           topic has the format: `"qnd/trigger/andreasdominik:ADoSnipsLights"`.
           The prefix `"qnd/trigger/"` and the developer name are added if
           missing in the argument.
- `trigger`: The system trigger to be published as Dict(). Format of the
           trigger is defined by the target skill.

`sessionId`, `origin` and `siteId` defaults to the current
values, if not given. SessionId and origin can be used to select
scheduled actions for deletion.
"""
function schedulerAddAction(executeTime, topic, trigger;
                            sessionId = CURRENT_SESSION_ID,
                            origin = CURRENT_APP_NAME,
                            siteId = CURRENT_SITE_ID)

    action = schedulerMakeAction(executeTime, topic, trigger,
                            sessionId = sessionId, origin = origin,
                            siteId = siteId)

    scheduleTrigger = Dict(
        :origin => origin,
        :topic => "qnd/trigger/andreasdominik:ADoSnipsSchedule",
        :siteId => siteId,
        :sessionId => sessionId,
        :mode => "add schedules",
        :time => "$(Dates.now())",
        :actions => [action]
        )
    publishSystemTrigger("ADoSnipsScheduler", scheduleTrigger)
end


"""
    schedulerAddActions(actions;
            sessionId = CURRENT_SESSION_ID,
            origin = CURRENT_APP_NAME,
            siteId = CURRENT_SITE_ID)

Add all actions in the list of action objects to the database of
scheduled actions for execution.
The elements of `actions` can be created by `schedulerMakeAction()` and must
include executeTime, topic and the trigger to be published.

- `actions`: List of actions to be published. Format of the
           trigger is defined by the target skill.

`sessionId`, `origin` and `siteId` defaults to the current
values, if not given. SessionId and origin can be used to select
scheduled actions for deletion.
"""
function schedulerAddActions(actions;
                            sessionId = CURRENT_SESSION_ID,
                            origin = CURRENT_APP_NAME,
                            siteId = CURRENT_SITE_ID)

    scheduleTrigger = Dict(
        :origin => origin,
        :topic => "qnd/trigger/andreasdominik:ADoSnipsSchedule",
        :siteId => siteId,
        :sessionId => sessionId,
        :mode => "add schedules",
        :time => "$(Dates.now())",
        :actions => actions
        )

    publishSystemTrigger("ADoSnipsScheduler", scheduleTrigger)
end




"""
    schedulerMakeAction(executeTime, topic, trigger;
                            sessionId = CURRENT_SESSION_ID,
                            origin = CURRENT_APP_NAME,
                            siteId = CURRENT_SITE_ID)

Return a `Dict` in the format for the QnD scheduler.
A list of these object can be used to schedule many
actions at once via `schedulerAddActions()`.
(see documentation of `schedulerAddAction()` for details.)
"""
function schedulerMakeAction(executeTime, topic, trigger;
                            sessionId = CURRENT_SESSION_ID,
                            origin = CURRENT_APP_NAME,
                            siteId = CURRENT_SITE_ID)

    topic = expandTopic(topic)
    action = Dict(
        :topic => topic,
        :origin => origin,
        :execute_time => "$executeTime",
        :trigger => trigger
        )

    return action
end



"""
    schedulerDeleteAll()

Delete all scheduled action triggers.
"""
function schedulerDeleteAll()

    trigger = Dict(
        :mode => "delete all",
        :sessionId => CURRENT_SESSION_ID,
        :siteId => CURRENT_SITE_ID,
        :topic => "dummy",
        :origin => "dummy",
        :time => "$(Dates.now())"
        )
    publishSystemTrigger("ADoSnipsScheduler", trigger)
end


"""
    schedulerDeleteTopic(topic)

Delete all scheduled action triggers with the given topic.
"""
function schedulerDeleteTopic(topic)

    topic = expandTopic(topic)
    trigger = Dict(
        :mode => "delete by topic",
        :sessionId => CURRENT_SESSION_ID,
        :siteId => CURRENT_SITE_ID,
        :topic => topic,
        :origin => "dummy",
        :time => "$(Dates.now())"
        )
    publishSystemTrigger("ADoSnipsScheduler", trigger)
end


"""
    schedulerDeleteOrigin(origin)

Delete all scheduled action triggers with the given origin
(i.e. name of the app which cerated the scheduled action).
"""
function schedulerDeleteOrigin(origin)

    trigger = Dict(
        :mode => "delete by origin",
        :sessionId => CURRENT_SESSION_ID,
        :siteId => CURRENT_SITE_ID,
        :topic => "dummy",
        :origin => origin,
        :time => "$(Dates.now())"
        )
    publishSystemTrigger("ADoSnipsScheduler", trigger)
end
