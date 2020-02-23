# Daemons and components

## Hotword detection

By default, Snowboy is used as hotword detector, because of its high
accuracy.


## Record

The Swiss Army knife of sound processing programs (SoX - Sound eXchange)
is used as default recording service.
The following rec-command records audio with the configuration:
* maximum lenght $TIME_MAX seconds
* wait with recording until a sound is detected (no silence)
* stop recording if 1 second of silence is recorded
* remix to one channel
* use a bitrate of 16000
* add 10 dB of gain
```
rec --rate 16000 $AUDIO \
    trim 0 $TIME_MAX \
    silence 1 0:00.05 $NOISE 1 $END_TRIGGER $NOISE \
    remix 1-2 \
    gain 10
```

## Speech to text (STT)

Speech recognition is the cruical part of every assistant.
Unfortunately not very much open software with the desired quality
is available currently.

The ASR component of Snips takes its power from the integration with
NLU; i.e. the ASR knows all sentences and phrases that must be
recognised and hence the language model can be adapted to each individual
assistant.
Because the Snips Console (the Web-interface to Snips ASR and NLU) is no longer
open for the public, it is no longer possible to train the
speech recognition for new skills.

As an alternative approach, general speech-to-text-services that can transcribe
arbitrary text can be used.
However, there is only a small number of potentially usable open software
available.
Best chances may provide Mozilla DeepSpeech.

