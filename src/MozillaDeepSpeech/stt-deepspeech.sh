#!/bin/bash
#
# use Mozilla DeesSpeech for SST
#   Input: $1 : file with base64-encoded audio
#   Output: $2 file with transscript only

STT_INPUT=$1
STT_OUTPUT=$3

# load tool funs:
#
source $SUSI_INSTALLATION/src/Tools/init_susi.sh


if [[ ! -s $STT_INPUT ]] ; then
  echo "" > $STT_OUTPUT
  exit 1
fi

# make wav from b64:
#
AUDIO_RAW="audio"
AUDIO_WAV=${AUDIO_RAW}.wav
base64 --decode $STT_INPUT > $AUDIO_RAW

# use ffmpg for format detection rather then soxi:
#
MEDIA_TYPE="$(ffprobe -show_format $AUDIO_RAW 2>/dev/null | grep -Po '(?<=format_name=)[0-9a-zA-Z]+$')"
AUDIO_NAME="${AUDIO_RAW}.${MEDIA_TYPE}"
sox $AUDIO $AUDIO_WAV


DEEP_SPEECH="$deep_speech_binary"
INSTALLATION_DIR="$(relDir $deep_speech_installation)"
MODEL_DIR="$deep_speech_model_dir"
MODEL="$deep_speech_model"
LANGUAGE_MODEL="$deep_speech_language_model"
TRIE="$deep_speech_trie"

cd $INSTALLATION_DIR
source ./deepspeech-venv/bin/activate

$DEEP_SPEECH --model $MODEL_DIR/$MODEL \
       --lm $MODEL_DIR/$LANGUAGE_MODEL \
       --trie $MODEL_DIR/$TRIE \
       --audio $local_work_directory/$AUDIO_WAV > $local_work_directory/$STT_OUTPUT

echo "transscript is:"
cat $local_work_directory/$STT_OUTPUT
