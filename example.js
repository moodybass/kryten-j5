var Kryten, kryten, testOptions;

Kryten = require('./index.js');

var kryten = new Kryten({});

testOptions = {
  'autoDetect': true,
  'port': '',
  'interval': '500',
  'components': [
    {
      'name': 'Led_Pin_13',
      'action': 'digitalWrite',
      'pin': '13'
    }, {
      'name': 'some_sensor',
      'action': 'analogRead',
      'pin': '3'
    }, {
      'name': 'Servo1',
      'action': 'servo',
      'pin': '6'
    }
  ]
};

kryten.configure(testOptions);

kryten.on('ready', function() {
  var state;
  console.log('ready to go dog');
  kryten.on('data', function(data) {
    return console.log(data);
  });
  
  kryten.on('angular-schema-form', function(schema) {
    return console.log(schema);
  });

  state = '1';
  return setInterval(function() {
    kryten.onMessage({
      payload: {
        component: 'Led_Pin_13',
        state: state
      }
    });
    if (state === '1') {
      return state = '0';
    } else {
      return state = '1';
    }
  }, 1000);
});
