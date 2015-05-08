{ Schema } = require 'caminte'

module.exports = class Database

  constructor: (@config={}) ->

    adapter = undefined

    adapters = Object.keys(@config)

    Object.defineProperty @, "adapters", value: {}

    Object.defineProperty @, "adapter",

      set: (value) =>

        if not value in adapters

          throw new Error "invalid database adapter #{value}"

        adapter = value

      get: => @adapters[adapter]

    adapters.map (name) =>

      connection = @config[name]

      { driver, options } = connection

      @adapters[name] = new Schema driver, options

      @adapter ?= name

    return @adapter

  disconnect: ->

    Object.keys(@config).map (adapter) =>

      @adapters[adapter].disconnect()
