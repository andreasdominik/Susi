#!/bin/bash
#
# Basic service for NoSnips replacement service.
# Usage:
#     susi.sh path/to/susi.toml
#
# https://github.com/dbohdan/remarshal is used for reading toml
# jq is used for parsing JSON
#

CONFIG="/etc/susi.toml"
source $SUSI_INSTALLATION/bin/toml2env $CONFIG

# load tool funs:
#
source $SUSI_INSTALLATION/src/Tools/funs.sh
source $SUSI_INSTALLATION/src/Tools/topics.sh

cd $local_work_directory

if [[ $local_satellite == true ]] ; then
  DAEMONS="hotword record say"
else
  DAEMONS="hotword record play stt nlu duckling tts session"
fi

MONITOR_PIDS=""

function startDaemon() {

  _DAEMON=$1
  _RUN_KEY="${DAEMON}_start"
  _PATH_KEY="${DAEMON}_daemon"
  _FLAG=${!_RUN_KEY}
  _EXEC="$(relDir ${!_PATH_KEY})"

  if [[ $_FLAG == true ]] ; then
    echo "starting $_DAEMON daemon"
    $_EXEC &

    # make list to monitor:
    #
    _PID=$!
    MONITOR_PIDS="$MONITOR_PIDS $_PID $_DAEMON"
  fi
}

for DAEMON in $DAEMONS ; do
  echo "Starting $DAEMON"
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
