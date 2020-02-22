#!/bin/bash
#
# Get STT from IBM
#   Input: $1 : file with base64-encoded audio
#   Output: $2 file with transscript only

STT_INPUT=$1
STT_OUTPUT=$2

# load tool funs:
#
source $SUSI_INSTALLATION/src/Tools/init_susi.sh

# load IBM cloud env and clean end-of-line:
#
source $(relDir $ibm_cloud_credentials)
SPEECH_TO_TEXT_APIKEY="${SPEECH_TO_TEXT_APIKEY//$'\r'/}"
SPEECH_TO_TEXT_IAM_APIKEY="${SPEECH_TO_TEXT_IAM_APIKEY//$'\r'/}"
SPEECH_TO_TEXT_URL="${SPEECH_TO_TEXT_URL//$'\r'/}"
SPEECH_TO_TEXT_ATUH_TYPE="${SPEECH_TO_TEXT_AUTH_TYPE//$'\r'/}"

# make audio for IBM:
#
AUDIO_NAME="sttAudio.flac"
base64 -d $STT_INPUT > $AUDIO_NAME

JSON="curl.result"

# find language model
#
if [[ -s $STT_INPUT ]] ; then
  STT_MODEL="${LANGUAGE_CODE}_BroadbandModel"

  curl -v -X POST -u "apikey:$SPEECH_TO_TEXT_APIKEY" \
      --header "Content-Type: audio/flac" \
      --data-binary @$AUDIO_NAME  \
      "$SPEECH_TO_TEXT_URL/v1/recognize?model=$STT_MODEL" \
      -o $JSON

  # extract transcript if it is there:
  #
  grep 'transcript' $JSON
  TS_OK=$?

  if [[ $TS_OK -eq 0 ]] ; then
    TS="$( cat $JSON | jq '.results[].alternatives[].transcript' | sed 's/[^0-9a-zA-Z]/ /g')"
    echo $TS > $STT_OUTPUT
  else
    echo "" > $STT_OUTPUT
  fi
else
  echo "" > $STT_OUTPUT
fi

#
# eof.
