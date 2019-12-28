#!/bin/bash -xv
#
#

MAX_TIME=$1
STT="${SUSI_DIR}/src/STT/Google/googleREST.sh"
EMPTY_TS="${SUSI_DIR}/src/STT/Google/empty.json"

${SUSI_DIR}/src/Hardware/Internet/checkservices.sh

# check if a new access token is necessary
# (in background, inparallel to record)
#
${SUSI_DIR}/src/STT/Google/refreshToken.sh &

AUDIO_NAME="cmd.flac"
STT_OUTPUT="cmdservice.json"
TS_NAME="cmd.ts"

# record == tell daemon to record and wait until done:
#
echo $MAX_TIME > record.voice.main
while [[ -e record.voice.main ]] ; do
  sleep 0.05
done

if [[ -s $AUDIO_NAME ]] ; then
  $STT $AUDIO_NAME $STT_OUTPUT   > /dev/null 2>&1

  # generate simple standardised JSON for Susi
  # and fix if ts is corrupted:
  #
  grep 'transcript' $STT_OUTPUT
  TS_OK=$?

  if [[ $TS_OK -eq 0 ]] ; then
    TS="$( cat $STT_OUTPUT | jq '.results[].alternatives[].transcript' | sed 's/[^0-9a-zA-Z]/ /g')"

    echo "{"                             >  $TS_NAME
    echo "   \"transscript\": \"$TS\" "  >> $TS_NAME
    echo "}"                             >> $TS_NAME
  else
    cp $EMPTY_TS $TS_NAME
  fi
else
  cp $EMPTY_TS $TS_NAME
fi

echo "transscript is:"
cat $TS_NAME
