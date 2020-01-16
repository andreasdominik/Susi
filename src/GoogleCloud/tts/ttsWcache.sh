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
LANGUAGE=$2
CACHE=$3
shift 3
TEXT="$@"
TMP_TOKEN="google_cloud.tmptoken"

# umask 000
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

# language-specfic cache:
#
CACHE="${CACHE}/${LANCODE}"
if [[ ! -d $CACHE ]] ; then
    mkdir -p ${CACHE}
fi

# TTS_SERVICE=${GOOGLE_TTS_DIR}/src/ttsREST.sh

CACHED_NAME=$(echo $TEXT | tr '/' '_' | sed 's/[^(0-9a-zA-Z)]/_/g').b64
LEN=$(echo $CACHED_NAME | wc -c)

# use caching for strings smaller then 256
#
if [[ -e ${CACHE}/${CACHED_NAME} ]] ; then
    cp ${CACHE}/${CACHED_NAME} $AUDIO_NAME

# get audio from Google Wavenet:
#
else
    if [[ $LANCODE == de-DE ]] ; then
      VOICE="de-DE-Wavenet-B"
      LAN="de-DE"
      VOICE_SET="\"voice\":
                  {
                    \"languageCode\": \"$LAN\",
                    \"name\": \"$VOICE\",
                  },"
      # VOICE="de-DE-Wavenet-C"
      # LAN="de-DE"
      # VOICE_SET="\"voice\":
      #             {
      #               \"languageCode\": \"$LAN\",
      #               \"name\": \"$VOICE\",
      #               \"ssmlGender\": \"FEMALE\"
      #             },"
    elif [[ $LANGUAGE == en-GB ]] ; then
      VOICE="en-GB-Wavenet-A"
      LAN="en-GB"
      VOICE_SET="\"voice\":
                  {
                    \"languageCode\": \"$LAN\",
                    \"name\": \"$VOICE\",
                    \"ssmlGender\": \"FEMALE\"
                  },"
    else
      LAN=$LANGUAGE
      VOICE_SET="\"voice\":
                  {
                    \"languageCode\": \"$LAN\",
                    \"ssmlGender\": \"FEMALE\"
                  },"
    fi

    JSON="
    {
      \"input\":
      {
        \"text\": \"$TEXT\"
      },
      $VOICE_SET
      \"audioConfig\":
      {
        \"audioEncoding\": \"LINEAR16\",
        \"speakingRate\": \"1.0\",
        \"pitch\": \"0\",
        \"volumeGainDb\": \"0.0\",
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

    if [[ -s ${AUDIO_NAME} ]]; then
        if [[ $LEN -lt 256 ]] ; then
            cp ${AUDIO_NAME} ${CACHE}/${CACHED_NAME}
        fi
    fi
fi
