#!/bin/bash
#
# Get TTS from IBM
#   $1 : name of audio file to be created
#   $all remaining: text

AUDIO_NAME=$1
shift
TEXT="$@"

# load tool funs:
#
source $SUSI_INSTALLATION/src/Tools/init_susi.sh

# load IBM cloud env and clean end-of-line:
#
source $(relDir $ibm_cloud_tts_credentials)
APIKEY="${TEXT_TO_SPEECH_APIKEY//$'\r'/}"
IAM_APIKEY="${TEXT_TO_SPEECH_IAM_APIKEY//$'\r'/}"
URL="${TEXT_TO_SPEECH_URL//$'\r'/}"
ATUH_TYPE="${TEXT_TO_SPEECH_AUTH_TYPE//$'\r'/}"

AUDIO_WAV="ibm-tts.wav"
rm $AUDIO_NAME $AUDIO_WAV

# get audio from IB cloud:
#
curl -v -X POST -u "apikey:$APIKEY" \
      --header "Content-Type: application/json" \
      --header "Accept: audio/wav" \
      --data "{\"text\":\"$TEXT\"}" \
      --output "$AUDIO_WAV" \
      "$URL/v1/synthesize?voice=$ibm_cloud_voice"

if [[ -f $AUDIO_WAV ]] ; then
  base64 -w 0 $AUDIO_WAV > $AUDIO_NAME
else
  echo "" > $AUDIO_NAME
fi

#
# eof.
