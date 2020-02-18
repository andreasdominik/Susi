# Daemons and components

### Hotword detection

### Snowboy

#### Snips (of course)

### Speech to text (STT)

#### Google STT

#### Mozilla DeepSpeech
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