In contrast, commercial web-services with almost perfect quality are availble,
such as:
* Google Cloud Speech-to-Text (https://cloud.google.com/speech-to-text/),
* Wit.ai (https://wit.ai),
* Google Dialogue Flow (https://dialogflow.com/),
* Microsoft Cognitive Services (https://azure.microsoft.com/en-us/services/cognitive-services),
* Watson Speech to Text (https://www.ibm.com/cloud/watson-speech-to-text),
* Speechmatics (https://www.speechmatics.com/),
* Amazon (https://aws.amazon.com/transcribe/)
* etc.

All of them require sending
the recorded audio to the server somewhere in the internet,
which breaks the privacy we are used to with Snips.ai.

However, speech recognition technology develops very fast and using a
cloud service may be necessary for a period of transition, until
locally installed and *open* software is available.


#### Google Cloud STT
The Google Cloud connector is configured by default in Susi, because of the
very high quality of the transcriptions.
The service ist sensitive, accurate available for many
languages and has a good common knowlegde (knows names of famous persons,
titles of movies and TV shows, etc.).


#### Mozilla DeepSpeech
As an alternative to the Google Cloud services Mozilla DeepSpeech can be used.
However,
- trained models and language models are only available for English langage
- the quality of transcription seems not to be sufficient for an assistant
  (at least in my tests - this may differ for other speakers and different
  hardware)
- a transcription needs 2-5 seconds.

However, it is easily possible to set up a separate STT-server with
sufficient CPU power (and maybe a GPU) and integrate it to Susi.


#### IBM Cloud services

Transcription quality  of IBM Cloud STT is sufficent for an assistant.
(At least) in Europe the latency is smaller compared to the Google service
(approx. half).

## Text to speech (TTS)
#### Google Cloud TTS
Google's text to speech service is used as default service, because it
provides the most realistic voices.
In order to reduce calls to the Google Cloud, all retrieved audio will be cached
and reused if the same sentence is needed again.

Available voices can be tested here: https://cloud.google.com/text-to-speech.

#### Mozilla
Mozilla's Deep Voice is not yet implemented.

#### IBM Cloud TTS
The connector to the IBM Clouds text-to-speech service is alrady
included in the distribution. It can be selected by uncommenting the
respective line for the binary in the `[tts]`-section of the
configuration file 'susi.toml'.

Please notice, that there are different credentials for STT and TTS.

Example voices can be listened to at:
https://www.ibm.com/de-de/cloud/watson-text-to-speech and
https://cloud.ibm.com/docs/text-to-speech?topic=text-to-speech-voices.

## Play

Susi's play component uses linux sox play (SoX - Sound eXchange).
The play.daemon subscribes to the topic 'susi/playserver/request'with a
payload that include a base64-encoded audio file and the siteId on
which the audio must be played.

The daemon can play all audio formats that sox play is able to play
(for mp3 'libsox-fmt-mp3' must be installed).

The length of the audio is not limited.

It is recommended not to send requests directly to the play daemon, but use the
session manager API instead (topic: 'susi/play/playAudio'). This ensures that
timeouts are postponed during playing.


## Session manager

The session manager runs sequences of
actions, such as `hotword -> record -> stt -> nlu -> publish intent`
and takes care of timeouts and non-responding components.




## NLU - natural language understanding

The NLU component replaces the Snips NLU and is independent from the
Snips console.
It is configured only with a configuration file `nlu-xx.toml` for
each skill, where 'xx'
denotes a 2-letter language code. The nlu configuration files must be present
somewhere in the skills directory.

The files are in standard toml format, constisting of
'key' -> 'value' pairs or 'key' -> 'list' pairs. Lists with only one
entry may be written as values (without brackets).

The nlu.xx.toml file includes the parts:

#### head

The head defines the name of the configured skill and the name of the skill
developer (the developer name is used to generate Snips-compatible
intent names).

The inventory section lists all intents and slots configured and
used in the file:

```
# head:
#
skill = "RollerShutter"
developer = "andreasdominik"

[inventory]
intents = ["RollerUpDown"]
slots = ["room", "device", "Action"]
```

#### Slot definitions

For each listed slot, a slot definition section must be present in the
toml file, including the keys `slot_type`, optional `allow_empty` and
an optional sub-section `<slotname>.synonyms`:

```
# slot definitions:
#
[room]
slot_type = "ListOfValues"
allow_empty = true

        [room.synonyms]
        "house" = ["everywhere", "in the house", "house"]
        "dining" = ["dining room", "dining"]
        "stairs" = ["staircase", "stairs"]
        "kitchen" = "kitchen"
        "bedroom" = ["bedroom", "parents bedroom"]
```

**slot_type** is one of 'ListOfValues', 'Any', 'Number', 'Ordinal' or 'Time';
see below for details.    
If **allow_empty** is specified as true, an expression will match, even if the
slot is not parsed. If the key 'allow_empty' is missing, the default
`false` is assumed.

##### Slot type ListOfValues

A slot type 'ListOfValues' needs a mandatory subsection with synonymes,
consisting of alternatives with a name and a list of values.
In contrast to Snips, the names are not included in the list.

When parsing a command the slot will match if one of the words or phrases
in one of the lists is recognised, and the name of the respective
synonym is returned as slot value.
This way it is easy to write language-independent skill code, because
the returned slot values are indepentent from the actual parsed commands.


##### Slot type Any

A slot of tyle 'Any' will match any word or phrase.

In addition it is possible to add synonyms to a slot of type Any.


##### Slot types Number, Ordinal and Time

Slots of one of these types will be extracted from the command
and passed to Duckling to get a number or timestring.


#### Intent definition
The last part of the configuration file holds *match phrases*, which are
compared with transcribed commands to identify intents (actions to be
executed within skills) and to extract slot values.
The following rukles apply:
* each intent is configured in a separate section of the toml file
  `[intentname]`
* several match phrases may be defined for each intent
* each match phrase constists of a *name*, a *type* and the phrase to be
  matched
* match phrases are matched in alphabetic order of their names
* a match phrase can be of type 'regex', 'complete', 'partial' or
  'ordered'.

##### match phrase type regex
It is possible to write match phrases as Perl-compatible regular expresisons
with a syntax, provided b ythe PCRE library (see http://www.pcre.org/current/doc/html/pcre2syntax.html for the syntax).
Slots are defined as named capture groups with the slot name as capture
group name.


##### match phrase type complete
To avoid the need to writing plain regular expressions, the types
'complete', 'partial' and 'ordered' provide an easier interface.

For complete', the phrase is just a sentence that must
match completely, with several types of placeholders allowed:

* **<<slotname>>:** the slot is expected at this position.
  If the slot si configured as `allow_empty = true`, the phrase will
  match even if the slot is not present.
* **<<word1|words and more|word3>>:** one of the listed words or phrases
  is expected at this position. Words are separated by the pipe charater `|`.
  An empty alternative (<<word1|words and more|>> or <<word1||words and more>>)
  will match missing words as well.
* **<<>>:** the empty placeholder will match exactly one or no words.

Examples:    
the match phrase  
```
[RollerUpDown]
roller_a = "complete: <<action>> the <<rollershutter|roller>> <<in|>> <<the|>> <<room>>"
```
will match the commands `"Open the rollershutter in the kitchen"` and
`"Open the rollershutter in kitchen"` as well as
`"Open the rollershutter"`, because the placeholders "<<in|>>" and "<<the|>" allow
empty values and "<<room>>" is allowed to be empty as well.

However the match phrase will **not** match
`"Please open the rollershutter in the kitchen"`, because not the complete
phrase mathes.

To be more specific optional words may be added, such as
```
roller_b = "complete: <<please|>> <<action>> the <<rollershutter|roller>> <<in|>> <<the|>> <<room>> <<please|>>"
```

##### match phrase type partial
Match phrases of type 'partial' follow the same rules as of type 'complete',
with the difference that only parts of the command must match the phrase.

Examples:
the match phrase
```
[RollerUpDown]
roller_b = "partial: <<action>> the <<rollershutter|roller>> <<in|>> <<the|>> <<room>>"
```
will match `"Please open the rollershutter in the kitchen"`
as well as `"Please open the rollershutter in the kitchen and get me a coffee"`.


##### match phrase type ordered
Match phrases of type 'ordered' follow the same rules but are more
vague, as only all words of the match phrase must be present in the
command in the correct order. Additional words may be present before,
after or inbetween.


#### Example file nlu-xx.toml for the rollershutter skill:

A complete (but very simple and not yet sufficent) example nlu configuration
file is shown in a version vor 3 different languages.
It must be pointet out, that the slot values extracted to the intent
are exactly the same for all languages, which makes it easy to
write language-intependant skill code.


##### nlu-en.toml
```
# nlu definition for RollerShutter skill
#
# head:
#
skill = "RollerShutter"
developer = "andreasdominik"

[inventory]
intents = ["RollerUpDown"]
slots = ["room", "Action"]


# slot definitions:
#
[room]
slot_type = "ListOfValues"
allow_empty = true

        [room.synonyms]
        "house" = ["everywhere", "in the house", "house"]
        "dining" = ["dining room", "dining"]
        "stairs" = ["staircase", "stairs"]
        "kitchen" = "kitchen"
        "bedroom" = ["bedroom", "parents bedroom"]

[action]
slot_type = "ListOfValues"

        [action.synonyms]
        "open" = ["open", "up"]
        "close" = ["close", "down", "shut"]

# match phrases for intent recognion:
#
[RollerUpDown]
roller_a = "partial: <<action>> the <<rollershutter|roller>> <<in|>> <<the|>> <<room>>"
roller_b = "complete: <<please|>> make the <<rollershutter|roller>> in the <<room|>> <<room>> <<action>> <<please|>>"
roller_c = "partial: make the <<rollershutter|roller>> <<>> <<action>>"
```



##### nlu-fr.toml
```
# nlu definition for RollerShutter skill
#
# head:
#
skill = "RollerShutter"
developer = "andreasdominik"

[inventory]
intents = ["RollerUpDown"]
slots = ["room", "Action"]


# slot definitions:
#
[room]
slot_type = "ListOfValues"
allow_empty = true

        [room.synonyms]
        "house" = ["partout dans la maison", "dans toute la maison", "maison"]
        "dining" = "salle à manger"
        "stairs" = ["cage d'escalier"]
        "kitchen" = "cuisine"
        "bedroom" = ["chambre"]

[action]
slot_type = "ListOfValues"

        [action.synonyms]
        "open" = ["ouvrir", "ouvrez"]
        "close" = ["fermez"]

# match phrases for intent recognion:
#
[RollerUpDown]
roller_a = "<<veuillez|>> <<action>> <<le volet roulant|les volets|le volet>> <<de la|dans la|>> <<room>> <<s'il vous plaît|>>"
```


##### nlu-de.toml
```
# nlu definition for RollerShutter skill
#
# head:
#
skill = "RollerShutter"
developer = "andreasdominik"

[inventory]
intents = ["RollerUpDown"]
slots = ["room", "Action"]


# slot definitions:
#
[room]
slot_type = "ListOfValues"
allow_empty = true

        [room.synonyms]
        "house" = ["überall", "im ganzen Haus", "Haus"]
        "dining" = "Esszimmer"
        "stairs" = ["Treppenhaus", "Treppe"]
        "kitchen" = "Küche"
        "bedroom" = ["schlafzimmer"]

[action]
slot_type = "ListOfValues"

        [action.synonyms]
        "open" = ["auf", "nach oben", "öffne"]
        "close" = ["zu", "herunter", "runter", "schließe"]

# match phrases for intent recognion:
#
[RollerUpDown]
roller_a = "partial: <<bitte|>> <<action>> <<bitte|>> den <<Rolladen|Rollo>> <<in der|im|>> <<room>>"
roller_c = "partial: mach <<bitte|>> den <<Rolladen|Rollo>> <<in der|im>> <<room>> <<action>>"
roller_d = "partial: mach <<bitte|>> den <<Rolladen|Rollo>> <<action>>"
```
