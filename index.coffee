_            = require 'lodash'
five         = require 'johnny-five'
Oled         = require 'oled-js'
font         = require 'oled-font-5x7'
debug        = require('debug')('kryten')
util         = require 'util'
EventEmitter = require('events').EventEmitter
SchemaGenerator = require './schema-generator.coffee'
SchemaGenerator = new SchemaGenerator

class Kryten

  constructor: (io={}) ->

    EventEmitter.call @

    @testOptions =
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

    @schema = {}

    @options = {}

    @io = io
    @board = {}
    @bot = {
      names: []
      component: {}
      read: {}
      servo: []
      oled: []
      lcd: []
      accel: []
      map: []
      esc: []
    }

    prevData = {}

    @boardReady = false
    @started = false

    debug @bot

  util.inherits(@, EventEmitter)

  StartBoard: (device) =>
    self = @
    @started = true

    if !@boardReady
      if device.port != "auto-detect"
        @board = new five.Board(@io)
      else
        @board = new five.Board()

      @board.on 'ready', ->
        debug 'ready dude'
        self.emit 'ready'
        self.boardReady = true
        self.configBoard(device)
        self.Read()

  onMessage: (message) =>
    self = @
    payload = message.payload
    payload.name = payload.component

    if !self.bot.component[payload.name]
      return

    debug(self.bot.component[payload.name])
    switch self.bot.component[payload.name].action
      when 'digitalWrite'
        value = parseInt(payload.state)
        self.board.digitalWrite(self.bot.component[payload.name].pin, value)
      when "analogWrite"
        value = payload.value
        debug("analog STUFF", value)
        debug("pinsssc", self.bot.component[payload.name].pin)
        self.board.analogWrite(parseInt(self.bot.component[payload.name].pin), value)
      when "servo"
        debug('servo', servo)
        if payload.servo_action == "to"
          value = payload.to_value
          self.bot.servo[payload.name].stop()
          self.bot.servo[payload.name].to(value)
        else if payload.servo_action == "sweep"
          self.bot.servo.sweep([payload.sweep.min, payload.sweep.max])
        else if payload.servo_action == "stop"
          self.bot.servo[payload.name].stop()
      when "PCA9685-Servo"
        if payload.servo_action == "to"
          value = payload.to_value
          self.bot.servo[payload.name].stop()
          self.bot.servo[payload.name].to(value)
        else if payload.servo_action == "sweep"
          self.bot.servo.sweep([payload.sweep.min, payload.sweep.max])
        else if payload.servo_action == "stop"
          self.bot.servo[payload.name].stop()
      when "oled-i2c"
        self.bot.oled[payload.name].turnOnDisplay()
        self.bot.oled[payload.name].clearDisplay()
        self.bot.oled[payload.name].update()
        self.bot.oled[payload.name].setCursor(1, 1)
        self.bot.oled[payload.name].writeString(font, 3, payload.text , 1, true)
      when "LCD-PCF8574A"
        self.bot.lcd[payload.name].clear()
        if payload.text.length <= 16
          self.bot.lcd[payload.name].cursor(0,0).noAutoscroll().print(payload.text)
        else if payload.text.length > 16
          self.bot.lcd[payload.name].cursor(0,0).print(payload.text.substring(0,16))
          self.bot.lcd[payload.name].cursor(1,0).print(payload.text.substring(16,33))
      when "LCD-JHD1313M1"
        self.bot.lcd[payload.name].clear()
        if payload.text.length <= 16
          self.bot.lcd[payload.name].cursor(0,0).noAutoscroll().print(payload.text)
        else if payload.text.length > 16
          self.bot.lcd[payload.name].cursor(0,0).print(payload.text.substring(0,16))
          self.bot.lcd[payload.name].cursor(1,0).print(payload.text.substring(16,33))
      when "esc"
        self.bot.esc[payload.name].speed(part.speed)

  checkConfig: (data) =>
    if @boardReady
      return if _.isEqual(data, prevData)
      if _.has(data, "components")
        @configBoard(data)
      else if !_.has(data, "components")
        #@emit('update', {options: @testOptions})
        data = @testOptions
        @configBoard(data)

      prevData = data
    else
      #this.emit('config')

  configBoard: (data) =>
    self = @
    @device = data
    debug 'board is', @boardReady
    if @boardReady
      @bot = {
        names: []
        component: {}
        read: {}
        servo: []
        oled: []
        lcd: []
        accel: []
        map: []
        esc: []
      }

      components = @device.components
      debug components
      debug(components)
      self.createComponents(components)

    else
      setTimeout ->
        #self.emit('config')
        self.configBoard(@device)
        debug 'config'
      ,1000

  createComponents: (comp) =>
    self = @
    _.forEach comp, (part) ->
      debug(part)
      debug self.bot

      return if !_.has(part, "pin") && !_.has(part, "address")

      if _.has(part, "pin")
        self.bot.component[part.name] = {
          pin: part.pin
          action: part.action
        }

      if _.has(part, "address")
        self.bot.component[part.name] = {
          address: part.address,
          action: part.action
        }

      debug(self.bot.component)
      switch (part.action)
        when 'digitalRead'
          debug("digitalRead")
          self.board.pinMode(part.pin, five.Pin.INPUT)
          self.board.digitalRead part.pin, (value) ->
            if _.has(self.bot.component, part.name)
              self.bot.read[part.name] = value
        when 'digitalWrite'
          self.board.pinMode(part.pin, self.board.MODES.OUTPUT)
          self.bot.names.push(part.name)
        when 'analogRead'
          self.board.pinMode(part.pin, five.Pin.ANALOG)
          self.board.analogRead part.pin, (value) ->
            if _.has(self.bot.component, part.name)
              self.bot.read[part.name] = value
        when 'analogWrite'
          self.board.pinMode(parseInt(part.pin), five.Pin.PWM)
          self.bot.names.push(part.name)
        when 'servo'
          self.bot.servo[part.name] = new five.Servo({pin: parseInt(part.pin)})
          self.bot.names.push(part.name)
        when 'servo-continuous'
          self.bot.servo[part.name] = new five.Servo.Continuous(parseInt(part.pin)).stop()
          self.bot.names.push(part.name)
        when 'PCA9685-Servo'
          address = parseInt(part.address) || 0x40
          self.bot.servo[part.name] = new five.Servo({
            address: address,
            controller: "PCA9685",
            pin: part.pin
          })
          self.bot.names.push(part.name)
        when 'oled-i2c'
          debug("oled initiated")
          address = parseInt(part.address) || 0x3C
          opts = {
            width: 128
            height: 64
            address: address
          }
          self.bot.oled[part.name] = new Oled(self.board, five, opts)
          self.bot.oled[part.name].clearDisplay()
          self.bot.oled[part.name].setCursor(1, 1)
          self.bot.oled[part.name].writeString(font, 3, 'Skynet Lives', 1, true)
          self.bot.oled[part.name].update()
          self.bot.names.push(part.name)
        when 'LCD-PCF8574A'
            self.bot.lcd[part.name] = new five.LCD({
              controller: "PCF8574A",
              rows: 2,
              cols: 16
            })
            self.bot.lcd[part.name].cursor(0, 0).print("Skynet Lives")
            self.bot.names.push(part.name)
        when 'LCD-JHD1313M1'
            self.bot.lcd[part.name] = new five.LCD({
              controller: "JHD1313M1",
              rows: 2,
              cols: 16
            })
            self.bot.lcd[part.name].cursor(0, 0).print("Skynet Lives")
            self.bot.names.push(part.name)
        when 'MPU6050'
          addr = parseInt(part.address) || 0x68
          self.bot.accel[part.name] = new five.IMU({
            controller: "MPU6050",
            address: addr
          })
          self.bot.accel[part.name].on "data", (err, data) ->
            values = {}
            values["accel"] = {"x": this.accelerometer.x , "y": this.accelerometer.y, "z": this.accelerometer.z}
            values["gyro"] = {"x": this.gyro.x , "y": this.gyro.y, "z": this.gyro.z}
            values["temp"] = {"temperature" : this.temperature.celsius}
            self.bot.read[part.name] = values
        when 'esc'
          self.bot.esc[part.name] = new five.ESC({
            device: "FORWARD_REVERSE",
            neutral: 50,
            pin: part.pin
          })
        else null

      schema = SchemaGenerator.generateMessageSchema(self.bot.names, self.bot.component)
      self.emit 'schema', schema
      debug schema


  configure: (device = @testOptions) =>
    self = @
    self.options = device
    self.StartBoard(device) if !self.started
    self.checkConfig(device)

  Read: ->
    self = @
    interval = parseInt(self.options.interval) || 1000
    debug("interval is:", interval)

    setInterval ->
      debug self.bot.read
      if !(_.isEmpty(self.bot.read))
        debug self.bot.read
        self.emit 'data', self.bot.read
    , interval

module.exports = Kryten
