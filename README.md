# OSCMotionApp

**Source code used on EDGE Sydney Biennale performance "Without a Trace" 04-2024**

https://www.innerwest.nsw.gov.au/live/living-arts/edge/edge-inner-west-2024/edge-town-hall-takeover/kenneth-craig-lambert

This repository contains a Swift app and Max MSP patches used for sound design
on this live art performance.

- - -

The application connects to WITMotion bluetooth sensors, parses their binary
messages and forwards them into Open Source Control and MIDI destinations.

It renders the sensors' attitude angles in a set of SceneKit views.

## Resources

* Thanks to https://github.com/transistorgit/WT901BLECL_Demo for an initial
  set-up example

