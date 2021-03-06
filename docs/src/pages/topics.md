

# Topics:

This is a complete list of MQTT topics processed by Susi.

#### DialogueManager
```
TOPIC_START_SESSION="hermes/dialogueManager/startSession"
TOPIC_END_SESSION="hermes/dialogueManager/endSession"
TOPIC_CONTINUE_SESSION="hermes/dialogueManager/continueSession"
TOPIC_SESSION_ENDED="hermes/dialogueManager/sessionEnded"

TOPIC_TIMEOUT="susi/session/timeout"
TOPIC_LOG="susi/log/notification"
TOPIC_LOG_SESSION_STARTED="susi/log/sessionStarted"

TOPIC_DIALOGUE_STOP_LISTEN="susi/dialogueManager/stopListen"
TOPIC_DIALOGUE_START_LISTEN="susi/dialogueManager/startListen"
```


#### Hotword
```
TOPIC_HOTWORD_ON="hermes/hotword/toggleOn"
TOPIC_HOTWORD_OFF="hermes/hotword/toggleOff"
TOPIC_HOTWORD="hermes/hotword/detected"
```
#### Speech recognition
```
TOPIC_ASR_START="hermes/asr/startListening"
TOPIC_ASR_AUDIO="susi/asr/audioCaptured"
TOPIC_ASR_TRANSSCRIBE="susi/asr/transscribe"
TOPIC_ASR_TEXT="hermes/asr/textCaptured"

TOPIC_NOTIFICATION_ON="hermes/feedback/sound/toggleOn"
TOPIC_NOTIFICATION_OFF="hermes/feedback/sound/toggleOff"

TOPIC_DIALOGUE_STOP_LISTEN="susi/dialogueManager/stopListen"
TOPIC_DIALOGUE_START_LISTEN="susi/dialogueManager/startListen"
```

#### NLU
```
TOPIC_NLU_QUERY="hermes/nlu/query"
TOPIC_NLU_PARSED="hermes/nlu/intentParsed"
TOPIC_NLU_NOT="hermes/nlu/intentNotRecognized"
TOPIC_DIALOGUE_NLU_NOT="hermes/dialogueManager/intentNotRecognized"

TOPIC_NLU_INTENT_FILTER="hermes/dialogueManager/configure"
TOPIC_NLU_RESET_INTENT_FILTER="hermes/dialogueManager/configureReset"
```

#### Play audio
```
TOPIC_TTS_SAY="hermes/tts/say"
TOPIC_TTS_REQUEST="susi/tts/request"
TOPIC_TTS_AUDIO="susi/tts/audio"
TOPIC_SAY_FINISHED="hermes/tts/sayFinished"
TOPIC_PLAY_FINISHED="susi/playserver/playFinished"
TOPIC_PLAY="susi/play/playAudio"
TOPIC_PLAY_REQUEST="susi/playserver/request"
```

#### Skill server
```
TOPIC_INTENT="hermes/intent"
```
