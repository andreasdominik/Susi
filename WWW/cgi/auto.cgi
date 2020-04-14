#!/bin/bash
#
export SUSI_INSTALLATION="/opt/Susi/Susi"

function fixdate() {
  _DATE=$1

  if [[ ${_DATE} =~ ([0-9]{4})-([0-9]{2})-([0-9]{2}) ]] ; then
    _YEAR=${BASH_REMATCH[1]}
    _MONTH=${BASH_REMATCH[2]}
    _DAY=${BASH_REMATCH[3]}
    __DATE="${_DAY}.${_MONTH}.${_YEAR}"
  else
    __DATE="01.01.1900"
  fi
  echo $__DATE
}


REGEX='^startdate=([0-9]{4}-[0-9]{2}-[0-9]{2})&enddate=([0-9]{4}-[0-9]{2}-[0-9]{2})&profile=(.+)$'
if [[ $QUERY_STRING =~ $REGEX ]] ; then
  START_DATE="${BASH_REMATCH[1]}"
  END_DATE="${BASH_REMATCH[2]}"
  PROFILE="${BASH_REMATCH[3]}"
  PROFILE="$(echo $PROFILE | sed 's/+/ /g')"

  # fix dates:
  #
  START_DATE="$(fixdate $START_DATE)"
  END_DATE="$(fixdate $END_DATE)"

  CMD="programmiere das Haus von $START_DATE bis $END_DATE im Profil $PROFILE"
  susi ${CMD}  > /dev/null 2>&1
  cat ok.html
else
  cat error.html
fi
# susi schalte den Fernseher im Wohnzimmer an > /dev/null 2>&1
#
# cat oktv.html
