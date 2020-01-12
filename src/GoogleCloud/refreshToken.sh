#!/bin/bash 
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
CREDS=$1
TMP_TOKEN="google_cloud.tmptoken"

if (! test -e $TMP_TOKEN ) || test "$(find $TMP_TOKEN -type f -mmin +45)" ; then
  echo "refresh Google access token"
  export GOOGLE_APPLICATION_CREDENTIALS=$CREDS
  echo "$(gcloud auth application-default print-access-token)" > $TMP_TOKEN

  # check if successful:
  T_SIZE=$(cat $TMP_TOKEN | wc -c)
  if [[ $T_SIZE -lt 10 ]] ; then
    rm $TMP_TOKEN
  fi
else
  echo "Google access token still valid"
fi
