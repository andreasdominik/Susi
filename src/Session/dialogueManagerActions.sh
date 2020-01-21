function publishLogSessionStarted() {

  _PAYLOAD="{
             \"sessionId\": \"$SESSION_ID\",
             \"siteId\": \"$SESSION_SITE_ID\",
             \"init\": {\"type\": \"$TYPE\"}
            }"
  publish "$TOPIC_LOG_SESSION_STARTED" "$_PAYLOAD"
}


function publishLog() {

  _MESSAGE=$1
  _PAYLOAD="{
             \"sessionId\": \"$SESSION_ID\",
             \"siteId\": \"$SESSION_SITE_ID\",
             \"customData\": \"$MESSAGE\"
            }"
  publish "$TOPIC_LOG" -m "$_MESSAGE"
}


function publishSessionEnded() {

  _PAYLOAD="{
            \"sessionId\": \"$SESSION_ID\",
            \"siteId\": \"$SESSION_SITE_ID\",
            \"customData\": \"$CUSTOM_DATA\",
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


function publishHotwordOff() {

  _PAYLOAD="{
            \"sessionId\": \"no_session\",
            \"siteId\": \"$SESSION_SITE_ID\"
           }"
  publish "$TOPIC_HOTWORD_OFF" "$_PAYLOAD"
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

  MQTT_COUNTER=$(($MQTT_COUNTER + 1))
  PAYLOAD_FILE="${MQTT_BASE_NAME}-$(printf "%04d" $MQTT_COUNTER).payload"
  echo -n "{
            \"sessionId\": \"$SESSION_ID\",
            \"siteId\": \"$SESSION_SITE_ID\",
            \"id\": \"$ID\",
            \"audio\": \""    >  $PAYLOAD_FILE
  cat $AUDIO_B64 | tr -d '\n' >> $PAYLOAD_FILE
  echo "\" }"                 >> $PAYLOAD_FILE
  publishFile "$TOPIC_ASR_TRANSSCRIBE" "$PAYLOAD_FILE"
}


function extractIntentFilter() {

  _FIELD=$1
  _FILENAME=$2
  _INTENT_FILTER="$(extractJSONfile $_FIELD $_FILENAME)"

  if [[ -z $_INTENT_FILTER ]] ; then
    INTENT_FILTER="[]"
  else
    INTENT_FILTER=$_INTENT_FILTER
  fi
}

function publishNluQuery() {

  _PAYLOAD="{
            \"sessionId\": \"$SESSION_ID\",
            \"siteId\": \"$SESSION_SITE_ID\",
            \"id\": \"$ID\",
            \"input\": \"$TEXT\",
            \"intentFilter\": $INTENT_FILTER
           }"
  publish "$TOPIC_NLU_QUERY" "$_PAYLOAD"
}

function publishIntent() {

  _INTENT_PATH=$1
  _INTENT_NAME="${TOPIC_INTENT}/$(extractJSONfile $_INTENT_PATH.intent.intentName $MQTT_PAYLOAD)"

  MQTT_COUNTER=$(($MQTT_COUNTER + 1))
  PAYLOAD_FILE="${MQTT_BASE_NAME}-$(printf "%04d" $MQTT_COUNTER).payload"
  _PAYLOAD="{
              \"sessionId\": \"$SESSION_ID\",
              \"siteId\": \"$SESSION_SITE_ID\",
              \"id\": \"$ID\",
              \"input\": \"$(extractJSONfile $_INTENT_PATH.input $MQTT_PAYLOAD)\",
              \"slots\": $(extractJSONfile $_INTENT_PATH.slots $MQTT_PAYLOAD),
              \"intent\": $(extractJSONfile $_INTENT_PATH.intent $MQTT_PAYLOAD)
             }"

  publish "$_INTENT_NAME" "$_PAYLOAD"
}



