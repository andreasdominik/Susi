# read the toml file and init env for Susi
#
CONFIG="/etc/susi.toml"
source $SUSI_INSTALLATION/bin/toml2env $CONFIG

# get 2-digit language code:
#
LANGUAGE_CODE="${assistant_language}"
LANGUAGE=${assistant_language:0:2}

# load tool funs:
#
source $SUSI_INSTALLATION/src/Tools/funs.sh
source $SUSI_INSTALLATION/src/Tools/topics.sh

# counter for recveived and subm. MQTT message files:
#
MQTT_COUNTER=0
