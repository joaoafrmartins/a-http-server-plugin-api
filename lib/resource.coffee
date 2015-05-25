Model = require './model'

clone = require 'lodash.clone'

{ camelize } = require 'inflection'

module.exports = class Resource

  constructor: (@api, @entity, @definition) ->

    @defineModel()

    @defineDefaultRoutes()

    process.on 'a-http-server:api:model:relationships', (entity) =>

      @defineAuthorization()

    process.on 'a-http-server:api:model:relationships', (entity) =>

      if entity is @entity then @defineRelationshipRoutes()

      process.emit 'a-http-server:api:resource:authorization', entity

    @api.resources[@entity] = @

  defineAuthorization: ->

    ###{ secret } = @api.server.config.plugins.api.auth###

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

      route.scopes ?= @definition.resource.scopes or

      @api.resource.scopes

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

        ###

        params = [

          "#{@api.endpoint}#{route.path}",

          @scopes(route.scopes),

        ]

        ###

        app[method] "#{@api.endpoint}#{route.path}", @[method].bind(

          model: route.model

          server: @api.server

          parseQuery: @parseQuery

        )

  parseQuery: (request) ->

    { order, group, skip, limit, where } = request

    query = {}

    if order then query.order = JSON.parse order

    if group then query.group = JSON.parse group

    if skip then query.skip = JSON.parse skip

    if limit then query.limit = JSON.parse limit

    if where then query.where = JSON.parse where

    query

  get: (req, res, next) ->

    query = @parseQuery req.query

    @model.find query, (err, data) ->

      if err then return next err

      res.setHeader 'Content-Type', 'application/json'

      res.send JSON.stringify(data) or {}

  post: (req, res, next) ->

    @model.create req.body, (err, data) ->

      if err then return next err

      res.setHeader 'Content-Type', 'application/json'

      res.send JSON.stringify(data) or {}

  put: (req, res, next) ->

    { query, body } = req

    query = @parseQuery query

    @model.update query, body, (err, data) ->

      if err then return next err

      res.setHeader 'Content-Type', 'application/json'

      res.end JSON.stringify(data) or {}

  delete: (req, res, next) ->

    query = @parseQuery req.query

    @model.remove query, (err, data) ->

      if err then return next err

      res.setHeader 'Content-Type', 'application/json'

      res.end JSON.stringify(data) or {}
