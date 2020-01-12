#!/bin/bash -xv
#

AUDIO_B64="audio.b64"
AUDIO="audio"
# PAYLOAD_FILE="payload.json"
# RECEIVED_MQTT="received.mqtt"
# RECEIVED_PAYLOAD="received.json"


function relDir() {
  _DIR="$1"
  if [[ $_DIR =~ ^/ ]] ; then
    echo "$_DIR"
  else
    echo "$SUSI_INSTALLATION/$_DIR"
  fi
}



# mqtt_sub/pub command with optional user/password:
#
function mqtt_auth() {

  # _FLAGS="-C 1 -v"
  _FLAGS=""

  [[ -n $mqtt_host ]] && _FLAGS="$_FLAGS -h $mqtt_host"
  [[ -n $mqtt_port ]] && _FLAGS="$_FLAGS -p $mqtt_port"
  [[ -n $mqtt_user ]] && _FLAGS="$_FLAGS -u $mqtt_user"
  [[ -n $mqtt_password ]] && _FLAGS="$_FLAGS -P $mqtt_password"

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

  MQTT_COUNTER=$(($MQTT_COUNTER + 1))
  RECEIVED_BASE="${MQTT_BASE_NAME}-$(printf "%04d" $MQTT_COUNTER)"
  RECEIVED_PAYLOAD="${RECEIVED_BASE}.json"
  RECEIVED_MQTT="${RECEIVED_BASE}.mqtt"

  $mqtt_subscribe -C 1 -v $(mqtt_auth) $__TOPICS > $RECEIVED_MQTT
  # _CMD="$mqtt_subscribe -C 1 -v $(mqtt_auth) $__TOPICS"
  # _RECIEVED="$($_CMD)"
  # _CMD="$mqtt_subscribe -C 1 -v $(mqtt_auth) $__TOPICS"
  parseMQTT $RECEIVED_MQTT
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

  MQTT_TOPIC=$(cat $RECEIVED_MQTT | grep -Po '^.*?(?= {)')
  cat $RECEIVED_MQTT | grep -Pzo '\{[\s\S]*\}' > $RECEIVED_PAYLOAD
  MQTT_SITE_ID=$(extractJSONfile .siteId $RECEIVED_PAYLOAD)
  MQTT_SESSION_ID=$(extractJSONfile .sessionId $RECEIVED_PAYLOAD)
  MQTT_ID=$(extractJSONfile .id $RECEIVED_PAYLOAD)
  # MQTT_TOPIC=$(echo "$_MQTT" | grep -Po '^.*?(?= {)')
  # MQTT_PAYLOAD=$(echo "$_MQTT" | grep -Pzo '\{[\s\S]*\}')
  # MQTT_SITE_ID=$(extractJSON .siteId $MQTT_PAYLOAD)
  # MQTT_SESSION_ID=$(extractJSON .sessionId $MQTT_PAYLOAD)
  # MQTT_ID=$(extractJSON .id $MQTT_PAYLOAD)
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
function extractJSONfile() {
  _FIELD=$1
  if [[ $# -gt 1 ]] ; then
    _FILE=$2
  else
    _FILE=$RECEIVED_PAYLOAD
  fi
  cat $_FILE | jq -r $_FIELD
}


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

  _TOPIC="$1"
  _PAYLOAD="$2"
  $mqtt_publish  -t "$_TOPIC" -m "$_PAYLOAD"
}

function publishFile() {

  _TOPIC="$1"
  _PAYLOAD="$2"
  $mqtt_publish  -t "$_TOPIC" -s <"$_PAYLOAD"
}
