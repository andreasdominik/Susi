#!/bin/bash -xv
#

# read main config from toml, with path/file.toml
# as argument.
#
function readToml() {
  CONFIG=$1
  export TOML="$(cat $CONFIG | toml2json)"
  MQTT_PORT="$(extractJSON .mqtt.port $TOML)"
  MQTT_HOST="$(extractJSON .mqtt.host $TOML)"
  MQTT_USER="$(extractJSON .mqtt.user $TOML)"
  MQTT_PW="$(extractJSON .mqtt.password $TOML)"

  export BASE_DIR="$(extractJSON .local.base_directory $TOML)"
  export WORK_DIR="$(extractJSON .local.work_dir $TOML)"

  export SITE_ID="$(extractJSON .local.siteId $TOML)"
  export SESSION_TIMEOUT="$(extractJSON .session.session_timeout $TOML)"

  SUBSCRIBE="$(extractJSON .mqtt.subscribe $TOML)"
  export SUBSCRIBE="$SUBSCRIBE -C 1 -v $(mqtt_auth)"
  PUBLISH="$(extractJSON .mqtt.publish $TOML)"
  export PUBLISH="$PUBLISH $(mqtt_auth)"
}

# make a dir relative to Susi if not absolute:
#
function relDir() {
  read _DIR
  if [[ $_DIR =~ ^/ ]] ; then
    echo "$_DIR"
  else
    echo "$BASE_DIR/$_DIR"
  fi
}



# mqtt_sub/pub command with optional user/password:
#
function mqtt_auth() {

  # _FLAGS="-C 1 -v"
  _FLAGS=""

  [[ -n $MQTT_HOST ]] && _FLAGS="$_FLAGS -h $MQTT_HOST"
  [[ -n $MQTT_PORT ]] && _FLAGS="$_FLAGS -p $MQTT_PORT"
  [[ -n $MQTT_USER ]] && _FLAGS="$_FLAGS -u $MQTT_USER"
  [[ -n $MQTT_PW ]] && _FLAGS="$_FLAGS -P $MQTT_PW"

  echo "$_FLAGS"
}



# subscribe to MQTT topics and wait only for ONE message
# then parse the message and return topc and payload
# as TOPIC and PAYLOAD.
#
function subscribeOnce() {

  # add topics:
  #
  __TOPICS=""
  for _T in $@ ; do
    __TOPICS="$__TOPICS -t $_T"
  done

  _RECIEVED="$($SUBSCRIBE $__TOPICS)"
  parseMQTT "$_RECIEVED"
}

function subscribeSiteOnce() {
  _SITE=$1
  shift
  _TOPICS=$@

  _MQTT_SITE="_no_site_"
  while [[ $_MQTT_SITE != $_SITE ]] ; do
    subscribeOnce $_TOPICS
    _MQTT_SITE=$MQTT_SITE_ID
  done
}

function parseMQTT() {
  _MQTT=$1

  MQTT_TOPIC=$(echo "$_MQTT" | grep -Po '^.*?(?= {)')
  MQTT_PAYLOAD=$(echo "$_MQTT" | grep -Pzo '\{[\s\S]*\}')
  MQTT_SITE_ID=$(extractJSON .siteId $MQTT_PAYLOAD)
  MQTT_SESSION_ID=$(extractJSON .sessionId $MQTT_PAYLOAD)
  MQTT_ID=$(extractJSON .id $MQTT_PAYLOAD)
}


# extract a field from a JSON string:
# extractJSON .field.name {json string}
#    usage:
#    VAL=$(extractJSON .field {json})
#
# if only one arg, JSON is assumed to be in $TOML
# dirs read with extractJSONdir() will be subdirs
# to BASE_DIR if relative.
#
function extractJSON() {
  _FIELD=$1
  if [[ $# -gt 1 ]] ; then
    shift
    _JSON=$@
  else
    _JSON=$TOML
  fi

  echo "$(echo $_JSON | jq -r $_FIELD)"
}

function extractJSONdir() {
  _FIELD=$1
  if [[ $# -gt 1 ]] ; then
    shift
    _JSON=$@
  else
    _JSON=$TOML
  fi

  echo "$(echo $_JSON | jq -r $_FIELD | relDir)"
}




function publish() {

# echo "publish"
# exit
  _TOPIC="$1"
  _PAYLOAD="$2"

  $PUBLISH  -t "$_TOPIC" -m "$_PAYLOAD"
}
