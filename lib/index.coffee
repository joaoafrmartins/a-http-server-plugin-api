merge = require 'lodash.merge'

mongoose = require 'mongoose'

module.exports = (next) ->

  @config.api = merge require('./config'), @config?.api or {}

  { url, options } = @config.api

  options ?= {}

  mongoose.connect url, options, () ->

    next null
