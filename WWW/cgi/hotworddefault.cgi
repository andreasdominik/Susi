#!/bin/bash
#
export SUSI_INSTALLATION="/opt/Susi/Susi"
# set config path:
#
source $SUSI_INSTALLATION/src/Tools/init_susi.sh

# construct MQTT message for hotword detected
#
PAYLOAD="{
  \"siteId\": \"$local_siteId\",
  \"modelId\": \"$hotword_local_hotword\",
  \"modelVersion\": \"1.0\",
  \"modeltype\": \"personal\",
  \"currentSensitivity\": $hotword_sensitivity
}"

publish $TOPIC_HOTWORD "$PAYLOAD"
cat ok.html
