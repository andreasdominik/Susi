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


There are a number of potentially usable open software
available, such as
* **Mozilla DeepSpeech** (https://github.com/mozilla/DeepSpeech), for
  which a binary is already included in the distribution.
* **Kaldi** (http://kaldi-asr.org/)
  provides already some high-quality model for different languages
* For Facebook's **wav2letter** (https://github.com/facebookresearch/wav2letter)
  trained models are available, too.
* High-quality trained models and tools are also provided by **Zamia AI**
  (http://zamia-speech.org/asr/).



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
locally installed and *open* software with compareble is available.


### Google Cloud STT
The Google Cloud connector is configured by default in Susi, because of the
very high quality of the transcriptions.
The service ist sensitive, accurate available for many
languages and has a good common knowlegde (knows names of famous persons,
titles of movies and TV shows, etc.).

#### Configuration of Google Cloud services:
If google services are used for text-to-speech (TTS)
or speech-to-text (STT) the required softwate must be set up:
Go through Google's tutorial
[Quickstart: Using the command line](https://cloud.google.com/text-to-speech/docs/quickstart-protocol).

  In summary ...
  * a Google Cloud Platform Project is needed,
  * the Cloud Text-to-Speech API must be enabled and
  * the JSON-file with the credentials must be downloaded to
    `/opt/Susi/ApplicationData/Google/Credentials/google-credentials.json`    
    Path and filename may differ - they are specified in the
    susi configuration file.
  * the path to the credentials file must be made available by an variable.
    Edit the file `.bashrc` in the home directory of the user who will later
    run the assistent (e.g. `susi`) and add the line:    
`export GOOGLE_APPLICATION_CREDENTIALS="/opt/Susi/ApplicationData/Google/Credentials/google-credentials.json"`    
  * gcloud API must be locally installed (see the quickstart
    documentation):
```
sudo echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get install apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
```


  To check the installation run the following command.
  It should print an access token, which can be uses to access the Cloud
  Text-to-Speech API:

```
gcloud auth application-default print-access-token
```


### IBM Cloud services

Transcription quality  of IBM Cloud STT is sufficent for an assistant.
(At least) in Europe the latency is smaller compared to the Google service
(approx. half).

#### Configuration of IBM Cloud services

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



### Mozilla DeepSpeech
As an alternative to the Google Cloud services Mozilla DeepSpeech can be used.
However,
- trained models and language models are only available for English langage
- the quality of transcription seems not to be sufficient for an assistant
  (at least in my tests - this may differ for other speakers and different
  hardware)
- a transcription needs 2-5 seconds.

However, it is easily possible to set up a separate STT-server with
sufficient CPU power (and maybe a GPU) and integrate it to Susi.

#### Installation of Mozilla DeepSpeech
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


### Snips ASR

The ASR component of Snips takes its power from the integration with
NLU; i.e. the ASR knows all sentences and phrases that must be
recognised and hence the language model can be adapted to each individual
assistant.
Because the Snips Console (the Web-interface to Snips ASR and NLU) is no longer
open for the public, it is no longer possible to train the
speech recognition for new skills.

Two potential ways to use Snips ASR still remain:
* A **customised trained existing model** can be used, as long as no new
  Skills and intents are added to an assistant, that hase been downloaded
  from the Snips console.
* Snips provides a pretrained **general model for English language** that can be
  used for any intent. However, the model is huge, compared to the customised
  models, and therefore transcription needs several seconds on a Raspberry pi.
  To use the model, it is recommended to install the STT component on
  a more powerful headless server (such as a NUC or a discarded laptop).

If a trained model is available and Snips ASR is installed, it can be activated
by selecting the respective binary in the STT section of the configuration file
'susi.toml.

#### Installation and configuration od Snips ASR

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
# sudo apt-get install snips-asr-model-en-500mb
```

A version of the general model is incuded inthe Susi distribution and strored at
'/opt/Susi/ApplicationData/Snips/ASRmodels'. To use it, just unpack it:
```
cd /opt/Susi/ApplicationData/Snips/ASRmodels
tar xvf snips-asr-model-en-500MB.tar.gz
```
In the STT section of the configuration file 'susi.toml' the binary must be set to
`snips-asr` (just uncomment the respective line) and to use the general model,
the model path must point to the directory to which the model was saved.

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


Please refer to the NLU-Section of the documentation for more details.
