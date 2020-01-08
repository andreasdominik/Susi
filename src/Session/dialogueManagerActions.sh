function publishLog() {

  _MESSAGE=$1
  _PAYLOAD="{
             \"sessionId\": \"$SESSION_ID\",
             \"siteId\": \"$SESSION_SITE_ID\",
             \"customData\": \"$MESSAGE\"
            }"
  publish -t "$TOPIC_WATCH_LOG" -m "$_MESSAGE"
}


function publishSessionEnded() {

  _PAYLOAD="{
            \"sessionId\": \"$SESSION_ID\",
            \"siteId\": \"$SESSION_SITE_ID\",
            \"termination\": { \"reason\":\"$@\" }
           }"
  publish "$TOPIC_SESSION_ENDED" "$_PAYLOAD"
}

function publishHotwordOn() {

  _PAYLOAD="{
            \"sessionId\": \"no_session\",
            \"siteId\": \"$SESSION_SITE_ID\"
           }"
  publish "$TOPIC_HOTWORD_ON" "$_PAYLOAD"
}


function publishAsrStart() {

  _PAYLOAD="{
            \"sessionId\": \"$SESSION_ID\",
            \"siteId\": \"$SESSION_SITE_ID\",
            \"id\": \"$ID\"
           }"
  publish "$TOPIC_ASR_START" "$_PAYLOAD"
}


function publishAsrTransscribe() {

  _PAYLOAD="{
            \"sessionId\": \"$SESSION_ID\",
            \"siteId\": \"$SESSION_SITE_ID\",
            \"id\": \"$ID\",
            \"audio\": \"$AUDIO\"
           }"
  publish "$TOPIC_ASR_TRANSSCRIBE" "$_PAYLOAD"
}


function publishNluQuery() {

  _PAYLOAD="{
            \"sessionId\": \"$SESSION_ID\",
            \"siteId\": \"$SESSION_SITE_ID\",
            \"id\": \"$ID\",
            \"input\": \"$TEXT\"
           }"
  publish "$TOPIC_ASR_TRANSSCRIBE" "$_PAYLOAD"
}

function pubishIntent() {

  _INTENT_NAME="${TOPIC_INTENT}/$(extractJSON .intent.intentName $INTENT)"
  publish "$_INTENT_NAME" "$INTENT"
}



function publishTTSrequest() {

  _PAYLOAD="{
            \"sessionId\": \"$SESSION_ID\",
            \"siteId\": \"$SESSION_SITE_ID\",
            \"id\": \"$ID\",
            \"input\": \"$TEXT\"
           }"
  publish "$TOPIC_TTS_REQUEST" "$_PAYLOAD"
}


function publishPlay() {

  _PLAY_SITE=$1

  _PAYLOAD="{
            \"sessionId\": \"$SESSION_ID\",
            \"siteId\": \"$_PLAY_SITE\",
            \"id\": \"$ID\",
            \"audio\": \"$AUDIO\"
           }"
  publish "$TOPIC_TTS_PLAY" "$_PAYLOAD"
}




# schedule a mqtt timout trigger and define a
# timoutId to be able to identify, if the trigger is still valid
#
function scheduleTimeOut() {

  TIMEOUT_ID="timeout:$(uuidgen)"

  _TOPIC=$TOPIC_TIMEOUT
  _PAYLOAD="{\"id\": \"$TIMEOUT_ID\",
             \"timeout\": $SESSION_TIMEOUT,
             \"siteId\": \"$SESSION_SITE_ID\",
             \"sessionId\": \"$SESSION_ID\",
             \"date\": \"$(date)\"
            }"

  (sleep $SESSION_TIMEOUT; $PUBLISH -t $_TOPIC -m "$_PAYLOAD") &
}




function setDMtopics() {

  case "$DOING" in
    "no_session")
      TOPICS="$TOPIC_HOTWORD $TOPIC_START_SESSION"
      MATCH="no_match"
      SESSION_ID="no_session"
      SESSION_SITE_ID="no_site"
      TIMEOUT_ID="no_timeout"
      ;;
    "wait_for_asr")
      TOPICS="$TOPIC_ASR_AUDIO"
      MATCH="id"
      ;;
    "wait_for_stt")
      TOPICS="$TOPIC_ASR_TEXT"
      MATCH="id"
      ;;
    "wait_for_nlu")
      TOPICS="$TOPIC_NLU_PARSED $TOPIC_NLU_NOT"
      MATCH="id"
      ;;
    "wait_for_tts")
      TOPICS="$TOPIC_TTS_AUDIO"
      MATCH="id"
      ;;
    "playing")
      TOPICS="$TOPIC_TTS_PLAY_FINISHED"
      MATCH="id"
      ;;
    "session_ongoing")
      TOPICS="$TOPIC_END_SESSION $TOPIC_CONTINUE_SESSION $TOPIC_DM_SAY"
      MATCH="id"
      ;;
    *)
      TOPICS=""
      MATCH="no_match"
    ;;
  esac

  if [[ $DOING != "no_session" ]] ; then
    TOPICS="$TOPICS $TOPIC_TIMEOUT"
  fi
}

function subscribeSmart() {

  _MATCH=$1
  shift
  _TOPICS="$@"

  LISTEN="continue"
  while [[ $LISTEN == "continue" ]] ; do

    subscribeOnce $_TOPICS
    # test, if the message is the correct one:
    #
    if [[ $MQTT_TOPIC == $TOPIC_TIMEOUT ]] ; then
      if [[ $MQTT_ID == $TIMEOUT_ID ]] ; then
        LISTEN="done"
      fi
    elif [[ $MQTT_TOPIC == $TOPIC_START_SESSION ]] ||
         [[ $MQTT_TOPIC == $TOPIC_HOTWORD ]] ; then
      LISTEN="done"
    elif [[ $_MATCH == "id" ]] ; then
      if [[ $MQTT_ID == $ID ]] ; then
        LISTEN="done"
      fi
    elif [[ $_MATCH == "session" ]] ; then
      if [[ $MQTT_SESSION_ID == $SESSION_ID ]] ; then
        LISTEN="done"
      fi
    elif [[ $_MATCH == "site" ]] ; then
      if [[ $MQTT_SITE_ID == $SESSION_SITE_ID ]] ; then
        LISTEN="done"
      fi
    fi
  done
}

function nextSessionId() {
  if [[ -z SESSION_ID_COUNTER ]] ; then
    SESSION_ID_COUNTER=1
  else
    let SESSION_ID_COUNTER=$SESSION_ID_COUNTER+1
  fi
  DATE="$(date | sed 's/ /_/g')"
  SESSION_ID="session:${SESSION_ID_COUNTER}_$DATE"
}
