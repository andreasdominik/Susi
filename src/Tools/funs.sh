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

# add a line to a config file:
# * if not already there => append line
# * if already defined => replace
#
function addOrReplace(){
  _FILE=$1
  _MATCH=$2
  _NEWLINE=$3
  if grep "$_MATCH" $_FILE ; then
    sed -i "s,${_MATCH}.*\$,${_NEWLINE}," $_FILE
  else
     echo "$_NEWLINE" >> $_FILE
   fi

  # grep "^export SUSI_INSTALLATION=" ~susi/.bashrc && \
  #    sed -i 's/^export SUSI_INSTALLATION=.*$/export SUSI_INSTALLATION=\/opt\/Susi\/Susi/' ~susi/.bashrc || \
  #    echo "export SUSI_INSTALLATION=/opt/Susi/Susi" >> ~susi/.bashrc
}

function startMQTTbroker(){

  if ! test -d ${local_application_data}/Susi/Mosquitto ; then
    mkdir -p ${local_application_data}/Susi/Mosquitto
  fi

  MOSQUITTO_DIR="${local_application_data}/Susi/Mosquitto"
  MOSQUITTO_CONF="${MOSQUITTO_DIR}/mosquitto.conf"
  MOSQUITTO_PW="${MOSQUITTO_DIR}/passwd"
  cp /etc/mosquitto/mosquitto.conf $MOSQUITTO_CONF

  addOrReplace $MOSQUITTO_CONF "^log_dest file" "log_dest file ${MOSQUITTO_DIR}/mosquitto.log"
  addOrReplace $MOSQUITTO_CONF "^pid_file" "pid_file ${MOSQUITTO_DIR}/mosquitto.pid"
  addOrReplace $MOSQUITTO_CONF "^persistence_location" "persistence_location ${MOSQUITTO_DIR}/"

  # add user/pw to passdw file if defined in susi.toml:
  #
  if [[ -n $mqtt_user && -n $mqtt_password ]] ; then
    addOrReplace $MOSQUITTO_CONF "^password_file" "password_file $MOSQUITTO_PW"
    addOrReplace $MOSQUITTO_CONF "^allow_anonymous" "allow_anonymous false"
    touch $MOSQUITTO_PW
    mosquitto_passwd -b $MOSQUITTO_PW $mqtt_user $mqtt_password
  else
    addOrReplace $MOSQUITTO_CONF "^allow_anonymous" "allow_anonymous true"
  fi
  mosquitto --daemon --config-file $MOSQUITTO_CONF
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

  echo "subscribeOnce to: $mqtt_subscribe -C 1 -v $(mqtt_auth) $__TOPICS"
  $mqtt_subscribe -C 1 -v $(mqtt_auth) $__TOPICS > $RECEIVED_MQTT
  # _CMD="$mqtt_subscribe -C 1 -v $(mqtt_auth) $__TOPICS"
  # _RECIEVED="$($_CMD)"
  # _CMD="$mqtt_subscribe -C 1 -v $(mqtt_auth) $__TOPICS"
  parseMQTTfile $RECEIVED_MQTT
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

# needs the filenames to be predefined!
#
function parseMQTTfile() {

  MQTT_TOPIC=$(cat $RECEIVED_MQTT | grep -Po '^.*?(?= {)')
  cat $RECEIVED_MQTT | grep -Pzo '\{[\s\S]*\}' > $RECEIVED_PAYLOAD
  MQTT_SITE_ID=$(extractJSONfile .siteId $RECEIVED_PAYLOAD)
  MQTT_SESSION_ID=$(extractJSONfile .sessionId $RECEIVED_PAYLOAD)
  MQTT_ID=$(extractJSONfile .id $RECEIVED_PAYLOAD)
}


function parseMQTT() {
  _MQTT=$1

  MQTT_TOPIC=$(echo "$_MQTT" | grep -Po '^.*?(?= {)')
  RECEIVED_PAYLOAD=$(echo "$_MQTT" | grep -Pzo '\{[\s\S]*\}')
  MQTT_SITE_ID=$(extractJSON .siteId $MQTT_PAYLOAD)
  MQTT_SESSION_ID=$(extractJSON .sessionId $MQTT_PAYLOAD)
  MQTT_ID=$(extractJSON .id $MQTT_PAYLOAD)
}


# extract a field from a JSON string:
# extractJSON .field.name {json string}
#    usage:
#    VAL=$(extractJSON .field {json})
#
function extractJSONfile() {
  _FIELD=$1
  if [[ $# -gt 1 ]] ; then
    _FILE=$2
  else
    _FILE=$RECEIVED_PAYLOAD
  fi
  # make empty if null:
  cat $_FILE | jq -r $_FIELD | sed 's/^null$//'
}


function extractJSON() {
  _FIELD=$1
  if [[ $# -gt 1 ]] ; then
    shift
    _JSON=$@
  else
    _JSON=$TOML
  fi

  # echo "$(echo $_JSON | jq -r $_FIELD)"
  _VAL="$(echo $_JSON | jq -r $_FIELD)"
  if [[ $_VAL == null ]] ; then
    echo ""
  else
    echo $_VAL
  fi
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
  _PAYLOAD="$(echo $2)"   # remove newlines

  $mqtt_publish $(mqtt_auth) -t "$_TOPIC" -m "$_PAYLOAD"
}

function publishFile() {

  _TOPIC="$1"
  _PAYLOAD="$2"

  # rm newlines and add one at the end:
  #
  _PAYLOAD_TMP="${_PAYLOAD}.tmp"
  cat $_PAYLOAD | tr -d '\n' | tr -s ' ' > $_PAYLOAD_TMP
  mv $_PAYLOAD_TMP $_PAYLOAD
  echo "" >> $_PAYLOAD

  $mqtt_publish $(mqtt_auth) -t "$_TOPIC" -s <"$_PAYLOAD"
}


# play a notification sound (arg1).
# if arg1 is a directory, play a randomly selected file
#
function playNotification() {

  _MEDIA=$1
  if [[ -d $_MEDIA ]] ; then
    _FILE="$(shuf -n1 -e $_MEDIA/*)"
  else
    _FILE="$_MEDIA"
  fi

  cp $_FILE ./
  _PLAY_FILE="$(basename $_FILE)"
  $record_play $_PLAY_FILE
}


# decode b64 audio with correct ext:
#
# use ffmpg for formate detection rather then soxi:
# MEDIA_TYPE="$(soxi -t $AUDIO)"
#
# AUDIO_NAME is defined after fun call:
#
function b64_decode() {
  _B64_NAME=$1
  _AUDIO_BASENAME=$2
  base64 --decode $_B64_NAME > $_AUDIO_BASENAME

  MEDIA_TYPE="$(ffprobe -show_format $_AUDIO_BASENAME 2>/dev/null | grep -Po '(?<=format_name=)[0-9a-zA-Z]+$')"
  AUDIO_NAME="${_AUDIO_BASENAME}.${MEDIA_TYPE}"
  mv $_AUDIO_BASENAME $AUDIO_NAME
}
