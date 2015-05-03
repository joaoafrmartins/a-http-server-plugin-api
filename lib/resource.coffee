{ isArray } = Array

module.exports = class Resource

  constructor: (@api, @entity, @defines) ->

    Object.defineProperty @, "model", value: @api.model.apply @api, [

      @entity, @defines.schema, {

        primaryKeys: @defines?.primaryKeys

        indexes: @defines?.indexes

      }

    ]

    if @defines.validation then @modelValidation @defines.validation

    if @defines.hooks then @modelHooks @defines.hooks

    process.on 'a-http-server:started', () =>

      if @defines.relationships then @modelRelationships(

        @defines.relationships

      )

  modelValidation: (validation) ->

    Object.keys(validation).map (fn) =>

      definition = validation[fn]

      if isArray definition then return @model[fn].apply @, definition

      if typeof definition is "object"

        Object.keys(definition).map (field) =>

          @model[fn].apply @, [ field, definition[field] ]

  modelHooks: (hooks) ->

    Object.keys(hooks).map (fn) => @model[hook] = hooks[fn]

  modelRelationships: (relationships) ->

    Object.keys(relationships).map (fn) =>

      defines = relationships[fn]

      Object.keys(defines).map (entity) =>

        model = @api.model entity

        @model[fn] entity, defines[entity]
