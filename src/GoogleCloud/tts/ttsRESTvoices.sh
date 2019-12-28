#!/bin/bash -xv
#
# retrieve a list of voices from GoogleTTS
#
curl -H "Authorization: Bearer "$(gcloud auth application-default print-access-token) \
    -H "Content-Type: application/json; charset=utf-8" \
    "https://texttospeech.googleapis.com/v1/voices"
