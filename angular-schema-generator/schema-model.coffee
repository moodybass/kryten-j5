
MESSAGE_SCHEMA =
  'type': 'object'
  'properties':
    'component':
      'title': 'Component'
      'type': 'string'
    'to_value':
      'title': 'Value'
      'type': 'string'
    'value':
      'title': 'Value'
      'type': 'number'
    'direction':
      'title': 'Direction'
      'type': 'string'
      'enum': [
        'CW'
        'CCW'
        'STOP'
      ]
    'text':
      'title': 'Text'
      'type': 'string'
    'state':
      'title': 'state'
      'type': 'string'
      'enum': [
        '0'
        '1'
      ]
    'servo_action':
      'type': 'string'
      'enum': [
        'to'
        'sweep'
        'stop'
      ]
    'sweep':
      'type': 'object'
      'properties':
        'min': 'type': 'number'
        'max': 'type': 'number'
    'speed':
      'type': 'number'

formSchema = (conditions) ->

  FORMSCHEMA = [
    {
      'key': 'component'
      'type': 'select'
      'titleMap': conditions.map
    }
    {
      'key': 'servo_action'
      'condition': conditions.servo_condition
    }
    {
      'key': 'sweep'
      'condition': conditions.servo_sweep
    }
    {
      'key': 'to_value'
      'condition': conditions.servo_to
    }
    {
      'key': 'state'
      'condition': conditions.digital_condition
    }
    {
      'key': 'value'
      'condition': conditions.analog_condition
    }
    {
      'key': 'text'
      'condition': conditions.text_condition
    }
    {
      'key': 'direction'
      'condition': conditions.servoc_condition
    }
    {
      'key': 'speed'
      'condition': conditions.esc_condition
    }
  ]

OPTIONS_SCHEMA =
  'type': 'object'
  'title': 'Component'
  'required': [ 'components' ]
  'properties':
    'autoDetect':
      'title': 'Auto Detect Port?'
      'type': 'boolean'
      'default': true
    'port':
      'type': 'string'
      'description': 'The serial port your board is on'
      'required': false
      'default': '/dev/ttyACM0'
    'interval':
      'type': 'string'
      'enum': [
        '500'
        '1000'
        '1500'
        '2000'
        '200'
      ]
      'description': 'The Interval in milliseconds to send Sensor readings.'
      'required': false
      'default': '500'
    'components':
      'type': 'array'
      'maxItems': 2
      'items':
        'type': 'object'
        'properties':
          'name':
            'title': 'Name'
            'type': 'string'
            'description': 'Name this component anything you like. (i.e Left_Motor). Sensor output will show up under this name in payload'
            'required': true
          'action':
            'title': 'Action'
            'type': 'string'
            'enum': [
              'digitalWrite'
              'digitalRead'
              'analogWrite'
              'analogRead'
              'servo'
              'servo-continuous'
              'PCA9685-Servo'
              'oled-i2c'
              'LCD-PCF8574A'
              'LCD-JHD1313M1'
              'MPU6050'
              'esc'
            ]
            'required': true
          'pin':
            'title': 'Pin'
            'type': 'string'
            'description': 'Pin used for this component'
            'required': false
          'address':
            'title': 'address'
            'type': 'string'
            'description': 'i2c address used for this component'
            'required': false
        'required': [
          'name'
          'action'
        ]
OPTIONS_FORM = [
  'port'
  'interval'
  {
    'key': 'components'
    'add': 'New'
    'style': 'add': 'btn-success'
    'items': [
      'components[].name'
      'components[].action'
      {
        'key': 'components[].pin'
        'condition': 'model.components[arrayIndex].action==\'digitalRead\' || model.components[arrayIndex].action==\'digitalWrite\' || model.components[arrayIndex].action==\'analogRead\' || model.components[arrayIndex].action==\'analogWrite\' || model.components[arrayIndex].action==\'servo\' || model.components[arrayIndex].action==\'esc\''
      }
      {
        'key': 'components[].address'
        'condition': 'model.components[arrayIndex].action==\'oled-i2c\' || model.components[arrayIndex].action==\'LCD-PCF8574A\' || model.components[arrayIndex].action==\'LCD-JHD1313M1\' || model.components[arrayIndex].action==\'PCA9685-Servo\''
      }
    ]
  }
  {
    'type': 'submit'
    'style': 'btn-info'
    'title': 'OK'
  }
]

module.exports = {
  messageSchema: MESSAGE_SCHEMA
  formSchema: formSchema
  optionsForm: OPTIONS_FORM
  optionsSchema: OPTIONS_SCHEMA
}
