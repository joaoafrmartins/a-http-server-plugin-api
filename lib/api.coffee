{ isArray } = Array

{ camelize } = require 'inflection'

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

    Object.keys(resources).map (entity) =>

      Object.defineProperty @resources, camelize(entity),

        value: new Resource @, entity, resources[entity]
