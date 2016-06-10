Kryten = require './index.coffee'
kryten = new Kryten({repl: false})

#BLESerialPort = require('ble-serial').SerialPort;
#Firmata = require('firmata').Board;
#kryten = new Kryten({
# io: new Firmata(new BLESerialPort({}))
#})

testOptions =
'autoDetect': true
'port': ''
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

console.log kryten
kryten.configure(testOptions)

# You can do it this way too bc its funny if you get it
#kryten.spareHead(testOptions)

kryten.on 'ready', ->
  console.log 'ready to go dog'

  kryten.on 'data', (data)->
    console.log data

  # kryten.on 'angular-schema-form', (schema)->
  #   console.log schema

  kryten.on 'config', (schema)->
    console.log schema

  state = '1'

  setInterval ->
    kryten.onMessage({payload: {component: 'Led_Pin_13', state: state}})
    if state == '1'
      state = '0'
    else
      state = '1'
  ,1000
