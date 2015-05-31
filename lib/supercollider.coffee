Controller = require './controller'

module.exports =
  controller: null
  configDefaults:
    classicRepl: true
    growlOnError: false

  activate: (state) ->
    if @controller
      return
    @controller = new Controller(atom.project.getRootDirectory())
    @controller.start()

  deactivate: ->
    @controller.stop()
    @controller = null

  serialize: ->
    {}
