schemaModel = require './schema-model.coffee'

class SchemaGenerator

  createCondition: (items) =>
    if items != undefined
      i = 0
      while i < items.length
        if i == 0
          condition = 'model.component == \'' + items[i] + '\''
        else
          condition = condition + ' || model.component == \'' + items[i] + '\''
        i++
      return condition
    else
      return 'model.component == \'aNeverEndingSchema\''

  generateMessageSchema: (names, component) =>

    servo_ = []
    digital_ = []
    analog_ = []
    text_ = []
    continuous_ = []
    map = []

    names.forEach (name) ->
      map.push 
        'value': name
        'name': name
        'group': component[name].action

      switch component[name].action
        when 'servo'
          servo_.push name
        when 'digitalWrite'
          digital_.push name
        when 'servo-continuous'
          continuous_.push name
        when 'analogWrite'
          analog_.push name
        else
          text_.push name

    servo_condition = @createCondition(servo_)
    digital_condition = @createCondition(digital_)
    analog_condition = @createCondition(analog_)
    text_condition = @createCondition(text_)
    servoc_condition = @createCondition(continuous_)

    servo_sweep = 'model.servo_action == \'sweep\' && ' + servo_condition
    servo_to = 'model.servo_action == \'to\' && ' + servo_condition
    console.log map
    conditions = {
      map: map
      servo_condition: servo_condition
      servo_sweep: servo_sweep
      servo_to: servo_to
      digital_condition: digital_condition
      analog_condition: analog_condition
      text_condition: text_condition
      servoc_condition: servoc_condition
    }

    return schema = {
      MESSAGE_SCHEMA: schemaModel.messageSchema
      FORMSCHEMA: schemaModel.formSchema(conditions)
    }


module.exports = SchemaGenerator
