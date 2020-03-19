#!/bin/bash
#
# Get STT from Google.
#   Input: $1 : file with base64-encoded audio
#   Output: $2 file with transscript only

STT_INPUT=$1
STT_OUTPUT=$2

# load tool funs:
#
source $SUSI_INSTALLATION/src/Tools/init_susi.sh


# only do something if input filesize is bigger as defined limit:
#
IN_SIZE=$(stat --printf="%s" $STT_INPUT)

if [[ $IN_SIZE -lt $google_cloud_minimum_size ]] ; then
  echo "" > $STT_OUTPUT
  exit
fi


# get google token:
#
REFRESH_TOKEN_CMD="$(relDir $google_cloud_refresh_token_cmd)"
CREDS="$(relDir $google_cloud_credentials)"
TMP_TOKEN="google_cloud.tmptoken"
$REFRESH_TOKEN_CMD $CREDS

REQUEST="sttrequest.json"
JSON="curl.result"

if [[ -s $STT_INPUT ]] ; then

  ACCESS_TOKEN="$( cat $TMP_TOKEN )"

  echo -n "{
            \"config\": {
                \"encoding\" : \"FLAC\",
                \"sampleRateHertz\" : 16000,
                \"languageCode\" : \"$LANGUAGE_CODE\",
                \"alternativeLanguageCodes\" : [\"en-US\"],
                \"maxAlternatives\" : 1,
                \"model\" : \"command_and_search\",
                \"speechContexts\": [ {
                    \"phrases\": [\"\$TIME\"]
               }],
              \"enableWordTimeOffsets\" : false
            },
            \"audio\": {
                \"content\": \""       >  $REQUEST
  cat $STT_INPUT | tr -d '\n'           >> $REQUEST
  echo "\"} }"                          >> $REQUEST

  # remove spaces and line breaks:
  #
  REQUEST_TMP=${REQUEST}.tmp
  cat $REQUEST | tr -d '\n' | tr -s ' ' > $REQUEST_TMP
  mv $REQUEST_TMP $REQUEST
  echo "" >> $REQUEST


  # curl -v -XPOST --http2 'https://speech.googleapis.com/v1/speech:recognize' \

  curl -v -XPOST --http2 'https://speech.googleapis.com/v1p1beta1/speech:recognize' \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     --data "@$REQUEST" -o $JSON

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
