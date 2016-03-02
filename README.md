# kryten

A wrapper for johnny-five that lets you define/re-configure a board using JSON and then generates schemaform.io schema for controlling it.

You can change what io it uses easily - see uncommented lines in example below.

```coffee
Kryten = require 'kryten'
kryten = new Kryten({})

# BLESerialPort = require('ble-serial').SerialPort;
# Firmata = require('firmata').Board;
# kryten = new Kryten({
#   io: new Firmata(new BLESerialPort({}))
# })

testOptions =
'port': 'auto-detect'
'interval': '500'
'components': [
  {
    'name': 'Led_Pin_13'
    'action': 'digitalWrite'
    'pin': '13'
  }
  {
    'name': 'some_sensor'
    'action': 'analogRead'
    'pin': '3'
  }
  {
    'name': 'Servo1'
    'action': 'servo'
    'pin': '6'
  }
]

kryten.configure(testOptions)

kryten.on 'ready', ->
  console.log 'ready to go dog'

  kryten.on 'data', (data)->
    console.log data

  kryten.on 'schema', (schema)->
    console.log schema

  state = '1'

  setInterval ->
    kryten.onMessage({payload: {component: 'Led_Pin_13', state: state}})
    if state == '1'
      state = '0'
    else
      state = '1'
  ,1000

```
