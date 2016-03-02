Kryten = require './index.coffee'

kryten = new Kryten.Kryten({})

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

testOptions2 =
'port': 'auto-detect'
'interval': '500'
'components': [
  {
    'name': 'Led_Pin_13'
    'action': 'digitalWrite'
    'pin': '13'
  }
  {
    'name': 'digital'
    'action': 'digitalRead'
    'pin': '4'
  }
  {
    'name': 'Servo1'
    'action': 'servo'
    'pin': '6'
  }
]

#console.log kryten


kryten.onConfig(testOptions)

setTimeout ->
  console.log 'blink'
  kryten.onMessage({payload: {component: 'Led_Pin_13', state: '1'}})
,10000

setTimeout ->
  kryten.onMessage({payload:{component: 'Led_Pin_13', state: '0'}})
,1000

setTimeout ->
  kryten.onMessage({payload:{component: 'Led_Pin_13', state: '1'}})
,1000


setTimeout ->
  kryten.onMessage({payload:{component: 'Led_Pin_13', state: '0'}})
  kryten.onConfig(testOptions2)
,20000
