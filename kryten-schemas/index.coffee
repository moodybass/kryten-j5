schemaModel = require './message-schemas.json'
_ = require 'lodash'

class KrytenSchema

  componentList: (names, component) =>
    components = {}
    names.forEach (name) ->
      components[component[name].action] = [] if !components[component.action]?
      components[component[name].action].push name
    return components

  generateMessageSchema: (names, component) =>
    components = @componentList names, component
    schema = {}
    _.forEach components, (value, key) =>
      return unless value?
      schema[key] = schemaModel[key] if !schema[key]?
      schema[key].properties.component.enum = value
    return schema

module.exports = KrytenSchema
