# SnipsHermesQnD

This is a "Quick-and-Dirty" implementation of an Julia-ecosystem for the
Snips.ai home assistant.

Aim is not yet a production system but testing ways to develop apps in the new and awesome programming
language Julia.

## Installation

The package builds on the mosquitto MQTT (`mosquitto_pub` and `mosquitto_sub`), which can be installed from the debian repos
(for Raspberry Pi: package `mosquitto` and `mosquitto-client`).

To install the Julia package, run

```Julia
julia> using Pkg
julia> Pkg.clone("git@github.com:andreasdominik/SnipsHermesQnD.git")
```

## Documentation

Documentation is in the source code.
Currently exported functions include:

Hermes:
* subscribeMQTT
* readOneMQTT
* publishMQTT
* subscribe2Intents
* listen2Intents
* publishEndSession
* publishContinueSession
* publishSay

App organisation:
* readConfig
* matchConfig
* getConfig
* isInConfig

other helpers:
* tryrun
* tryParseJSONfile
* tryParseJSON
* tryMkJSON

GPIO tools (pigpio must be installed)
* setGPIOtoON
* setGPIOtoOFF

## Caveat

Feel free to use the package **but:**
Use it at your own risk and be aware that the package is under development and interfaces may change.
