Api = require './api'

methodOverride = require 'method-override'

configFn = require 'a-http-server-config-fn'

module.exports = (next) ->

  configFn @config, "#{__dirname}/config"

  Object.defineProperty @, "api", value: new Api @

  process.on "a-http-server:shutdown:dettach", () =>

    @api.database.disconnect()

    process.emit "a-http-server:shutdown:dettached", "api"

  { getters, methods } = @config.plugins.api['method-override']

  getters.map (getter) => @app.use methodOverride getter, methods

  process.emit "a-http-server:shutdown:attach", "api"

  next null
