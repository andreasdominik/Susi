#!/bin/bash
#
# Get STT from local Snips asr-server.
#   Input: $1 : file with base64-encoded audio
#   Output: $2 file with transscript only

STT_INPUT=$1
STT_OUTPUT=$2

# load tool funs:
#
source $SUSI_INSTALLATION/src/Tools/init_susi.sh

AUDIO_BASENAME="snipsasraudio"

if [[ -s $STT_INPUT ]] ; then
  b64_decode $STT_INPUT $AUDIO_BASENAME

  RESULT="$($snips_asr_exec -m $snips_asr_model_path file $AUDIO_NAME)"

  REGEX="Ok.*Recognition.*decoded_string: \"(was kann ich für)\","
  if [[ $RESULT =~ $REGEX ]] ; then
    TRANSCRIPT="${BASH_REMATCH[1]}"
  else
    TRANSCRIPT=""
  fi
else
  TRANSCRIPT=""
fi

echo  $TRANSCRIPT > $STT_OUTPUT
echo "transscript is:"
cat $STT_OUTPUT
