# Susi

Susi (SUsi is not SnIps) is a replacement for the Snips
home assistant ecosystem. It follows mainly the same architecture as
Snips (with a MQTT broker as central unit and MQTT messages exchanged
between the components).
Consequently most native Snips skills will run with Susi as well but without
the need of the (no longer available) Snips console.

Susi is build as a modular system as a collection of
of daemons (hotword detection, record, speech to text,
intent recognion, play, skill managment).
Most daemons are lightweight bash scripts responsible for communication with
other daemons via MQTT messages. The actual workers for the respective functionality
can be configured separately and hence can be replaced easily.


## Main components
All components run standalone on one or more satellites of the installation
and communicate with each other and with the session manager via MQTT.

A default session includes the following components and steps:

#### MQTT broker
A `mosquitto` MQTT broker ist started by the susi service.
Hostname, port, login and password must be configured in the `/etc/susi.toml`
files of all satellites.

#### Hotword detection
An hotword detector must run on all sattelites, on which voice commands
need to be detected.
The detector program must publish a MQTT-topic with topic `hermes/hotword/detected`
and the siteId as payload.


#### Record service
A record service must run on all sattelites, on which voice commands
need to be detected.
It subscribes to the MQTT-topic `hermes/asr/startListening`. If a message
with the correct siteId is received, it records a voice command and publishes
a message with topic `susi/asr/audioCaptured` and the base64-encoded recording
in flac-format.
The payload id matches the id of the request.


#### Speech-to-text service
A speech-to-text service runs only once for an installation.
It subscribes to the MQTT-topic `susi/asr/transscribe`. If a message
is received, it extracts text from the audio and publishes
a message with topic `hermes/asr/textCaptured` with the
transcribed text as payload.
The payload id matches the id of the request.

#### Natural language understanding
A NLU service runs only once for an installation.
It subscribes to the MQTT-topic `hermes/nlu/query`. If a message
is received, it extracts text from the audio and publishes
a message with topic `hermes/nlu/intentParsed`
with the recognised skill intent as payload or
`hermes/nlu/intentNotRecognized`.
The payload id matches the id of the request.

#### Session manager
The session manager runs only once for an installation.
It orchestrates session sequences (like the one described above)
starts, queues and ends sessions and publishes
final intents.

#### Skill manager
Skills are standalone programs that may run on any computers of
a Susi installation.  Each skill must subscribe to the
topics of its intents (such as `/hermes/intent/andreasdominik:LightOn`) and
execute the requested actions.

Susi's skill manager makes sure, that all skills located in the skills
directory are running (all skills with name pattern `action-...` wil be started
with the susi service and restarted if they crash).

#### Play service
A play service must run on all sattelites, on which audio output is
required.
It subscribes to the MQTT-topic `susi/playserver/request`. If a message
with the correct siteId is received, it playsteh audio included in the
payload and publishes
a message with topic `susi/playserver/playFinished`.
The payload id matches the id of the request.

#### Text-to-speech service
A text-to-speech service runs only once for an installation.
It subscribes to the MQTT-topic `susi/tts/request`. If a message
is received, it geberates an aodio of the text and publishes it as
payload of  
a message with topic `susi/tts/audio`.
The payload id matches the id of the request.



## Skills

As all main MQTT topics are comaptible with the respective Snips.ai-topics,
all Snips-skills shold run with Susi.
However it is recommended, not to use Snips' Hermes framework for
Python for skill development. Instead, the Julia-framework
ADoSnipsQnD supports writing skills (for Snips and Susi)
in the modern and fast programming language Julia and makes it simple to
develop skills with multilanguage support and extensive user interaction.

Currently supported and tested skills include:

+ ADoSnipsLights
+ ADoSnipsKodi
+ ADoSnipsTVViera
+ ADoSnipsWakeup
+ ADoSnipsRollerShutter
+ ADoSnipsIrrigation
+ ADoSnipsDoNotListen
+ ADoSnipsAutomation
+ SusiTime
