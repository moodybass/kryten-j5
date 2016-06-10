schemaModel = require './schema-model.coffee'

class SchemaGenerator

  createCondition: (items) =>
    if items[0]?
      i = 0
      while i < items.length
        if i == 0
          condition = 'model.component == \'' + items[i] + '\''
        else
          condition = condition + ' || model.component == \'' + items[i] + '\''
        i++
      return condition
    else
      condition = 'model.component == \'aNeverEndingSchema\''
      return condition

  generateMessageSchema: (names, component) =>

    servo_ = []
    digital_ = []
    analog_ = []
    text_ = []
    continuous_ = []
    esc_ = []
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
        when 'esc'
          esc_.push name
        else
          text_.push name

    servo_condition = @createCondition(servo_)
    digital_condition = @createCondition(digital_)
    analog_condition = @createCondition(analog_)
    text_condition = @createCondition(text_)
    servoc_condition = @createCondition(continuous_)
    esc_condition = @createCondition(esc_)


    servo_sweep = 'model.servo_action == \'sweep\' && ' + servo_condition
    servo_to = 'model.servo_action == \'to\' && ' + servo_condition

    conditions = {
      map: map
      servo_condition: servo_condition
      servo_sweep: servo_sweep
      servo_to: servo_to
      digital_condition: digital_condition
      analog_condition: analog_condition
      text_condition: text_condition
      servoc_condition: servoc_condition
      esc_condition: esc_condition
    }

    return schema = {
      MESSAGE_SCHEMA: schemaModel.messageSchema
      FORMSCHEMA: schemaModel.formSchema(conditions)
    }


module.exports = SchemaGenerator
