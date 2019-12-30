# How to write a new skill

Starting with a new skill can be done by adapting the template skill
to your needs. However, several files need to be modified. Therefore
a shell script is provided, which takes care of the major part of the
modifications.

This brief tutorials guides through the process of
making a new skill using the init script and template in Julia language.


## Set up the framework (if starting from scratch)

Create a directory in which the skills will be developed, such as
`~/Documents/Snips/` and make a clone of the framework project at
GitHub (install the git software before, if necessary):

```bash
$ ~/Documents/Snips/
$ cd  ~/Documents/Snips/
$ git clone git@github.com:andreasdominik/ADoSnipsQnD.git
```

Now you have the source code of the framework in a local clone in
the directory `~/Documents/Snips/ADoSnipsQnD/`.


## Set up the skeleton a new project

Before strating, prepare to give the init-script some information:
- *name of the new skill:* the name must not contain any whitespace,
      must be unique within your Snips skills,
      and must be unique within your GitHub repositories.
      The example below will create a skill to control an Amazon Fire device.
      Therefore in this tutorial the name `MyFire` will be used as example.
- *your GitHub name:* create a GitHub account if necessary.
- *your gitHub password:* name and password are needed, because the script will
      initialise a new GitHub repo for the new project.

The script `init.sh` in the directory `/bin` will create
the skeleton of a new skill. Enter (or stay in) the directory
`~/Documents/Snips/` and run the script:

```bash
$ cd ~/Documents/Snips
$ ./ADoSnipsQnD/bin/init.sh
```

Now provide the prepered information and follow the instructions of the script.
At the end, the skeleton of a skill is created, committed into the
git repo and pushed to GitHub.

All file- and directory names can be left unchanged.
The skill has no file `action-...` as demanded by the Snips skill server,
because all SnipsHermesQnD-skills will run in the same Julia process. Only
the framework it self has the starter function `action-ADoSnipsQnD.jl`,
all other skills have loader functions `loader-...` instead, which are
recognised by the framework and loaded into the running instance.


## Files in the sceleton

The created skeleton consists of several files, but only some of them need to be
adapted for a new skill.

filename | comment | needs to be adapted
---------|---------|--------------------
`loader-MyFire.jl` | generated loader function for the framework | no
`config.ini`       | ini file as default in Snips                | yes
`setup.sh`         | setup file as default in Snips              | yes
`api.jl`           | source code of Julia low-level API for a controlled device | optional
`config.jl`   | global initialisation of a skill                 | yes
`exported.jl` | generated exported functions of the skill module  | no
`languages.jl`| text fragments for multi-language support        | optional
`skill-actions.jl` | functions to be executed, if an intent is recognised | yes
`MyFire.jl`        | the julia module for the skill              | no

In a minimum-setup only 2 things need to be adapted for a new
skill:
- the action-functions which respond to an intent (the *direct* action, no callback)
  must be definded and implemented (in `skill-actions.jl`)
- the action-functions must be connected with the corresponding intent names
  (in `config.jl`).

Optionally, more fine-grained software engineering is possible by
- separating the user-interaction from the API of controlled devices (latter
  will go to `api.jl`).
- adding multi-language support, by specifying phrases in different languages
  (`languages.jl`) and by using different intents, depending on the language
  defined in `config.ini`.
- the `setup.sh` file has the same function as in every Snips skill: setup
  the environement for the skill and install dependencies.
  In case of the QnD framework main purpose of `setup.sh` is to install
  Julia packages, necessray for a skill. The framework only installs
  the packages `JSON` and `StatsBase`. Additional packages can be installed
  by uncommenting the respective line in the file and adding the
  required dependency.

## Example with low-level API

This tutorial shows how a skill to control an external device
can be derived from the template.

The idea is to control an Amazon fire stick with a minimum set of commands
`on, off, play, pause`.
More commands can be implement easily the same way.

Switching on and off is implemented based on the common on-off-intent,
included in the framework.


### The Amazon fire low-level API

The low-level API which sends commands to the Amazon fire is borrowed from
Matt's ADBee project (`git@github.com:mattgyver83/adbee.git`) that provides
a shell-script to send commands to the Amazon device.
Please read there for the steps to prepare the Amazon device for
the remote control via ADB.

Although Python programmes usually find Python packages for every task, it is
a very good idea to implement the lowest level of any device-control API
as a shell script. Advantages:
- easy to write
- fast and without any overhead
- easy to test: the API can be tested by running the script
  from the commandline as `controlFire ON` or `controlFire OFF` and see
  what happens.

 The simplified ADBee-script is:

