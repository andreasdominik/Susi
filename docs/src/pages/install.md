# Basic installation

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

Please see in the section *Components* for more alternatives.
Only **one** of the alternatives must be installed. STT and TTS
services are selected by specifying the respective binary in the
`[stt]` and `[tts]` sections of the configuration file.


Please refer to the section *Daemons and Comonents* for detailed
installation and configuration instructions for the respective
STT and TTS services.


## Installation with the installation script (Raspberry Pi only)

In most cases the install script will do the installation.
Just download the latest Susi release from GitHub unpack it to a temporary
location and run `sudo ./install` or `sudo ./install satellite` to
make a full or a sattelite installation.

After the script has completed STT and TTS must be configured (for
details see below
in section *Configure Susi*).


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
