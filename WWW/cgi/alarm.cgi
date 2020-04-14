#!/bin/bash
#
export SUSI_INSTALLATION="/opt/Susi/Susi"

function fixtime() {
  _TIME=$1

  if [[ ${_TIME} =~ wakeuptime=([0-9]{2})%3A([0-9]{2}) ]] ; then
    _HOUR=${BASH_REMATCH[1]}
    _MINUTE=${BASH_REMATCH[2]}
    __TIME="${_HOUR} uhr ${_MINUTE}"
  else
    __TIME="unknown"
  fi
  echo $__TIME
}


# echo $QUERY_STRING
WAKEUP_TIME="$(fixtime $QUERY_STRING)"
# echo $WAKEUP_TIME
#
if [[ $WAKEUP_TIME != unknown ]] ; then

  CMD="stelle den Wecker auf $WAKEUP_TIME Uhr"
  susi ${CMD}  > /dev/null 2>&1
  cat okbed.html
else
  cat error.html
fi
