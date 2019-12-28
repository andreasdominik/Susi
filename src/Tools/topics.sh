
# Topics:
#

# DialogueManager topics:
#
TOPIC_START_SESSION="hermes/dialogueManager/startSession"
TOPIC_END="hermes/dialogueManager/endSession"
TOPIC_CONTINUE_SESSION="hermes/dialogueManager/continueSession"
TOPIC_SESSION_ENDED="hermes/dialogueManager/sessionEnded"
# TOPIC_COMMAND="qnd/dialogueManager/startCommand"
# TOPIC_API="qnd/dialogueManager/startAPIcall"


# Snips Hermes and QnD topics:
#
TOPIC_HOTWORD_ON="hermes/hotword/toggleOn"
TOPIC_HOTWORD_OFF="hermes/hotword/toggleOff"
TOPIC_HOTWORD="hermes/hotword/detected"

TOPIC_ASR_START="hermes/asr/startListening"
TOPIC_ASR_AUDIO="qnd/asr/audioCaptured"
TOPIC_ASR_TRANSSCRIBE="qnd/asr/transsribe"
TOPIC_ASR_TEXT="hermes/asr/textCaptured"

TOPIC_NLU_QUERY="hermes/nlu/query"
TOPIC_NLU_PARSED="hermes/nlu/intentParsed"
TOPIC_NLU_NOT="hermes/nlu/intentNotRecognized"

TOPIC_TTS_REQUEST="qnd/tts/request"
TOPIC_TTS_AUDIO="qnd/tts/audio"

# QnD NoSnips topics:
#
TOPIC_TIMEOUT="qnd/session/timeout"
TOPIC_WATCH_LOG="qnd/watch/log"
