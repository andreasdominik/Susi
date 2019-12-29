#!/bin/bash -vx
#
# Basic service for NoSnips replacement service.
# Usage:
#     nosnips.sh path/to/nosnips.toml
#
# https://github.com/dbohdan/remarshal is used for reading toml
# jq is used for parsing JSON
#

# set config path:
#
if [[ $# -lt 1 ]] ; then
  CONFIG="/etc/nosnips.toml"
else
  CONFIG=$1
fi

TOML="$(cat $CONFIG | toml2json)"
BASE_DIR="$(echo $TOML | jq -r .local.base_directory)"
WORK_DIR="$(echo $TOML | jq -r .local.work_directory)"
export BASE_DIR

# load tool funs:
#
source $BASE_DIR/Tools/funs.sh

IS_SATELLITE="$(extractJSON .local.satellite $TOML)"
if [[ $IS_SATELLITE == true ]] ; then
  DAEMONS="hotword record say"
else
  DAEMONS="hotword record say stt nlu tts session"
fi

function startDaemon() {

  _DAEMON=$1
  _FLAG="$(extractJSON .$_DAEMON.start $TOML)"

  if [[ $_FLAG == true ]] ; then
    echo "starting $_DAEMON daemon"
    _EXEC="$(extractJSON .$_DAEMON.daemon $TOML)"
    $BASE_DIR/$_EXEC $CONFIG &
  fi
}

for DAEMON in $DAEMONS ; do
  startDaemon $DAEMON
done
