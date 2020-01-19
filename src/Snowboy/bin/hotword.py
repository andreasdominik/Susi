#!/usr/bin/python
#
# usage: hotword.py model senistivity trigger_file
import snowboydecoder
import sys
import signal
import os.path
from os import path

interrupted = False


def signal_handler(signal, frame):
    global interrupted
    interrupted = True


def interrupt_callback():
    global interrupted
    return interrupted

if len(sys.argv) < 4:
    print("Error: need to specify model name and sensitivity")
    print("Usage: python hotword.py your.path/your.model 0.5 trigger.off")
    sys.exit(-1)

model = sys.argv[1]
sensi = sys.argv[2]
offTrigger = sys.argv[3]

# capture SIGINT signal, e.g., Ctrl+C
signal.signal(signal.SIGINT, signal_handler)

detector = snowboydecoder.HotwordDetector(model, sensitivity=sensi)

# main loop
# reason = detector.start(detected_callback=snowboydecoder.play_audio_file,
#                interrupt_check=interrupt_callback,
#                sleep_time=0.03)
while True:
    reason = detector.start(detected_callback=snowboydecoder.print_detected,
               interrupt_check=interrupt_callback,
               sleep_time=0.03)

    detector.terminate()

    if not path.exists(offTrigger)
        if reason == "hotword":
            sys.exit(0)
        else:
            sys.exit(1)
