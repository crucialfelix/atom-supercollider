Controller = require './controller'

module.exports =
  controller: null
  configDefaults:
    classicRepl: true
    growlOnError: false

  activate: (state) ->
    @controller = new Controller(
      atom.workspaceView,
      atom.project.getRootDirectory())
    @controller.start()

  deactivate: ->
    @controller.stop()

  serialize: ->
    {}
