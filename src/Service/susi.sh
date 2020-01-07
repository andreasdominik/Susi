#!/bin/bash -vx
#
# Basic service for NoSnips replacement service.
# Usage:
#     susi.sh path/to/susi.toml
#
# https://github.com/dbohdan/remarshal is used for reading toml
# jq is used for parsing JSON
#

# set config path
# and make a JSON config in work dir:
#
if [[ $# -lt 1 ]] ; then
  CONFIG="/etc/susi.toml"
else
  CONFIG=$1
fi
cd /tmp
cat $CONFIG | toml2json > susi.json

TOML="$(cat susi.json)"
BASE_DIR="$(echo $TOML | jq -r .local.base_directory)"
WORK_DIR="$(echo $TOML | jq -r .local.work_directory)"
export BASE_DIR

# load tool funs:
#
source $BASE_DIR/src/Tools/funs.sh

IS_SATELLITE="$(extractJSON .local.satellite $TOML)"
if [[ $IS_SATELLITE == true ]] ; then
  DAEMONS="hotword record say"
else
  DAEMONS="hotword record say stt nlu duckling tts session"
fi

MONITOR_PIDS=""

function startDaemon() {

  _DAEMON=$1
  _FLAG="$(extractJSON .$_DAEMON.start $TOML)"

  if [[ $_FLAG == true ]] ; then
    echo "starting $_DAEMON daemon"
    _EXEC="$(extractJSONdir .$_DAEMON.daemon $TOML)"
    $_EXEC $CONFIG &

    # make list to monitor:
    #
    _PID=$!
    MONITOR_PIDS="$MONITOR_PIDS $_PID $_DAEMON"
  fi
}

for DAEMON in $DAEMONS ; do
  startDaemon $DAEMON
done


# monitor all daemons and restart:
#
while true ; do
  sleep 10
  set -- $MONITOR_PIDS
  MONITOR_PIDS=""

  while [[ $# -gt 1 ]] ; do
    __PID=$1
    __DAEMON=$2
    shift 2

    ps -p $__PID
    __IS_OK=$?

    if [[ $__IS_OK -gt 0 ]] ; then
      startDaemon $__DAEMON
    else
      MONITOR_PIDS="$MONITOR_PIDS $__PID $__DAEMON"
    fi
    sleep 1
  done
done
