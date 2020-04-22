
# Definition of NoSnips MQTT-payloads

### Example intent

The intent is constructed by the NLU component and sent to the session manager
as part of the payload of the topic `hermes/nlu/intentParsed`.
The session manager publishes the intent.

```
{
  "siteId": "default",
  "sessionId": "d15eb1a0-67ba-4a3b-a378-a5b06e370719",
  "input": "bitte schalte die stehlampe an",
  "intent": {
    "intentName": "andreasdominik:ADoSnipsOnOffDE",
    "confidenceScore": 1
  },
  "slots": [
    {
      "rawValue": "stehlampe",
      "value": {
        "kind": "Custom",
        "value": "floor_light"
      },
      "range": {
        "start": 18,
        "end": 27
      },
      "entity": "device_Type",
      "slotName": "device"
    },
    {
      "rawValue": "an",
      "value": {
        "kind": "Custom",
        "value": "ON"
      },
      "range": {
        "start": 28,
        "end": 30
      },
      "entity": "on_off_Type",
      "slotName": "on_or_off"
    }
  ]
}
```


### Hotword manager

#### Topic: hermes/hotword/detected

Published by the hotword service locally on each satellite:

```
{
  "siteId": "default",
  "modelId": "Computer",
  "modelVersion": "1.0",
  "modeltype": "personal",
  "currentSensitivity": 0.5
}
```



### Dialogue manager

#### Topic: qnd/session/timeout

Published by the dialogue manager TIMEOUT seconds after every
dialogue manager iteration. Sessions are terminated only, if
the timeoutId is still valid:

```
{
  "timeoutId": "timeout:2c0dc569-321b-41f9-9012-2b0ac5f9fcd6",
  "timeout": 30,
  "siteId": "no_site",
  "sessionId": "session:0e24799a-aa63-4205-9808-74ee92f2436b",
  "date": "Fr 27. Dez 14:08:56 CET 2019"
}
```


#### Topic: susi/dialogueManager/stopListen

The topic is received by the dialogue manager. The 'siteId' of the payload will
be added to the list of sites for which hotwords are ignored.

```
{
    "siteId": "default"
}
```



#### Topic: susi/dialogueManager/startListen

The topic is received by the dialogue manager. The 'siteId' of the payload will
be removed from the list of sites for which hotwords are ignored and
a `TOPIC_HOTWORD_ON` is published for teh target siteId.

```
{
    "siteId": "default"
}
```

#### Topic: hermes/asr/startListening

Published by the dialogue manager to ask a satellite to start
listening (normally to a command):

```
{
  "sessionId": "session:0e24799a-aa63-4205-9808-74ee92f2436b",
  "siteId": "default",
  "id": "id:f587690c-4612-4e8e-a138-dc66f41890e2"
}
```

### Topic: qnd/asr/audioCaptured

Answer of a satellite to a topic hermes/asr/startListening request.
Sent by the NoSnips `Record` component of a satellite
to deliver a base64-encoded audio recording of a command.
All IDs match the IDs of the request:

```
{
  "sessionId": "session:0e24799a-aa63-4205-9808-74ee92f2436b",
  "siteId": "default",
  "id": "id:f587690c-4612-4e8e-a138-dc66f41890e2",
  "audio": "UG9seWZvbiB6d2l0c2NoZXJuZCBhw59lbiBNw6R4Y2hlbnMgVsO2Z2VsIF
          LDvGJlbiwgSm9naHVydCB1bmQgUXVhcms="
}
```

### Topic: qnd/asr/transsribe

```
{
  "sessionId": "session:0e24799a-aa63-4205-9808-74ee92f2436b",
  "siteId": "default",
  "id": "id:f587690c-4612-4e8e-a138-dc66f41890e3",
  "audio": "UG9seWZvbiB6d2l0c2NoZXJuZCBhw59lbiBNw6R4Y2hlbnMgVsO2Z2VsIF
          LDvGJlbiwgSm9naHVydCB1bmQgUXVhcms="
}
```

### Topic: hermes/asr/textCaptured

```
{
  "sessionId": "session:0e24799a-aa63-4205-9808-74ee92f2436b",
  "siteId": "default",
  "id": "id:f587690c-4612-4e8e-a138-dc66f41890e3",
  "text": "transcribed voice command"
}
```

### Topic: susi/play/request

Play an audio at the given siteId.
If `hotword` == "sensitive", the audio playing is stopped if a hotword is
detected at the site (useful for notifications).
`fade_in` defines the fade-in-time in sec.

```
{
  "sessionId": "session:d15eb1a0-67ba-4a3b-a378-a5b06e370719",
  "siteId": "default",
  "id": "ff64e565-8398-4ca5-9742-a4f1712153e3",
  "hotword": "ignore",
  "fade_in": "0",
  "audio": "UG9seWZvbiB6d2l0c2NoZXJuZCBhw59lbiBNw6R4Y2hlbnMgVsO2Z2VsIF
            LDvGJlbiwgSm9naHVydCB1bmQgUXVhcms="
}
```  
