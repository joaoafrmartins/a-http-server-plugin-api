{ isArray } = Array

{ camelize } = require 'inflection'

{ resolve } = require 'path'

Database = require './database'

Resource = require './resource'

module.exports = class Api

  constructor: (@server) ->

    {

      endpoint,

      authorization,

      database,

      resource,

      resources

    } = @server.config.plugins.api

    Object.defineProperty @, "endpoint", value: endpoint

    Object.defineProperty @, "resource", value: resource

    Object.defineProperty @, "database", value: new Database database

    Object.defineProperty @, "resources", value: {}

    if isArray(resources) then resources.map (dep) =>

      try

        mod = require dep

      catch err

        mod = require resolve(

          "#{process.env.PWD}", "node_modules", "#{dep}"

        )

      Object.keys(mod).map (entity) =>

        if mod[entity].enabled

          Object.defineProperty @resources, camelize(entity),

            value: new Resource @, entity, mod[entity]

    else

      Object.keys(resources).map (entity) =>

        Object.defineProperty @resources, camelize(entity),

          value: new Resource @, entity, resources[entity]
