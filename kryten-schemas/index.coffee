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
    schema = schemaModel
    _.forEach components, (value, key) =>
      schema[key].properties.component.enum = value
    return schema

module.exports = KrytenSchema
