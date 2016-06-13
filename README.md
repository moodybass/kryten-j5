# kryten

A wrapper for johnny-five that lets you define/re-configure a board using JSON and then generates schemaform.io schema for controlling it.

This makes Kryten ideal for IoT. Just pick the messaging/m2m platform of your liking and use JSON to configure and control your board remotely without having to write out an interface.

Kryten is used for various hardware connectors for [Octoblu](https://octoblu.com)

You can change what io it uses easily - see uncommented lines in example below.

CoffeeScript Example
```coffee
Kryten = require './index.coffee'
kryten = new Kryten({})

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

kryten.configure(testOptions)

# You can do it this way too bc its funny if you get it
#kryten.spareHead(testOptions)

kryten.on 'ready', ->
  console.log 'ready to go dog'

  kryten.on 'data', (data)->
    console.log data

  kryten.on 'angular-schema-form', (schema)->
    console.log schema

  state = '1'

  setInterval ->
    kryten.onMessage({component: 'Led_Pin_13', state: state})
    if state == '1'
      state = '0'
    else
      state = '1'
  ,1000

```

### Configure

Essentially you create an array of components to send to the board defining a name, action, and pin or address.

#### Available Components
```
'digitalWrite'
'digitalRead'
'analogWrite'
'analogRead'
'servo'
'PCA9685-Servo'
'oled-i2c'
'LCD-PCF8574A'
'LCD-JHD1313M1c'
'MPU6050'
'esc'
```

#### Set components
```coffee
testOptions =
'port': 'auto-detect' #Can be used to specify port
'interval': '500' # Interval at which to send sensor readings
'components': [
  {
    'name': 'Led_Pin_13'
    'action': 'digitalWrite'
    'pin': '13'
  },
  {
    'name': 'Text Display'
    'action': 'oled-i2c'
    'address': '0x3C'
  }
]
```

#### Configure Board
```coffee
kryten.configure(testOptions)
```

#### Generated Schema

##### schemaform.io Message Schema and Formschema

```coffee
kryten.on 'angular-schema-form', (schema)->
  console.log schema
```

##### Schema collection

```coffee
kryten.on 'config', (schema)->
  console.log schema
```

Returns collection of schemas for components that were created.
So if you configured just one digitalWrite component you would get back this.

```json
{
  "digitalWrite": {
    "title": "Digital Write",
    "type": "object",
    "properties": {
      "component": {
        "title": "Component Name",
        "type": "string",
        "enum": ["Some Component you named"]
      },
      "state": {
        "type": "string",
        "enum": [
          "1",
          "0"
        ]
      }
    }
  },
}
```

### Send Command/payload
For components that take input like digitalWrite, analogWrite, et cetera.

```coffee
kryten.onMessage({
  payload:
    {
      component: 'Led_Pin_13',
      state: '1'
    }
  })
```

### Message Structure

#### digitalWrite
```json
{ "payload":
  { "component": "Led_Pin_13",
    "state": "1" | "0"
    }
  }
```

#### analogWrite
```json
{ "payload":
  { "component": "Some Analog Thing",
    "value": 0 - 255
    }
  }
```

#### Servo

to
```json
{ "payload":
  { "component": "Servo 1",
    "servo_action": "to",
    "to_value": 0 - 180
    }
  }
```

sweep
```json
{ "payload":
  { "component": "Led_Pin_13",
    "servo_action": "sweep",
    "sweep": {
      "min": 0 - 180,
      "max": 0 - 180
    }
   }
  }
```

stop
```json
{ "payload":
  { "component": "Servo 1",
    "servo_action": "stop"
    }
  }
```

#### Servo Continuous
```json
{ "payload":
  { "component": "Servo Name",
    "direction": "CW, CCW, STOP"
    }
  }
```


#### OLED/LCD
```json
{ "payload":
  { "component": "Some display",
    "text": "Some text to display"
    }
  }
```

#### ESC
```json
{ "payload":
  { "component": "The Esc",
    "speed": 0 - 255
    }
  }
```




![Kryten](http://s30.postimg.org/7o69ldgs1/tumblr_m61bkqd_ZF61rvt47eo1_500.jpg)


Kryten says don't be a smeg head! Always give credit where credit is due! Open source is awesome, this library is awesome because of awesome people who worked on johnny-five, I just wrapped that awesomeness in bacon.
