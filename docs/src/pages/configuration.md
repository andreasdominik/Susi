## Configuration file `susi.toml`

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

#### [stt]
Configuration of the STT daemon.
By default Google STT is used because of its very high accuracy and common
knowledge. However, it's no longer local and private.    
Mozilla DeepSpeech can be used for English language if installed by
uncommenting the respective line.
Other services may be included by exchange the `binary`.

#### [nlu]
Configuration of the NLU (natural language understanding) daemon.
The default daemon is implemented in Julia and uses Regular Expressions
for intent matching and capturing of slots values.
sh sus
For more details see the NLU section of the docu.
The NLU also reads the skill directory from the `[skills]` section to find
skills.


#### [session]
Configuartionj of the session manager which runs ste sequences of
actions, such as `hotword -> record -> stt -> nlu -> publish intent`.



#### [duckling]
Insert the correct installation dir to susi.toml
(/opt/Duckling/duckling) with the leading / to enforce
absolute path.
If an externam duckling-service is used, correct host and
password information must be provided.

#### [skills]
The skills daemon will start all skills in `skills_dir` and all subdirectories.
Like with Snips, a skill is considered to be an executable file with a
name starting with `action-`.


### Optional sections

If external software is integrated, the file will show sections for these:

#### [google_cloud]
Settings:
* path to the credentials file
* command for refresh the token.

#### [deep_speech]
If Mozilla DeepSpeech is used as STT engine, it can be configured here.
Deep speech needs
* `model`: the trained neural network
* `language_model`: ngram model for the language
* `trie`: the suffix tree for fast searched in the language model.
