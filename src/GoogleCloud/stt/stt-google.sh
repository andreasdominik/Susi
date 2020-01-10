#!/bin/bash -xv
#
# Get STT from Google.
#   Input: $1 : file with base64-encoded audio
#   Output: $2 file with transscript only

STT_INPUT=$1
LANGUAGE=$2
STT_OUTPUT=$3
TMP_TOKEN="google_cloud.tmptoken"
REQUEST="sttrequest.json"
JSON="curl.result"

if [[ -s $STT_INPUT ]] ; then

  case $LANGUAGE in
      de)
          COUNTRY="DE"
          ;;
      en)
          COUNTRY="GB"
          ;;
      *)
          LANGUAGE="$(echo ${LANGUAGE:0:2} | tr A-Z a-z)"
          COUNTRY="$(echo $LANGUAGE | tr a-z A-Z)"
          ;;
  esac
  LANCODE="${LANGUAGE}-${COUNTRY}"

  ACCESS_TOKEN="$( cat $TMP_TOKEN )"

  REQUEST="{
            \"config\" : {
                \"encoding\" : \"FLAC\",
                \"sampleRateHertz\" : 16000,
                \"languageCode\" : \"$LANCODE\",
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
