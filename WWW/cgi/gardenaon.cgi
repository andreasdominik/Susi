#!/bin/bash
#
export SUSI_INSTALLATION="/opt/Susi/Susi"
susi schalte die Bewässerung ein > /dev/null 2>&1
susi.say Bitte achte darauf dass der Wasserhahn geöffnet ist > /dev/null 2>&1
cat ok.html
