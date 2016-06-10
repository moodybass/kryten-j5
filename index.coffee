_            = require 'lodash'
five         = require 'johnny-five'
Oled         = require 'oled-js'
font         = require 'oled-font-5x7'
debug        = require('debug')('kryten')
util         = require 'util'
EventEmitter = require('events').EventEmitter

SchemaGenerator = require './angular-schema-generator/index.coffee'
SchemaGenerator = new SchemaGenerator

KrytenSchema = require './kryten-schemas/index.coffee'
KrytenSchema = new KrytenSchema

class Kryten

  constructor: (io={}) ->
    EventEmitter.call @

    @options = {interval: 1000}
    @io = io
    @board = {}
    prevData = {}
    @boardReady = false
    @started = false

    @clearBoard()
    @Read()

  util.inherits(@, EventEmitter)

  StartBoard: (device) =>
    @started = true

    if !@boardReady
      if !device.autoDetect
        if !@io.io?
          @board = new five.Board({port: device.port, repl: false})
        else
          @board = new five.Board(@io)
      else
        @board = new five.Board(@io)

      @board.on 'ready', =>
        debug 'ready dude'
        @emit 'ready'
        @boardReady = true
        @configBoard(device)

  onMessage: (message) =>
    payload = message.payload
    payload.name = payload.component

    if !@bot.component[payload.name]
      return

    debug(@bot.component[payload.name])
    switch @bot.component[payload.name].action
      when 'digitalWrite'
        value = parseInt(payload.state)
        @board.digitalWrite(@bot.component[payload.name].pin, value)
      when "analogWrite"
        value = payload.value
        debug("analog STUFF", value)
        debug("pinsssc", @bot.component[payload.name].pin)
        @board.analogWrite(parseInt(@bot.component[payload.name].pin), value)
      when "servo"
        debug('servo', payload.name)
        if payload.servo_action == "to"
          value = payload.to_value
          @bot.servo[payload.name].stop()
          @bot.servo[payload.name].to(value)
        else if payload.servo_action == "sweep"
          @bot.servo[payload.name].sweep([payload.sweep.min, payload.sweep.max])
        else if payload.servo_action == "stop"
          @bot.servo[payload.name].stop()
      when "PCA9685-Servo"
        if payload.servo_action == "to"
          value = payload.to_value
          @bot.servo[payload.name].stop()
          @bot.servo[payload.name].to(value)
        else if payload.servo_action == "sweep"
          @bot.servo.sweep([payload.sweep.min, payload.sweep.max])
        else if payload.servo_action == "stop"
          @bot.servo[payload.name].stop()
      when "oled-i2c"
        @bot.oled[payload.name].turnOnDisplay()
        @bot.oled[payload.name].clearDisplay()
        @bot.oled[payload.name].update()
        @bot.oled[payload.name].setCursor(1, 1)
        @bot.oled[payload.name].writeString(font, 3, payload.text , 1, true)
      when "LCD-PCF8574A"
        @bot.lcd[payload.name].clear()
        if payload.text.length <= 16
          @bot.lcd[payload.name].cursor(0,0).noAutoscroll().print(payload.text)
        else if payload.text.length > 16
          @bot.lcd[payload.name].cursor(0,0).print(payload.text.substring(0,16))
          @bot.lcd[payload.name].cursor(1,0).print(payload.text.substring(16,33))
      when "LCD-JHD1313M1"
        @bot.lcd[payload.name].clear()
        if payload.text.length <= 16
          @bot.lcd[payload.name].cursor(0,0).noAutoscroll().print(payload.text)
        else if payload.text.length > 16
          @bot.lcd[payload.name].cursor(0,0).print(payload.text.substring(0,16))
          @bot.lcd[payload.name].cursor(1,0).print(payload.text.substring(16,33))
      when "esc"
        @bot.esc[payload.name].speed(payload.speed)

  checkConfig: (data) =>
    if @boardReady
      return if _.isEqual(data, prevData)
      if _.has(data, "components")
        @configBoard(data)
      else if !_.has(data, "components")
        debug 'No components'
        return
      prevData = data

  configBoard: (data) =>
    @device = data
    debug 'board is', @boardReady
    if @boardReady
      @clearBoard()

      components = @device.components
      debug components
      debug(components)
      @createComponents(components)

    else
      setTimeout ->
        @configBoard(@device)
        debug 'config'
      ,1000

  createComponents: (comp) =>

    _.forEach comp, (part) =>
      debug(part)
      debug @bot

      return if !_.has(part, "pin") && !_.has(part, "address")

      if _.has(part, "pin")
        @bot.component[part.name] = {
          pin: part.pin
          action: part.action
        }

      if _.has(part, "address")
        @bot.component[part.name] = {
          address: part.address,
          action: part.action
        }

      debug(@bot.component)
      switch (part.action)
        when 'digitalRead'
          debug("digitalRead")
          @board.pinMode(part.pin, five.Pin.INPUT)
          @board.digitalRead part.pin, (value) =>
            if _.has(@bot.component, part.name)
              @bot.read[part.name] = value
        when 'digitalWrite'
          @board.pinMode(part.pin, @board.MODES.OUTPUT)
          @bot.names.push(part.name)
        when 'analogRead'
          @board.pinMode(part.pin, five.Pin.ANALOG)
          @board.analogRead part.pin, (value) =>
            if _.has(@bot.component, part.name)
              @bot.read[part.name] = value
        when 'analogWrite'
          @board.pinMode(parseInt(part.pin), five.Pin.PWM)
          @bot.names.push(part.name)
        when 'servo'
          @bot.servo[part.name] = new five.Servo({pin: parseInt(part.pin)})
          @bot.names.push(part.name)
        when 'servo-continuous'
          @bot.servo[part.name] = new five.Servo.Continuous(parseInt(part.pin)).stop()
          @bot.names.push(part.name)
        when 'PCA9685-Servo'
          address = parseInt(part.address) || 0x40
          @bot.servo[part.name] = new five.Servo({
            address: address,
            controller: "PCA9685",
            pin: part.pin
          })
          @bot.names.push(part.name)
        when 'oled-i2c'
          debug("oled initiated")
          address = parseInt(part.address) || 0x3C
          opts = {
            width: 128
            height: 64
            address: address
          }
          @bot.oled[part.name] = new Oled(@board, five, opts)
          @bot.oled[part.name].clearDisplay()
          @bot.oled[part.name].setCursor(1, 1)
          @bot.oled[part.name].writeString(font, 3, 'Skynet Lives', 1, true)
          @bot.oled[part.name].update()
          @bot.names.push(part.name)
        when 'LCD-PCF8574A'
            @bot.lcd[part.name] = new five.LCD({
              controller: "PCF8574A",
              rows: 2,
              cols: 16
            })
            @bot.lcd[part.name].cursor(0, 0).print("Skynet Lives")
            @bot.names.push(part.name)
        when 'LCD-JHD1313M1'
            @bot.lcd[part.name] = new five.LCD({
              controller: "JHD1313M1",
              rows: 2,
              cols: 16
            })
            @bot.lcd[part.name].cursor(0, 0).print("Skynet Lives")
            @bot.names.push(part.name)
        when 'MPU6050'
          addr = parseInt(part.address) || 0x68
          @bot.accel[part.name] = new five.IMU({
            controller: "MPU6050",
            address: addr
          })
          @bot.accel[part.name].on "data", (err, data) =>
            values = {}
            values["accel"] = {"x": this.accelerometer.x , "y": this.accelerometer.y, "z": this.accelerometer.z}
            values["gyro"] = {"x": this.gyro.x , "y": this.gyro.y, "z": this.gyro.z}
            values["temp"] = {"temperature" : this.temperature.celsius}
            @bot.read[part.name] = values
        when 'esc'
          @bot.esc[part.name] = new five.ESC({
            device: "FORWARD_REVERSE",
            neutral: 50,
            pin: part.pin
          })
          @bot.names.push(part.name)
        else null

      schema = SchemaGenerator.generateMessageSchema(@bot.names, @bot.component)
      krytenSchema = KrytenSchema.generateMessageSchema(@bot.names, @bot.component)
      @emit 'angular-schema-form', schema
      @emit 'schema', schema
      @emit 'config', krytenSchema
      debug schema

  clearBoard: () =>
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
    debug @bot

  spareHead: (device={}) =>
    @configure(device)

  configure: (device={}) =>
    return unless device?
    @options = device
    @StartBoard(device) if !@started
    @checkConfig(device)

  Read: =>
    debug("interval is:", @options.interval)
    setInterval =>
      return unless @bot.read?
      debug @bot.read
      @emit 'data', @bot.read
    , @options.interval

module.exports = Kryten