function publishTTSrequest() {

_TEXT="$(echo $TEXT)"

  _PAYLOAD="{
            \"sessionId\": \"$SESSION_ID\",
            \"siteId\": \"$SESSION_SITE_ID\",
            \"lang\": \"$LANG\",
            \"id\": \"$ID\",
            \"input\": \"$_TEXT\"
           }"
  publish "$TOPIC_TTS_REQUEST" "$_PAYLOAD"
  LANG=$assistant_language
}


function publishPlay() {

  _PLAY_SITE=$1
  MQTT_COUNTER=$(($MQTT_COUNTER + 1))
  PAYLOAD_FILE="${MQTT_BASE_NAME}-$(printf "%04d" $MQTT_COUNTER).payload"
  echo -n "{
    \"sessionId\": \"$SESSION_ID\",
    \"siteId\": \"$PLAY_SITE\",
    \"id\": \"$ID\",
    \"audio\": \""              >  $PAYLOAD_FILE
    cat $AUDIO_B64              >> $PAYLOAD_FILE
    echo "\" }"                 >> $PAYLOAD_FILE

  publishFile "$TOPIC_PLAY_REQUEST" "$PAYLOAD_FILE"
}


function publishSayFinished() {

  _ID="$1"

  PAYLOAD="{
            \"sessionId\": \"$MQTT_SESSION_ID\",
            \"id\": \"$_ID\",
            \"siteId\": \"$MQTT_SITE_ID\"
           }"
  publish "$TOPIC_SAY_FINISHED" "$PAYLOAD"
}



function publishIntentNotRecognized(){

  PAYLOAD="{
            \"sessionId\": \"$MQTT_SESSION_ID\",
            \"customData\": \"$CUSTOM_DATA\",
            \"siteId\": \"$SESSION_SITE_ID\"
           }"
  publish "$TOPIC_DIALOGUE_NLU_NOT" "$PAYLOAD"
}

# schedule a mqtt timout trigger and define a
# timoutId to be able to identify, if the trigger is still valid
#
function scheduleTimeOut() {

  TIMEOUT_ID="timeout:$(uuidgen)"

  _TOPIC=$TOPIC_TIMEOUT
  _PAYLOAD="{\"id\": \"$TIMEOUT_ID\",
             \"timeout\": \"$session_session_timeout sec timeout\",
             \"siteId\": \"$SESSION_SITE_ID\",
             \"sessionId\": \"$SESSION_ID\",
             \"date\": \"$(date)\"
            }"

  (sleep $session_session_timeout ; publish $_TOPIC "$_PAYLOAD") &
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

function nextId() {
    ID="id:$(uuidgen)"
}


# performs all steps of ending a session, including:
# look if NLU_ERROR_ACTION is "continue_session"
# and strating the next queued session
#
function makeSessionEnd() {

  _LOG_MESSAGE=$@

  if [[ $ERROR_ACTION == "terminate_session" ]] ; then
      publishSessionEnded "$_LOG_MESSAGE"
      DOING="no_session"
      SESSION_ID="no_session"
      INTENT_FILTER="[]"

      # re-publish queued start requests:
      #
      if [[ ${#START_QUEUE[@]} -gt 1 ]] ; then
        QUEUED_TOPIC="${START_QUEUE[0]}"
        QUEUED_JSON="${START_QUEUE[1]}"
        START_QUEUE=("${START_QUEUE[@]:2}") # slice 2 to end

        (sleep 1; publish $QUEUED_TOPIC "$QUEUED_JSON") &
      else
        # acivate hotword only if nothing in queue:
        #
        publishHotwordOn
        START_QUEUE=()
      fi
      ERROR_ACTION="continue_session"
    elif [[ $ERROR_ACTION == "continue_session" ]] ; then
      publishIntentNotRecognized
    fi
}

# add a start session or hotword to queue, because
# another session is still running.
# queued requests are re-submitted at session end
#
START_QUEUE=()
function addToQueue() {

  START_QUEUE+=("$MQTT_TOPIC")
  START_QUEUE+=("$(cat $RECEIVED_PAYLOAD)")
}