```sh
#!/bin/bash -xv
# control fireTv via adb

COMMANDS=$@
IP=amazon-fire  # set to 192.168.1.200 by dhcp
PORT=5555
ADB=adb
SEND_KEY="$ADB -s $IP:$PORT shell input keyevent"

adb connect amazon-fire

for CMD in $COMMANDS ; do
  case $CMD in
    wake)
      $SEND_KEY KEYCODE_WAKEUP
      ;;
    sleep)
      $SEND_KEY KEYCODE_POWER
      ;;
    play)
      $SEND_KEY KEYCODE_MEDIA_PLAY_PAUSE
      ;;
    pause)
      $SEND_KEY KEYCODE_MEDIA_PLAY_PAUSE
      ;;
    # more commands may go here ...
  esac
done
```

Once this script is tested, the Julia API can be set up.


### The Julia API

By default the API goes into the file api.jl, which is empty
in the template.

In this case only a wrapper is needed, to make the API-commands
available in the Julia program.
The framework provide a function `tryrun()` to execute external
commands safely (i.e. if an error occures, the program will not crash,
but reading the error message via Hermes text-to-speech).

This API definition splits in the function to execute the ADBee-script and
functions to be called by the user:

```Julia
function adbCmds(cmds)

    return tryrun(`$ADB $(split(cmds))`, errorMsg =
            """An error occured while sending commands $cmds
            to Amazon fire."""
end




function amazonON()
    adbCmds("wake")
end

function amazonOFF()
    adbCmds("sleep")
end

function amazonPlay()
    adbCmds("play")
end

function amazonPause()
    adbCmds("pause")
end
```


### The skill-action for on/off

This functions are executed by the framework if an intent is
recognised.
The functions are defined in the file `skill-actions.jl`.
On/off is handled via the common on/off-intent, all other actions
need a specific intent, that must be set up in the Snips console.

The constant `DEVICE_NAME`, used in the example, must be defined
somewhere (by default constants are defined in `config.jl`):

```Julia
"""
    powerOnOff(topic, payload)

Power on or of with SnipsHermesQnD mechanism.
"""
function powerOnOff(topic, payload)

    if isOnOffMatched(payload, DEVICE_NAME) == :on
        Snips.publishEndSession("I wake up the Amazon Fire Stick.")
        amazonON()
        return true

    elseif isOnOffMatched(payload, DEVICE_NAME) == :off
        Snips.publishEndSession("I send the Amazon Fire Stick to sleep.")
        amazonOFF()
        return true

    else
        return false
    end
end
```

Returning `false` will disable the *continue without hotword* function; i.e.
a hotword is necessary before the next command can be uttered.
This is necessary for the default-case, because probably a different
app will execute this non-recognised command.

In order to ensure that the framework accepts on-off-commands for the new
device, it must be added to the list of handled devices in the `config.ini`
of the framework. The Amazon Fire Stick is already defined as device-type
in the slot `device` of the intent.

```
on_off_devices=floor_light,light,amazon_fire
```


### The skill-action for all other commands

All other commands must be handled by an intent that you must
create in the Snips console.
Let's assume the intent has the name `MyFire` and delivers
the command in the slot `Command`.
The slot should know all known commands with synonyms.

To handle this, a second skill-action has to be defined in the file
`skill-actions.jl`:

```Julia
"""
    commands(topic, payload)

Send commands to Amamzon device.
"""
function commands(topic, payload)

    if Snips.isInSlot(payload, SLOT_NAME, "play")
        Snips.publishEndSession("I play the current selection!")
        amazonPlay()
        return true

    elseif Snips.isInSlot(payload, SLOT_NAME, "pause")
        Snips.publishEndSession("I pause the movie.")
        amazonPause()
        return true

    else
        Snips.publishEndSession("I cannot respond!")
        return true
    end
end
```


### Tying everything together

The last step is to tell the skill the names of intents to listen to
and the names of the slots to extract values from.
Both is defined in the file `config.jl`:

- The slot names are simply defined as global constants
  (they are global within the module MyFire).
- Intents and respective functions are stored in the background
  and registered with the function `registerIntentAction()`.

```Julia
const SLOT_NAME = "Command"
const DEVICE_NAME = "amazon_fire"

...

Snips.registerIntentAction("AdoSnipsOnOffEN", powerOnOff)
Snips.registerIntentAction("MyFire", commands)
```

Once the functuions are registered together with the intents,
the framework will execute the functions.
