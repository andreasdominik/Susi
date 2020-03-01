# Installation

This tutorial shows a brief installation of Susi.
More configuration and customisation is possible - please read the
sections "Configuration file susi.toml" and "Daemons" for details
about alternative configurations.

Susi may be installed on any linux/unix-like operating system.    
Because Susi is build with a minimum of specific implementation major parts
of its functionality are taken from existing projects.
Therefore bunch of software must be installed before using Susi.

For Raspberry Pis an installation script is available, but
manual installation is simple, and Susi can be installed on
every device that have a bash available (because major parts of Susi
are implemented as simple bash-scripts).

For both methods you must descide for TTS and STT services to be used. These must
be installed and configured seperately:

## *Speech to text* and *text to speech*

Susi does not come with an own AI for STT and TTS and needs external
services to transcribe audio to text as well as for speech synthesis.
The modular design of Susi makes it easy to integrate any service.
Currently 4 alternatives are implemented:
* **Google Cloud:** best quality for both STT and TTS, but
  cloud-based not local, and not for free - expect cost in the
  range of 0.5-1$ per month.
* **IBM Cloud:** the free "Light Plan" will be sufficient for most cases.
  However, this is also not local.
* **Mozilla Deep Speech** can be installed locally and hence will
  preserve privacy. However the quality of STT is limited.
* **Snips ASR** can be used fot STT if a trained model is available
  (e.g. from an assistant downloaded from the Snps console).

Only **one** of the alternatives must be installed. STT and TTS
services are selected by specifying the respective binary in the
`[stt]` and `[tts]` sections of the configuration file.



