#!/bin/bash 
#
# retrieve a sound file from Google TTS
# and write it to a cache in order to be re-used
#
# (c) Andreas Dominik
# THM University of Applied Sciences
# Gießen, DE
#
# License: GPL3
#

AUDIO_NAME=$1
shift
TEXT="$@"

# load tool funs:
#
source $SUSI_INSTALLATION/src/Tools/init_susi.sh

# get google token:
#
REFRESH_TOKEN_CMD="$(relDir $google_cloud_refresh_token_cmd)"
CREDS="$(relDir $google_cloud_credentials)"
TMP_TOKEN="google_cloud.tmptoken"
$REFRESH_TOKEN_CMD $CREDS

REQUEST="sttrequest.json"

# get audio from Google Wavenet:
#

JSON="
{
  \"input\":
  {
    \"text\": \"$TEXT\"
  },
  \"voice\":
  {
      \"languageCode\": \"$LANGUAGE_CODE\",
      \"name\": \"$google_cloud_voice\"
  },
  \"audioConfig\":
  {
    \"audioEncoding\": \"LINEAR16\",
    \"speakingRate\": \"1.0\",
    \"pitch\": \"0\",
    \"volumeGainDb\": \"0.0\"
  }
}"
echo $JSON > request.json


curl -XPOST\
     -H "Authorization: Bearer $(cat $TMP_TOKEN)" \
     -H "Content-Type: application/json; charset=utf-8"   \
     -v\
     --data "$JSON" \
     "https://texttospeech.googleapis.com/v1beta1/text:synthesize" \
     -o audio.json

cat audio.json | sed 's/^.*audioContent\": \"//' | sed 's/[\"{}]//g'  >  $AUDIO_NAME

#
# eof.
