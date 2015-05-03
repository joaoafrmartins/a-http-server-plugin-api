Resource = require './resource'

{ Schema } = require 'caminte'

module.exports = class Api

  constructor: (@server) ->

    { adapter, options } = @server.config.plugins.api.database

    Object.defineProperty @, "schema", value: new Schema adapter, options

    Object.defineProperty @, "resources", value: {}

  resource: (entity, definition) ->

    if @resources?[entity] then return @resources[entity]

    Object.defineProperty @resources, entity, value: new Resource(

      @, entity, definition

    )

    @resources[entity]

  model: (args...) ->

    name = args[0]

    if @schema?.models?[name] then return @schema.models[name]

    @schema.define.apply @schema, args

    @schema.models[name]
