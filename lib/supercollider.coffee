Controller = require './controller'

module.exports =
  controller: null
  config:
    growlOnError:
      type: 'boolean'
      default: false

  activate: (state) ->
    if @controller
      return
    @controller = new Controller(atom.project.getDirectories()[0])
    @controller.start()

  deactivate: ->
    @controller.stop()
    @controller = null

  serialize: ->
    {}
