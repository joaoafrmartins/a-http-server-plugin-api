Model = require './model'

clone = require 'lodash.clone'

{ camelize } = require 'inflection'

module.exports = class Resource

  constructor: (@api, @entity, @definition) ->

    @defineModel()

    @defineDefaultRoutes()

    process.on 'a-http-server:api:model:relationships', (entity) =>

      if entity is @entity then @defineRelationshipRoutes()

    @api.resources[@entity] = @

  scopes: (requiredScopes) ->

    { requestProperty } = @config.authorization

    availableScopes = Object.keys(scopes or {})

    requiredScopes.map (scope) =>

      if not ( scope in availableScopes )

        throw @error.UnauthorizedError

    (req, res, next) =>

      token = req[requestProperty]

      token?.scopes?.map (scope) ->

        if scope in requiredScopes then return next()

      throw @error.UnauthorizedError

  defineModel: ->

    definition = @definition.database.model

    definition.entity = @entity

    Object.defineProperty @, "model", value: new Model(

      @api.database, definition

    )

  defineDefaultRoutes: ->

    blacklist = []

    @definition.resource.routes.map (route) =>

      blacklist.push route.path

      route.model = @model

      route.methods ?= @api.resource.methods

      route.scopes ?= @definition.resource.scopes or @api.resource.scopes

    @api.resource.routes.map (r) =>

      if not ( r.path in blacklist )

        route = clone r

        route.methods ?= @api.resource.methods

        if @definition.resource.scopes

          route.scopes = @definition.resource.scopes

        else

          route.scopes = @api.resource.scopes

        if @definition.resource.methods

          route.methods = @definition.resource.methods

        else

          route.methods = @api.resource.methods

        route.model = @model

        @definition.resource.routes.push route

    @definition.resource.routes.map (route) =>

      route.path = "/#{@entity}#{route.path}".replace(/\/$/, '')

    if not @definition.resource.nested

      @defineRouter(

        @api.server.app,

        @definition.resource.routes

      )

  defineRelationshipRoutes: ->

    routes = @definition.resource.routes

    relationships = @definition.database.model.relationships

    Object.keys(relationships.hasMany or {}).map (entity) =>

      relatedResource = @api.resources[entity].definition.resource

      if relatedResource.nested

        relatedResourceRoutes = []

        relatedModel = @api.resources[entity].model

        relatedResource.routes.map (_route) =>

          route = clone _route

          route.path = "/#{@entity}/:id#{route.path}".replace(/\/$/, '')

          route.model = relatedModel

          routes.push route

          relatedResourceRoutes.push route

        @defineRouter(

          @api.server.app,

          relatedResourceRoutes

        )

  defineRouter: (app, routes) ->

    routes.map (route) =>

      route.methods.map (method) =>

        route.path = "#{@api.endpoint}#{route.path}"

        app[method] route.path, @[method].bind(

          model: route.model,

          server: @api.server

        )

  get: (req, res) ->

    console.log @model

    console.log @server.config

    res.sendStatus 200

  post: (req, res) ->

    console.log @model

    console.log @server.config

    res.sendStatus 200

  put: (req, res) ->

    console.log @model

    console.log @server.config

    res.sendStatus 200

  delete: (req, res) ->

    console.log @model

    console.log @server.config

    res.sendStatus 200