#### Google cloud services:
If google services are used for text-to-speech (TTS)
or speech-to-text (STT) the required softwate must be set up:
Go through Google's tutorial
[Quickstart: Using the command line](https://cloud.google.com/text-to-speech/docs/quickstart-protocol).

  In summary ...
  * a Google Cloud Platform Project is needed,
  * the Cloud Text-to-Speech API must be enabled and
  * the JSON-file with the credentials must be downloaded to
    `/opt/Susi/ApplicationData/Google/Credentials/google-credentials.json`    
    Path and filename may differ - they are later specified in the
    susi configuration file.
  * the path to the credentials file must be made available by an variable.
    Edit the file `.bashrc` in the home directory of the user who will later
    run the assistent (e.g. `susi`) and add the line:    
`export GOOGLE_APPLICATION_CREDENTIALS="/opt/Susi/ApplicationData/Google/Credentials/google-credentials.json"`    
    To check the installation run the following command.
    It should print an access token, which can be uses to access the Cloud
    Text-to-Speech API:

```
gcloud auth application-default print-access-token
```

#### IBM Cloud services

To use IBM Watson Text to Speech STT or TTS, it must be configured as
described on IBM's website: https://cloud.ibm.com/.

Is is as simple as:
* create an account
* descide for a pricing plan (the "Free Lite Plan" may be sufficient
  as it offers up to 500 minutes of audio transcription and
  10000 characters for TTS per month)
* create a Speech to Text Service (and a Text to Sppech Service)
* download the credential file `ibm-cedentials.env`, rename and save it at
  `/opt/Susi/ApplicationData/IBMCloud/ibm-tts-cedentials.env` (the download link is in the
    'Manage' section)
* work through the "Getting started with Sppech to Text" tutorial
  (https://cloud.ibm.com/docs/services/speech-to-text?topic=speech-to-text-gettingStarted#getting-started-tutorial).

Similar steps are necessary for text to speech.
Please notice, that there are different credentials necessary for STT and TTS.
Both need to be downloaded and saved to `/opt/Susi/ApplicationData/IBMCloud/`
with different names (such as 'ibm-tts-cedentials.env' and 'ibm-stt-cedentials.env').
Names can be configured in the 'susi.toml' file.


#### Mozilla DeepSpeech
Installation is simple and follows the instruction on the website
(https://github.com/mozilla/DeepSpeech). The installation can be tested
by running deepspeech on the commandline.

DeepSpeech integration to Susi is already included in the distribution and
can be activated by uncommenting the line in the configuration file.

```
# installation of Mozilla DeepSpeech:
#
# prepare:
mkdir /opt/DeepSpeech
cd /opt/DeepSpeech
virtualenv -p python3 ./deepspeech-venv/
source $HOME/tmp/deepspeech-venv/bin/activate

# Install DeepSpeech
pip3 install deepspeech

# Download pre-trained English model and extract
curl -LO https://github.com/mozilla/DeepSpeech/releases/download/v0.6.1/deepspeech-0.6.1-models.tar.gz
tar xvf deepspeech-0.6.1-models.tar.gz

# Download example audio files
curl -LO https://github.com/mozilla/DeepSpeech/releases/download/v0.6.1/audio-0.6.1.tar.gz
tar xvf audio-0.6.1.tar.gz

# Transcribe an audio file
rec -r 16000 lighton.wav

deepspeech --model deepspeech-0.6.1-models/output_graph.pbmm --lm deepspeech-0.6.1-models/lm.binary --trie deepspeech-0.6.1-models/trie --audio lighton.wav
```

#### Snips ASR

If a trained model is available and Snips ASR is installed, it can be activated
by selecting the respective binary in the STT section of the configuration file
'susi.toml.

To install the Snips asr
* add the Snips apt-get repository,
* install snips-asr,
* make sure that the service is not runing (Susi will start asr
  when it needs it),
* if you have no personally trained model, there is a general model
  (English language only) that can be used:

```
sudo bash -c  'echo "deb https://debian.snips.ai/stretch stable main" > /etc/apt/sources.list.d/snips.list'
sudo apt-key adv --fetch-keys  https://debian.snips.ai/5FFCD0DEB5BA45CD.pub
sudo apt-get update
sudo apt-get install snips-asr
sudo systemctl stop snips-asr
sudo systemctl disable snips-asr

# the general model:
sudo apt-get install snips-asr-model-en-500mb
```

In the STT section of the configuration file 'susi.toml' the binary must be set to
`snips-asr` (just uncomment the respective line) and to use the general model,
the model path must point to the directory to which the model was saved.



## Installation with the installation script (Raspberry Pi only)

In most cases the install script will do the installation.
Just download the latest Susi release from GitHub unpack it to a temporary
location and run `sudo ./install` or `sudo ./install satellite` to
make a full or a sattelite installation.


## Manual installation

The tutorial assumes that all indivdual software is installed at
`/opt/`. So the first step is to login as the user which will run
the assistant later (such as `susi`),
and create the directory `/opt/Susi`.

```
sudo mkdir /opt/Susi
chown susi /opt/Susi
chgrp susi /opt/Susi
```
### Dependencies

#### git
Most of the software must be obtained from git repos; therefore
git must be installed first:

```
sudo apt-get install git-core curl coreutils
```

#### mosquitto, jq
mosquitto server and client are needed to
publish and subscribe to MQTT messages. The package mosquitto
provides the MQTT broker and is only necessary for the main installation and
not for satellites.
MQTT messages are sent as JSON strings. susi uses `jq` to parse JSON.
In order to avoid sending binary files via MQTT, they are base64 encoded.

Be sure to disable the mosquitto-service! Susi will start mosquitto
when it is needed.

The base64 utility is part of the coreutils:

```
sudo apt-get install mosquitto mosquitto-clients coreutils jq
sudo systemctl stop mosquitto.service
sudo systemctl disable mosquitto.service
```

#### Julia
some components of the system are written in the nice and
fast programming laguage Julia. Install the current version from
https://www.julialang.org (a good location is `/opt/Susi/Julia`) by downloading
the version for your platform to `/opt/Susi/Julia`, unpacking and creating a
link to `/usr/local/bin` to make it available (example for 64-bit linux
version 1.3.1).

Some Julia packages are needed and can be installed right now:

```
mkdir /opt/Julia
cd /opt/Julia
cp ~/Downloads/julia-1.3.1-linux-x86_64.tar.gz .
tar xvzf julia-1.3.1-linux-x86_64.tar.gz

cd /usr/local/bin
sudo ln -s /opt/Julia/julia-1.3.1/bin/julia
julia -e 'using Pkg; Pkg.add(["ArgParse", "JSON", "StatsBase"]; Pkg.update()'
```

#### sox
sox
is used for recording and playing sound. It must be installed on the main
installation and on all satellites. In addition ffmpeg and and libsox-fmt-mp3
might be necessary in order to be able to play all types of audio files.

After installation sox can be tested with `rec firstaudio.wav` and
`play firstaudio.wav`.
Volume gain may be adapted with alsamixer or (x11) pavucontrol.

```
sudo apt-get install sox libsox-fmt-mp3
sudo apt-get install ffmpeg
```

#### Snowboy
the Snowboy hotword detector is used by default for hotword
recognition. Snowboy is completely local and allows to create and train own
hotwords via a web-interface.    
- download the binaries for the required platform from https://github.com/kitt-ai/snowboy.
- unpack the tar ball to `/opt/Snowboy`
- install the dependencies for the required platform as described in
  https://github.com/kitt-ai/snowboy/README.md

##### Hotwords
After the installation the latest version of the default hotword
(i.e. *Snowboy*) and individual
hotwords can be created and downloaded into  the directory
`/opt/Susi/Susi/src/Snowboy/resources`.

To improve hotword detection it is recommended to train
the hotword with the voices of all speakers before
downloading.
Many hotwords are alredy trained and new hotwords can be created easily
via the Snowboy website. It is always a good idea to improve training of a
hotword with your own voice before downloading:

* **snowboy.umdl:** https://snowboy.kitt.ai/hotword/5 (the best hotword,
  recommended for testing)
* **smart_mirror.umdl:** https://snowboy.kitt.ai/hotword/47
* **computer.umdl:** https://snowboy.kitt.ai/hotword/46
* **susi.pmdl:** https://snowboy.kitt.ai/hotword/7915 (however a hotword with
  only 2 syllables may show high false activation rate; better try
  something like "hey Susi").

Snowboy can be tested like described in the Snowboy docu.

```
mkdir /opt/Snowboy
cd /opt/Snowboy
#
# replace rpi-arm-raspbian-8.0-1.3.0.tar.bz2 with the precompiled
# binaries for the required platform:
cp ~/Downloads/rpi-arm-raspbian-8.0-1.3.0.tar.bz2 /opt/Snowboy
tar xvf rpi-arm-raspbian-8.0-1.3.0.tar.bz2
sudo apt-get install python-pyaudio python3-pyaudio sox
```



### Get and install Susi

* Clone Susi from the GitHub repo
* make the installation directory available in the environment
* integrate Snowboy
* make links to the executables
* install and activate systemd service to make susi available as service
* install and edit the configuration file `/etc/susi.toml`

Before starting the service, the configuration must be adapted to the local
installation (see next section for details).

```
# Susi:
cd /opt/Susi
mkdir /opt/Susi/ApplicationData
mkdir /opt/Susi/Skills
git clone git@github.com:andreasdominik/Susi.git

# add variable to environment:
grep "^export SUSI_INSTALLATION=" ~/.bashrc || echo "export SUSI_INSTALLATION=/opt/Susi/Susi" >> ~/.bashrc
source ~/.bashrc

# Snowboy:
# replace rpi-arm-raspbian-8.0-1.3.0.tar.bz2 with the precompiled
# binaries for the required platform:
cp /opt/Susi/Susi/src/Snowboy/bin/hotword_susi.py /opt/Snowboy/rpi-arm-raspbian-8.0-1.3.0/
cp /opt/Susi/Susi/src/Snowboy/bin/snowboydecoder_susi.py /opt/Snowboy/rpi-arm-raspbian-8.0-1.3.0/

# Susi service and execs:
cd /usr/local/bin/
sudo ln -s /opt/Susi/Susi/bin/susi.watch
sudo ln -s /opt/Susi/Susi/bin/susi
sudo ln -s /opt/Susi/Susi/bin/susi.say
sudo ln -s /opt/Susi/Susi/src/Service/susi.start
sudo ln -s /opt/Susi/Susi/src/Service/susi.stop

cd $SUSI_INSTALLATION
sudo cp /opt/Susi/Susi/src/Service/susi.service /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/susi.service

# configuration:
sudo cp /opt/Susi/Susi/etc/susi.toml /etc/susi.toml
```


#### Duckling
Duckling is used to parse transcribed voice input into
time or numbers.
For performance reasons Susi uses the Rust-port (done by the Snips people)
of Duckling (so-called *Rustling*).

For 32-bit ARM and 64-bit x86 precompiled binaries are available.
Just copy the correct binary to `/opt/Rustling/bin`.


Otherwise
Rust and Rustling can be installes as follows:

```
# Rust:
mkdir -p /opt/Rustling
mkdir -p /opt/Rustling/bin
cd /opt/Rustling

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Rustling:
cd /opt/Rustling
git clone https://github.com/snipsco/rustling-ontology.git

cp -r /opt/Susi/Susi/src/Duckling/Rustling/rustling-ontology/listener /opt/Rustling/rustling-ontology/
cp /opt/Susi/Susi/src/Duckling/Rustling/rustling-ontology/Cargo.toml /opt/Rustling/rustling-ontology/
cd /opt/Rustling/rustling-ontology/listener
cargo build --release
cp /opt/Rustling/rustling-ontology/target/release/rustling-listener opt/Rustling/bin/
```

Depending on the hardware, the build process may need from some minutes up to several hours.


## Configure Susi

Susi is configured with the file `/etc/susi.toml`.
Susi consists of several daemons that runs at the main system or
on all satellites:
* hotword daemon: Hotword detection (all satellites)
* record daemon: record commands (all satellites)
* play daemon: play a audio file (all satellites)
* STT daemon: transcribe recorded speech (audio) to text (only one)
* TTS daemon: synthesise speech (audio) from text (only one)
* NLU daemon: analyse a transcribed command and create an intent (only one)
* session daemon. the session manager that defines pipelines of
  actions to be executed when a hotword or other trigger is detected
  (only one).
* duckling server: the duckling webserver is used to extract
  time, numbers or ordinals from commands.


`susi.toml` is a standard toml file. All path definitions can be given
as relative or absolute paths: if a path starts with an "/", it is
considered to be an absolute path, if not it is expanded relative to the
Susi installation (default: "/opt/Susi/Susi").

More information about all entries is given in the file.


#### Standard configuration

Most parameters in the configuration file are by default set to resonable
values and are self-explaining.
* specify a language code
* select a name for the assistant
* go through the file and double-check or
  adapt paths if necessary.





#### Configuration for all daemons

All daemons share some config entries:

* `start = true` defines if the daemon
  is started with the susi service or not.
* `daemon = "xyz"` is the path to the executable that runs the daemon.
* `binary = "xyz"` is the path to the executable that does the job when
  the daemon is gets a trigger.




The sections of the susi.toml file are:

#### [assistant]
Name and language of the assistant.

#### [debug]
if 'show_all_stdout' is set to 'true', all daemons will echo commands to
stdout (i.e. 'set -xv').



#### [local]
Work directory to store temporary files and
name of the local siteId. Each satellite needs an unique name.
If satellite is set to "true", only hotword, record and play daemon will be started
on this site.

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
  sound file will be played every time the detector is toggled on.

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

By default, Google TTS is configured.
The daemin uses caching: an audio file of every
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
For more details see the NLU section of the docu.
The NLU also reads the skill directory from the `[skills]` section to find
skills.

#### [session]
The session timeout controls after how many seconds of inactivity a session
is ended by the session manager.
During skill development shorter timeouts are used (such as 5 sec) to
avoid waiting if a component crashes.

#### [skills]
Here the path to the directory of installed skills is configured.


### External services Configuration
In the following sections external software is configured:

#### [google_cloud]
Path to the JSON file with the credentials for the Google Cloud Services.
The same credentials are used for all services (such as STT and TTS).

#### [ibm_cloud]
Path to the JSON files with the credentials for the IBM Cloud Services.
Separate credentials are necessary for each service (such as STT and TTS).
Make sure to rename the files after downloading (and match the names
in susi.toml).

#### [deep_speech]
Mozilla DeepSpeech must be installed locally and the path to
the installation must be configured here.

To call DeepSpeech, Susi needs to know
* the executable ('binary')
* the trained neural network ('model')
* the language model ('language_model')
* the prefix tree toi query the language model ('trie')

#### [duckling]
Installation dir, executable and hostame/port ofthe webserver
must be configured.


#### voices
Depending on the text-to speech service used, a voice must be configured.
* if GoogleTTS is used the voice parameter in the section `[google-cloud]`
  must be set by uncommenting the correct line or changing the
  name of the wanted voice.   
  Available voices can be tested here: https://cloud.google.com/text-to-speech.





## Start Susi service

The last step is to enable the service it to make sure
Susi is started at reboot:
```
sudo systemctl enable susi.service
```

The service can be started manually with systemctl:
```
sudo systemctl start susi.service
sudo systemctl restart susi.service
sudo systemctl stop susi.service
```
