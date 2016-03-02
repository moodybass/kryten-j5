Kryten = require './index.coffee'
kryten = new Kryten({})

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

kryten.onConfig(testOptions)

setTimeout ->
  console.log 'blink'
  kryten.onMessage({payload: {component: 'Led_Pin_13', state: '1'}})
,10000

setTimeout ->
  kryten.onMessage({payload:{component: 'Led_Pin_13', state: '0'}})
,1000
