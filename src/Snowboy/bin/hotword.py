#!/usr/bin/python
#
import snowboydecoder
import sys
import signal

interrupted = False


def signal_handler(signal, frame):
    global interrupted
    interrupted = True


def interrupt_callback():
    global interrupted
    return interrupted

if len(sys.argv) < 3:
    print("Error: need to specify model name and sensitivity")
    print("Usage: python hotword.py your.path/your.model 0.5")
    sys.exit(-1)

model = sys.argv[1]
sensi = sys.argv[2]

# capture SIGINT signal, e.g., Ctrl+C
signal.signal(signal.SIGINT, signal_handler)

detector = snowboydecoder.HotwordDetector(model, sensitivity=sensi)

# main loop
# reason = detector.start(detected_callback=snowboydecoder.play_audio_file,
#                interrupt_check=interrupt_callback,
#                sleep_time=0.03)
reason = detector.start(detected_callback=snowboydecoder.print_detected,
               interrupt_check=interrupt_callback,
               sleep_time=0.03)

detector.terminate()

if reason == "hotword":
    sys.exit(0)
else:
    sys.exit(1)
