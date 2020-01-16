
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
TOPIC_ASR_AUDIO="susi/asr/audioCaptured"
TOPIC_ASR_TRANSSCRIBE="susi/asr/transsribe"
TOPIC_ASR_TEXT="hermes/asr/textCaptured"
TOPIC_NOTIFICATION_ON="hermes/feedback/sound/toggleOn"
TOPIC_NOTIFICATION_OFF="hermes/feedback/sound/toggleOff"

TOPIC_NLU_QUERY="hermes/nlu/query"
TOPIC_NLU_PARSED="hermes/nlu/intentParsed"
TOPIC_NLU_NOT="hermes/nlu/intentNotRecognized"

TOPIC_TTS_SAY="hermes/tts/say"
TOPIC_TTS_REQUEST="susi/tts/request"
TOPIC_TTS_AUDIO="susi/tts/audio"
TOPIC_PLAY_FINISHED="susi/play/playFinished"
TOPIC_PLAY="susi/play/playAudio"

TOPIC_INTENT="hermes/intent"

# QnD NoSnips topics:
#
TOPIC_TIMEOUT="susi/session/timeout"
TOPIC_LOG="susi/log/notification"
TOPIC_LOG_SESSION_STARTED="susi/log/sessionStarted"
