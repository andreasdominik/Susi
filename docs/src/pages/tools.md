# Tools

### susi
`susi` is a commandline tool to simulate voice interaction with Susi.
The command
```
$ susi please switch on the light
```
will be passed to the session manager to start a new session of type
'command'. The text is injected in the session manager pipeline exactly
the same way as a transcribed voice command.
This way it's possible to simulate a voice command.



### susi.start
The tool starts all daemons. `susi.start` is executed by the service
to start Susi.


### susi.stop
The tool stops all daemons, skills and susi-related tools.
`susi.start` is executed by the service to stop Susi.


### susi.say
Commandline tool to call the text-to-speech daemon.
The command
```
$ susi.say hello I am Susi, your assistant
```
will generate an audio file with the sentence and the voice
configured. The play daemon will the used to play the file
at site 'default'.

If caching is switched on, the audio will be added to the cache.

### susi.watch
Tool to monitor the session managers activity and the traffic on Susi's
MQTT broker.
