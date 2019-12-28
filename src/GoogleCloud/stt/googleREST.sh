#!/bin/bash -xv
#
# retrieve a transscript from Google stt
#
AUDIO_NAME=$1
JSON=$2

#${SUSI_DIR}/src/STT/Google/refreshToken.sh
TMP_TOKEN="${SUSI_DIR}/Work/GOOGLE_TMP_ACCESS_TOKEN"
ACCESS_TOKEN="$( cat $TMP_TOKEN )"

# base64 encode wav:
#SPEECH="$( base64 $AUDIO_NAME)"

# make JSON request:
#
REQUEST="sttRequest.json"

echo "{ "                                                      >  $REQUEST
echo "  \"config\" : {"                                        >> $REQUEST
echo "      \"encoding\" : \"FLAC\","                          >> $REQUEST
echo "      \"sampleRateHertz\" : 16000,"                      >> $REQUEST
echo "      \"languageCode\" : \"de-DE\","                     >> $REQUEST
echo "      \"alternativeLanguageCodes\" : [\"en-US\"],"       >> $REQUEST
# echo "      \"speechContexts\" : {"                            >> $REQUEST
# echo "         \"phrases\" : ["                                >> $REQUEST
# echo "            \"phrase eins\","                            >> $REQUEST
# echo "            \"phrase zwei\""                             >> $REQUEST
# echo "          ]"                                             >> $REQUEST
# echo "       },"                                               >> $REQUEST
echo "      \"maxAlternatives\" : 1,"                          >> $REQUEST
echo "      \"model\" : \"command_and_search\"",               >> $REQUEST
echo "      \"enableWordTimeOffsets\" : false"                 >> $REQUEST
echo "  },"                                                    >> $REQUEST
echo "  \"audio\" : {"                                         >> $REQUEST
echo "      \"content\" : \"$( base64 $AUDIO_NAME )\" "        >> $REQUEST
echo "  }"                                                     >> $REQUEST
echo "}"                                                       >> $REQUEST



curl -v -XPOST --http2 'https://speech.googleapis.com/v1p1beta1/speech:recognize' \
   -H "Content-Type: application/json" \
   -H "Authorization: Bearer $ACCESS_TOKEN" \
   -d @$REQUEST -o $JSON
