# Installation

This tutorial shows a brief installation of Susi.
More configuration and customisation is possible - please read the
sections "Configuration file susi.toml" and "demons" for details
about alternative configurations.

Susi may be installed on any linux/unix-like operating system.    
Because Susi is build with a minimum of specific implementation major parts
of its functionality are taken from existing projects.
Therefore bunch of software must be installed before using Susi.

The tutorial assumes that all indivdual software is installed at
`/opt/`. So the first step is to login as the user which will run
the assistant later (such as `susi`),
and create the directory `/opt/Susi`.

```
sudo mkdir /opt/Susi
chown susi /opt/Susi
chgrp susi /opt/Susi
```

## Dependencies

* **git:**
  Most of the software nusr be obtained from git repos; therefore
  git must be installed first:

```
sudo apt-get install git-core curl coreutils
```

* **Google cloud services:**
  if google services are used for text-to-speech (TTS)
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

* **Mozilla DeepSpeech:** nach hinten! TODO
  as an alternative to the Google Cloud services Mozilla DeepSpeech can be used.
  However,
  - trained models and language models are only available for English langage
  - the quality of transcription seems not to be sufficient for an assistant
    (at least in my tests - this may differ for other speakers and different
    hardware).

  Installation is simple and follows the instruction on the website
  (https://github.com/mozilla/DeepSpeech). The installation can be tested
  by running deepspeech on the commandline.

```
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


* **mosquitto, jq, base64:**
  mosquitto server and client are nedded to
  send publish and subscribe to MQTT messages. The package mosquitto
  provides the MQTT broker and is only necessary for the main installation and
  not for satellites.
  MQTT messages are sent as JSON strings. susi uses `jq` to parse JSON.
  In order to avoid sending binary files via MQTT, they are base64 encoded.
  The base64 utility is part of the coreutils:

```
sudo apt-get install jq mosquitto mosquitto-clients coreutils
```

* **Julia:**
  some components of the system are written in the nice and
  fast programming laguage Julia. Install the current version from
  https://www.julialang.org (a good location is `/opt/Susi/Julia`) by downloading
  the version for your platform to `/opt/Susi/Julia`, unpacking and creating a
  link to `/usr/local/bin` to make it available (example for 64-bit linux).

  Some Julia packages are needed and can be installed right now:

```
tar xvzf <julia-1.3.1-linux-x86_64.tar.gz>
cd /usr/local/bin
sudo ln -s /opt/Julia/<julia-1.3.1>/bin/julia
julia -e 'using Pkg; Pkg.add(["ArgParse", "JSON", "StatsBase"]; Pkg.update()'
```

* **sox:**
  the Swiss Army knife of sound processing programs (SoX - Sound eXchange)
  is used for recording and playing sound. It must be installed on the main
  installaion and on all satellites. In addition ffmpeg and and libsox-fmt-mp3
  might be necessary in order to be able to play all types of audio files.

  After installation sox can be tested with `rec firstaudio.wav` and
  `play firstaudio.wav`:

  Volume gain may be adapted with alsamixer or (x11) pavucontrol.

```
sudo apt-get install sox libsox-fmt-mp3
sudo apt-get install ffmpeg
```

* **Snowboy:**
  the Snowboy hotword detector is used by default for hotword
  recognition. Snowboy is completely local and allows to create and train own
  hotwords via a web-interface.    
  - download the binaries for the required platform from https://github.com/kitt-ai/snowboy.
  - unpack the tar ball to `/opt/Snowboy`
  - install the dependencies for the required platform as described in
    https://github.com/kitt-ai/snowboy/README.md

  After the installation (with the default hotword `snowboy`) individual
  hotwords can be created and downloaded into  the directory
  `/opt/Susi/Susi/src/Snowboy/bin/resources`.

  Snowboy can be tested like described in the Snowboy docu.

```
mkdir /opt/Snowboy
cd /opt/Snowboy
#
# replace rpi-arm-raspbian-8.0-1.3.0.tar.bz2 with the precompiled
# binaries for the required platform:
cp ~/Downloads/<rpi-arm-raspbian-8.0-1.3.0.tar.bz2> /opt/Snowboy
tar xvf <rpi-arm-raspbian-8.0-1.3.0.tar.bz2>
sudo apt-get install python-pyaudio python3-pyaudio sox
```

* **Duckling:**
  Duckling is used to parse transcribed voice input into
  time or numbers. There is a web-service available, but it is also possible to
  install it locally - the demo-program, which is shipped with the installation,
  already provides a local webserver, sufficcient for our neends.
  Duckling is written in Haskell, so a  Haskell stack is required.
  - install `stack` as described here: https://tech.fpcomplete.com/haskell/get-started.
  - io install Duckling create `/opt/Duckling/`, clone the GitHub repo
    https://github.com/facebook/duckling into `/opt/Duckling` and
    build the executable (be sure to have a good cup of coffee while it's compiling).

    It might be necessary to install libpcre before building (the build will fail without).
    After compilation, run the example-exe. It starts a web-server that can be tested
    by sending simple requests via cURL:

```
git clone https://github.com/facebook/duckling
sudo apt–get install libpcre3 libpcre3–dev
cd ./duckling
stack build

# test:
#
stack exec duckling-example-exe

curl -XPOST http://0.0.0.0:8000/parse --data 'locale=en_GB&text=tomorrow at eight'
```



## Susi

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
echo "export SUSI_INSTALLATION="/opt/Susi/Susi" >> ~/.bashrc

# Snowboy:
# replace rpi-arm-raspbian-8.0-1.3.0.tar.bz2 with the precompiled
# binaries for the required platform:
cp Susi/src/Snowboy/bin/hotword_susi.py /opt/Snowboy/<rpi-arm-raspbian-8.0-1.3.0/>
cp Susi/src/Snowboy/bin/snowboydecoder_susi.py /opt/Snowboy/<rpi-arm-raspbian-8.0-1.3.0/>

# Susi service and execs:
cd /usr/local/bin/:
sudo ln -s /opt/Susi/Susi/bin/susi.watch
sudo ln -s /opt/Susi/Susi/bin/susi
sudo ln -s /opt/Susi/Susi/bin/susi.say
sudo ln -s /opt/Susi/Susi/src/Service/susi.start
sudo ln -s /opt/Susi/Susi/src/Service/susi.stop

sudo cp /opt/Susi/Susi/src/Service/susi.service /etc/systemd/system/

# configuration:
sudo cp /opt/Susi/Susi/etc/susi.toml /etc/susi.toml
```

### Configure Susi

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
* specify a language in 2-letter-code
* select a name for the assistant
* go through the file and double-check or
  adapt paths if necessary.





#### Configuration for all daemons

All daemons share some config entries:

* `start = "true"` defines if the daemon
  is started with the susi service or not.
* `daemoon = "xyz"` is the path to the executable that runs the daemon.
* `binary = "xyz"` is the path to the executable that does the job when
  the daemon is gets a trigger.




The sections of the susi.toml file are:

#### [assistant]
Name and language of the assistant.

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


#### [tts]
    insert the correct installation dir to susi.toml
    (/opt/Duckling/duckling) with the leading / to enforce
    absolute path.
