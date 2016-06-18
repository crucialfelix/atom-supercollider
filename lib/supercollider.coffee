Controller = require './controller'

module.exports =
  controller: null
  config:
    sclangPath:
      type: 'string'
      default: ''
      title: 'Path to sclang(.exe) executable'
      description: 'Set this if you have installed SuperCollider in an unusual place or if it fails to find sclang by default. If you have created a .supercollider.yaml config file in your project directory that will take precedence over this setting.'
    growlOnError:
      type: 'boolean'
      default: false
      description: 'Raise a Native OS notification or Growl alert when your supercollider code encounters a runtime error.'
    debug:
      type: 'boolean'
      default: false
      description: 'Post additional debugging information to the Atom console'

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
