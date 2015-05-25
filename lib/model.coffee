{ EOL } = require 'os'

{ isArray } = Array

{ camelize } = require 'inflection'

module.exports = class Model

  constructor: (@connection, definition) ->

    {

      entity,

      schema,

      primaryKeys,

      indexes,

      validation,

      hooks,

      relationships

    } = definition

    Object.keys(schema).map (field) =>

      type = schema[field].type

      schema[field].type = @connection[type]

    Object.defineProperty @, "model", value: @connection.define(

      @modelName(entity), schema, {

        primaryKeys: primaryKeys or []

        indexes: indexes or {}

      }

    )

    if validation then @validation validation

    if hooks then @hooks hooks

    process.on 'a-http-server:started', () =>

      if relationships then @relationships relationships

      process.emit 'a-http-server:api:model:relationships', entity

    return @model

  modelName: (str) ->

    camelize(str.replace("-","_"), true)

  validation: (validation) ->

    functions = []

    Object.keys(validation).map (fn) =>

      definition = validation[fn]

      if isArray definition then return @model[fn].apply @, definition

      if typeof definition is "object"

        Object.keys(definition).map (field) =>

          @model[fn].apply @, [ field, definition[field] ]

  hooks: (hooks) ->

    Object.keys(hooks).map (fn) => @model[hook] = hooks[fn]

  relationships: (relationships) ->

    Object.keys(relationships).map (fn) =>

      defines = relationships[fn]

      Object.keys(defines).map (entity) =>

        try

          @model[fn](

            @connection.models[@modelName(entity)], defines[entity]

          )

        catch err

          throw new Error """loading #{entity} resource model

          #{err.message}

          """
