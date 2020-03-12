## Configure Susi with `susi.toml`

The central configuration file is located at `/etc/susi.toml`.

### Configuration for all daemons

All daemons share some config entries:

* `start = "true"` defines if the daemon
  is started with the susi service or not.
* `daemoon = "xyz"` is the path to the executable that runs the daemon.
* `binary = "xyz"` is the path to the executable that does the job when
  the daemon is gets a trigger.


### Sections

The sections of the susi.toml file are:

#### [assistant]
Name and language of the assistant.

#### [local]
Work directory to store temporary files and
name of the local siteId. Each satellite needs an unique name.
If satellite is set to "true", only hotword, record and play daemon will be started
on this site.

All variants of installation are possible, such as
* running all daemons
  on one system with mic and speaker
* running one main system (e.g. in the living room) with all daemons
  started and satellites.
* running parts of the software on separate systems without mic
  or speaker, such as the skills daemon on a server only for this
  purpose or running a headless server with GPU only for STT with
  DeepSpeech. To setup such a server, just do a normal susi install
  and set all daemon start-values to false, except the one that should run.

#### [debug]
if 'show_all_stdout' is set to 'true', all daemons will echo commands to
stdout (i.e. 'set -xv').


#### [mqtt]
Host and port definitions for the MQTT broker. If empty, the default
"localhost" and port "8883" will be used. For installations with satellites
the satellites will use this setting to find the correct MQTT broker.

User and password will be used by the broker and all clients.

With the subscribe and publish entries the MQTT client binaries can be specified.
Currently only eclipse mosquitto is supported.

#### [hotword]
Configuration of the hotword daemon.
When the daemon is started, it waits for a MQTT message to toggle on
hotword detection.
* The `binary` must  point to the hotword detector (default:
  `/opt/Snowboy/rpi-arm-raspbian-8.0-1.3.0/hotword_susi.py`)
* `model_path` and `model` define the hotword model to be used.
* `notification` is useful for debugging: if "true", the specified
  sound file will be played every time the detector is toggeled on.

#### [record]
Configuration of the record daemon.

* `binary` by default points to a script that uses sox to record commands.
* `recording_limit` defines the maximum time to wait for a command
* if `notification` is set to true, a sound defined by `notification_start`
  is played every time recoding starts. If `notification_start` points to
  a directory (instead of an audio file), one randomly selected files in the
  directory will be played.    
  (if the directory contains speech files, such as "hello", "how can I help you",
  "I am your assistant", "what can I do for you", the daemon will play
  one of these sentences).

#### [play]
Configuration of the play daemon.

#### [tts]
Configuration of the tts daemon.

By default, Google TTS is used with caching because the quality of Google's
voices is very good. Caching means that an audio file of every
uttered sentence will be stored in the cache. As assistants tend to say the same
things again and again ("hello", "OK", "I copy"), only a small number calls to the webservice
is necessary after some time of operation.

Susi is prepared to use IBM Cloud services, too.
Please refer to the "Installation/Text to Speech"
section of the documentation for details of installation and cofiguration.

To change the TTS service, the `binary` parameter in the section `tts`
must be changed.

#### [stt]
Configuration of the STT daemon.
By default Google STT is used because of its very high accuracy and common
knowledge. However, it's no longer local and private.    

Mozilla DeepSpeech can be used for English language.
Susi is prepared to use IBM Cloud services or Mozilla DeepSpeech, too.

Please refer to the "Components/Text to Speech"
section of the documentation for details of installation and cofiguration
of other services.

To change the STT service, the `binary` parameter in the section `stt`
must be changed.

#### [nlu]
Configuration of the NLU (natural language understanding) daemon.
The default daemon is implemented in Julia and uses Regular Expressions
for intent matching and capturing of slots values.
sh sus
For more details see the NLU section of the docu.
The NLU also reads the skill directory from the `[skills]` section to find
skills.


#### [session]
Configuartionj of the session manager which runs sequences of
actions, such as `hotword -> record -> stt -> nlu -> publish intent`.

The session timeout controls after how many seconds of inactivity a session
is ended by the session manager.
During skill development shorter timeouts are used (such as 5 sec) to
avoid waiting if a component crashes.


#### [duckling]
Insert the correct installation dir to susi.toml
(/opt/Rustling) with the leading / to enforce
absolute path.
By default a local rustling implementation is used and configured.

#### [skills]
The skills daemon will start all skills in `skills_dir` and all subdirectories.
Like with Snips, a skill is considered to be an executable file with a
name starting with `action-`.


### Optional sections

If external software is integrated, the file will show sections for these:

#### [google_cloud]
Settings:
* path to the credentials file (the same file is used for STT and TTS)
* command for refresh the token
* id of the voice to be used; change this voice, if the language
  of the assistant is changed.
  Available voices can be tested here: https://cloud.google.com/text-to-speech.

#### [ibm_cloud]
* path to the credentials file
  (separate credentials are necessary for each service (such as STT and TTS)).
  Make sure to rename the files after downloading (and match the names
  in susi.toml)
* id of the voice to be used; change this voice, if the language
  of the assistant is changed.

#### [deep_speech]
Mozilla DeepSpeech must be installed locally and the path to
the installation must be configured here.

To call DeepSpeech, Susi needs to know
* the executable ('binary')
* the trained neural network ('model')
* the language model ('language_model')
* the prefix tree toi query the language model ('trie')


#### [snips]
If the Snips ASR component is used for STT, the plath to the
executable 'snips-asr' and the directory with the model to be used
must be configured.
