#!/bin/bash -xv
#
# interface to TTS services:
# usage:
#
# $ ttsRest.sh filename language text as many words as necessary
#
# languages: any language code, such as de-DE, en-US, etc.
#            for de-DE and en-GB the voices "de-DE-Wavenet-C" and
#            "en-GB-Wavenet-A" are pre-selected.
#
# The resulting wav is stored played ad stored as "filename" in the
# work dir.
#
# (c) Andreas Dominik
# THM University of Applied Sciences
# Gießen, DE
#
# License: GPL3
#
AUDIO_NAME=$1
shift
LANGUAGE=$1
shift
TEXT="$@"

# define voices:
#
if [[ $LANGUAGE == de-DE ]] ; then
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

# check if a new accesstoken is neccessary:
# (token is valid about 60 mins)
#
TMP_TOKEN="/tmp/google_tmp_access_token"
${GOOGLE_TTS_DIR}/src/refreshToken.sh $TMP_TOKEN
ACCESS_TOKEN="$( cat $TMP_TOKEN )"

curl -XPOST\
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json; charset=utf-8"   \
     --data "$JSON" \
     "https://texttospeech.googleapis.com/v1beta1/text:synthesize" \
     -o audio.json

cat audio.json | sed 's/^.*audioContent\": \"//' | sed 's/[\"{}]//g' | \
                 base64 --decode >  $AUDIO_NAME
