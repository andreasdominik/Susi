#!/bin/bash -xv
#
# open all deamons in separate terminal tabs
#
#

gnome-terminal --tab -t "Session Manager" --working-directory=/tmp -- $SUSI_INSTALLATION/src/Session/session.daemon
gnome-terminal --tab -t "Hotword" --working-directory=/tmp -- $SUSI_INSTALLATION/src/Hotword/hotword.daemon
gnome-terminal --tab -t "NLU" --working-directory=/tmp -- $SUSI_INSTALLATION/src/NLU/nlu.daemon.jl
gnome-terminal --tab -t "Duckling" --working-directory=/tmp -- $SUSI_INSTALLATION/src/Duckling/duckling.daemon
gnome-terminal --tab -t "Play" --working-directory=/tmp -- $SUSI_INSTALLATION/src/Play/play.daemon
gnome-terminal --tab -t "Record" --working-directory=/tmp -- $SUSI_INSTALLATION/src/Record/record.daemon
gnome-terminal --tab -t "STT" --working-directory=/tmp -- $SUSI_INSTALLATION/src/SpeechToText/stt.daemon
gnome-terminal --tab -t "TTS" --working-directory=/tmp -- $SUSI_INSTALLATION/src/TextToSpeech/tts.daemon
gnome-terminal --tab -t "Skills" --working-directory=/tmp -- $SUSI_INSTALLATION/src/Skills/skills.daemon
