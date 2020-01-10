#!/bin/bash -xv
#

# # read main config from toml, with path/file.toml
# # as argument.
# # all settings will be stored in env directlywith names:
# # toml_path_path_key
# #
# function readToml() {
#   _CONFIG=$1
#
#   _PREFIX="toml"
#   while read -r _LINE ; do
#     # echo "$_LINE"
#
#     REGEX_VALUE='^\s*(\w.+)\s*=\s*(.*\S+.*?)\s*$'
#     REGEX_PATH='^\s*\[(\w.+)\]\s*$'
#     if [[ "$_LINE" =~ $REGEX_VALUE ]] ; then
#       _KEY="${BASH_REMATCH[1]}"
#       _VAL="${BASH_REMATCH[2]}"
#
#       # strip whitespaces:
#       #
#       _KEY="$(echo $_KEY | tr -d '"')"
#       _VAL="$(echo $_VAL)"
#
#       _FULL_KEY="${_PREFIX}_${_KEY}"
#       eval "${_FULL_KEY}"="${_VAL}"
#       echo "${_FULL_KEY}, ${!_FULL_KEY}"
#     elif [[ "$_LINE" =~ $REGEX_PATH ]]; then
#       _PATH="${BASH_REMATCH[1]}"
#       _PREFIX="toml_${_PATH}"
#     fi
#
#   done < $_CONFIG
# }
#
#
#
# function readToml() {
#   CONFIG=$1
#   export TOML="$(cat $CONFIG | toml2json)"
#   MQTT_PORT="$(extractJSON .mqtt.port $TOML)"
#   MQTT_HOST="$(extractJSON .mqtt.host $TOML)"
#   MQTT_USER="$(extractJSON .mqtt.user $TOML)"
#   MQTT_PW="$(extractJSON .mqtt.password $TOML)"
#
#   export BASE_DIR="$(extractJSON .local.base_directory $TOML)"
#   export WORK_DIR="$(extractJSONdir .local.work_dir $TOML)"
#
#   export SITE_ID="$(extractJSON .local.siteId $TOML)"
#   export SESSION_TIMEOUT="$(extractJSON .session.session_timeout $TOML)"
#
#   SUBSCRIBE="$(extractJSON .mqtt.subscribe $TOML)"
#   export SUBSCRIBE="$SUBSCRIBE -C 1 -v $(mqtt_auth)"
#   PUBLISH="$(extractJSON .mqtt.publish $TOML)"
#   export PUBLISH="$PUBLISH $(mqtt_auth)"
# }

# make a dir relative to Susi if not absolute:
#
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

  _CMD="$mqtt_subscribe -C 1 -v $(mqtt_auth) $__TOPICS"
  _RECIEVED="$($_CMD)"
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

  $mqtt_publish  -t "$_TOPIC" -m "$_PAYLOAD"
}
