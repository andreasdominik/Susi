#!/bin/bash -xv
#
# Get STT from Google.
#   Input: $1 : file with base64-encoded audio
#   Output: $2 file with transscript only

STT_INPUT=$1
STT_OUTPUT=$2
TMP_TOKEN="googlecloud.tmptoken"
REQUEST="sttrequest.json"

# load tool funs:
#
TOML="$(cat susi.json)"
BASE_DIR="$(echo $TOML | jq -r .local.base_directory)"
REFRESH_TOKEN="$(echo $TOML | jq -r .google_cloud.refresh_token)"

source $BASE_DIR/Tools/funs.sh

# parse config from toml:
# PUBLISH, SUBSCRIBE, MQTT_PORT, MQTT_HOST,
# BASE_DIR, WORK_DIR, SITE_ID
#
readToml $CONFIG

TIMEOUT="$(extractJSON .hotword.session_timeout)"

# Topics:
source $BASE_DIR/Tools/topics.sh

# check if a new access token is necessary
# (in background)
#
${BASE_DIR}/src/GoogleCloud/refreshToken.sh &

AUDIO_NAME="cmd.flac"
JSON="cmd.json"

if [[ -s $STT_INPUT ]] ; then

  ACCESS_TOKEN="$( cat $TMP_TOKEN )"

  REQUEST="{
            \"config\" : {
                \"encoding\" : \"FLAC\",
                \"sampleRateHertz\" : 16000,
                \"languageCode\" : \"de-DE\",
                \"alternativeLanguageCodes\" : [\"en-US\"],
                \"maxAlternatives\" : 1,
                \"model\" : \"command_and_search\",
                \"enableWordTimeOffsets\" : false
            },
            \"audio\" : {
                \"content\" : \"$(cat $STT_INPUT)\"
            }
          }"



  curl -v -XPOST --http2 'https://speech.googleapis.com/v1p1beta1/speech:recognize' \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -d "$REQUEST" -o $JSON

  grep 'transcript' $JSON
  TS_OK=$?

  if [[ $TS_OK -eq 0 ]] ; then
    TS="$( cat $JSON | jq '.results[].alternatives[].transcript' | sed 's/[^0-9a-zA-Z]/ /g')"
    echo "$TS" > $STT_OUTPUT
  else
    echo "" > $STT_OUTPUT
  fi
else
  echo "" > $STT_OUTPUT
fi

echo "transscript is:"
cat $STT_OUTPUT
