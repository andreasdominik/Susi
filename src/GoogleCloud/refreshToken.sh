#!/bin/bash -xv
#
# refreshes the google access token (valid approx. 1 hour)
# usage:
#
# $ refreshToke.sh
#
# without arguments
#
#
# (c) Andreas Dominik
# THM University of Applied Sciences
# Gießen, DE
#
# License: GPL3
#


# check if a new access token is neccessary:
#
TMP_TOKEN=$1

if (! test -e $TMP_TOKEN ) || test "$(find $TMP_TOKEN -type f -mmin +30)" ; then
  echo "refresh Google access token"
  export GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_TTS_DIR}/Credentials/google-credentials.json
  echo "$(gcloud auth application-default print-access-token)" > $TMP_TOKEN

  # check if successful:
  T_SIZE=$(cat $TMP_TOKEN | wc -c)
  if [[ $T_SIZE -lt 10 ]] ; then
    rm $TMP_TOKEN
  fi
else
  echo "Google access token still valid"
fi
