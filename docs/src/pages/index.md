# Susi

Susi (SUsi is not SnIps) is a replacement for the Snips
home assistant ecosystem. It follows mainly the same architecture as
Snips (with a MQTT broker as central unit and MQTT messages exchanged
between the components).
Consequently most native Snips skills will run with Susi as well but without
the need of the (no longer available Snips console).

Susi is build as a modular system as a collection of
of daemons (hotword detection, record, speech to text,
intent recognion, play, skill managment).
Most daemons are lightweight bash scripts responsible for communication with
other daeomns via MQTT messages. The actual workers for the respective functionality
can be configured separately and hence can be replaced easily.
