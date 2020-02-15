#!/bin/bash
#
# Script to record a command; activated by
#
# (c) Andreas Dominik
#     THM University of Apllied Sciences
#     Gießen, Germany
#     Dec. 2019
#

AUDIO=$1
TIME_MAX=$2
NOISE="1.5%"
END_TRIGGER="0:01"

rec --rate 16000 $AUDIO \
    trim 0 $TIME_MAX \
    silence 1 0:00.05 $NOISE 1 $END_TRIGGER $NOISE \
    remix 1-2 \
    gain 10

sleep 0.1
