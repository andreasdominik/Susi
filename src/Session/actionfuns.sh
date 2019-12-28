#!/bin/bash
#
# functions to run one action, triggered by hotword
#

TOPIC_ASK_AUDIO="nosnips/record/asc"
TOPIC_AUDIO="nosnips/record/audio"

TOPIC_ASK_STT="nosnips/stt/asc"
TOPIC_STT="nosnips/stt/transscript"

TOPIC_ASK_NLU="nosnips/nlu/asc"
TOPIC_NLU="nosnips/nlu/intent"

TOPIC_ASK_TTS="nosnips/tts/asc"
TOPIC_TTS="nosnips/tts/audio"

TOPC_HERMES_SAY="hermes/tts/say"


# runs all snips-replacements to process one action:
#
function runactionfun() {

  # ask satellite to record command
  # and wait for audio (or exit if no audio):
  #
  _REQUEST_ID="$(uuidgen)"
  _PAYLOAD="{
             \"sessionId\": \"$SESSION_ID\",
             \"siteId\": \"$SESSION_SITE_ID\",
             \"requestId\": \"$_REQUEST_ID\"
           }"

  $PUBLISH -t $TOPIC_ASK_AUDIO -m $_PAYLOAD

  MQTT_REQ_ID="no_ID"
  while [[ $MQTT_REQ_ID != $_REQUEST_ID ]] ; do
    subscribeSiteOnce $SESION_SITE_ID $TOPIC_AUDIO
    MQTT_REQ_ID="$(extractJSON .requestId $MQTT_PAYLOAD)"
  done

  AUDIO="$($extractJSON .audio $MQTT_PAYLOAD)"

  if [[ -z $AUDIO ]] ; then
    return
  fi


  # send audio to STT
  # and wait for text:
  #
  _REQUEST_ID="$(uuidgen)"
  _PAYLOAD="{
             \"sessionId\": \"$SESSION_ID\",
             \"siteId\": \"$SESSION_SITE_ID\",
             \"requestId\": \"$_REQUEST_ID\",
             \"audio\": \"$AUDIO\"
           }"

  $PUBLISH -t $TOPIC_ASK_STT -m $_PAYLOAD

  MQTT_REQ_ID="no_ID"
  while [[ $MQTT_REQ_ID != $_REQUEST_ID ]] ; do
    subscribeSiteOnce $SESION_SITE_ID $TOPIC_STT
    MQTT_REQ_ID="$(extractJSON .requestId $MQTT_PAYLOAD)"
  done

  TS="$($extractJSON .transscript $MQTT_PAYLOAD)"

  if [[ -z $TS ]] ; then
    return
  fi

  # send command to NLU
  # and do NOT receive result, because NLU pubishes intent:
  #
  _PAYLOAD="{
             \"sessionId\": \"$SESSION_ID\",
             \"siteId\": \"$SESSION_SITE_ID\",
             \"transscript\": \"$TS\"
           }"

  $PUBLISH -t $TOPIC_ASK_NLU -m $_PAYLOAD
}



# runs all snips-replacements to process one notification:
#
function runnotificationfun() {


  _REQUEST_ID="$(uuidgen)"
  _TEXT="$(extractJSON .init.text $MQTT_PAYLOAD)"

  # publish say:
  #
  _PAYLOAD="{
             \"sessionId\": \"$SESSION_ID\",
             \"siteId\": \"$SESSION_SITE_ID\",
             \"id\": \"$_REQUEST_ID\",
             \"text\": \"$_TEXT\"
           }"

  $PUBLISH -t $TOPIC_HERMES_SAY -m $_PAYLOAD

  # wait until finished:
  #
  PAYLOAD="{
             \"id\": \"$_REQUEST_ID\",
             \"sessionId\": \"$SESSION_ID\",
           }"

  MQTT_REQ_ID="no_ID"
  while [[ $MQTT_REQ_ID != $_REQUEST_ID ]] ; do
    subscribeOnce $TOPIC_NLU
    MQTT_REQ_ID="$(extractJSON .id $MQTT_PAYLOAD)"
  done

  INTENT="$($extractJSON .intent $MQTT_PAYLOAD)"

  if [[ -z $INTENT ]] ; then
    return
  fi
  # publish intent:
  #
  INTENT_NAME="$(extractJSON .intent.intentName, $INTENT)"
  $PUBLISH -t $INTENT_NAME -m $INTENT
}


function subscribeStartSession() {

  # wait for a session start MQTT
  # defines: MQTT_TOPIC, MQTT_PAYLOAD and MQTT_SITE_ID
  #
  subscribeOnce $TOPIC_HOTWORD $TOPIC_API
  SESSION_SITE_ID=$MQTT_SITE_ID

  # if hotword or start session, start a new session:
  #
  DO="ignore"
  if [[ $MQTT_TOPIC == $TOPIC_HOTWORD ]] ; then
    DO="action"
    TRIGGERED_BY="hotword detected"

  elif [[ $MQTT_TOPIC == $TOPIC_API ]] ; then
    TRIGGERED_BY="start session API call"
    TYPE="$(extractJSON .init.type $MQTT_PAYLOAD)"

    if [[ $TYPE == "action" ]] ; then
      DO="action"
    else
      DO="notification"
    fi
  fi

  # cancel if nothing meaningful recived:
  #
  if [[ $DO == "ignore" ]] ; then
    NEXT_ACTION="start_session"
    return
  fi



  # now a new session is started!
  #
  SESSION_ID="$(uuidgen)"

  # construct MQTT message for session started
  #
  TOPIC="hermes/dialogueManager/sessionStarted"
  PAYLOAD="{
    \"sessionId\": \"$SESSION_ID\",
    \"siteId\": \"$SESSION_SITE_ID\",
    \"customData\": \"Session started because of $TRIGGERED_BY\"
  }"
  $PUBLISH -t $TOPIC -m $PAYLOAD

  # prepare timeout:
  # (i.e. create a new timeout-id and schedule mqtt trigger)
  #
  scheduleTimeOut $TIMEOUT $SESION_SITE_ID

  # run the session until session end message:
  #
  if [[ $DO == "action" ]] ; then
    NEXT_ACTION=
    runactionfun &
    ACTION_PID=$!
  elif [[ $DO == "notifiation" ]] ; then
    runnotificationfun &
    ACTION_PID=$!
  fi

  # wait for session timeout:
  #
  DO_SESSION="run"
  while [[ $DO_SESSION == "run" ]] ; do

    subscribeSiteOnce $SESION_SITE_ID $TOPIC_END $TOPIC_CONTINUE $TOPIC_TIMEOUT

    if [[ $MQTT_TOPIC == $TOPIC_CONTINUE ]] ; then
      scheduleTimeOut $TIMEOUT $SESION_SITE_ID
      $RUN_ACTION $MQTT_PAYLOAD &

    elif [[ $MQTT_TOPIC == $TOPIC_END ]] ; then
      DO_SESSION="end"

    elif [[ $MQTT_TOPIC == $TOPIC_TIMEOUT ]] &&
         [[ $TIMEOUT_ID == $(extractJSON .timeoutID $MQTT_PAYLOAD)]] ; then
      DO_SESSION="timeout"
      kill -9 $ACTION_PID
    fi
  done
}
