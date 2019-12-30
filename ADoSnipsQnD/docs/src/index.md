# ADoSnipsQnD

This is a "quick-and-Dirty" framework for Snips.ai
written in Julia.
I comes with a template skill (gitHub project: `SnipsADoTemplate`)
which can be used as starting point for own skills.

To learn about Snips, goto [snips.ai](https://snips.ai/.)

To get introduced with Julia, see [julialang.org](https://julialang.org/.)


## Similarities and differences to the Hermes dialogue manager

The framework allows for setting up skills/apps the same way as
with the Python libraries. However, according to the more functional
programming style in Julia, more direct interactions are provided
and
technical stuff (such as siteId, sessionId, callback-functions, etc.)
are handled transparently by the framework in the background.

As an example, the function `listenIntentsOneTime()` can be used
without a callback-function. Recognised intent and payload
are returned as function value.

On top of `listenIntentsOneTime()`, SnipsHermesQnD comes with
a simple question/answer methods to
ask questions answered with *Yes* or *No*
(`askYesOrNo()` and `askYesOrNoOrUnknown()`).
As a result, it is possible to get a quick user-feedback without leaving
the control flow of a function, like illustrated in this skill action:

```Julia
"""
    destroyAction(topic, payload)

Initialise self-destruction.
"""
function destroyAction(topic, payload)

  # log message:
  Snips.printLog("[ADoSnipsDestroyYourself]: action destroyAction() started.")

  if Snips.askYesOrNo("Do you really want to initiate self-destruction?")
    Snips.publishEndSession("Self-destruction sequence started!")
    boom()
  else
    Snips.publishEndSession("""OK.
                            Self-destruction sequence is aborted!
                            Live long and in peace.""")
  end

  return true
end
```
