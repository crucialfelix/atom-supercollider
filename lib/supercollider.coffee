Controller = require './controller'

module.exports =
  controller: null
  config:
    sclangPath:
      type: 'string'
      default: ''
      title: '(Optional) Path to sclang(.exe) executable'
      description: 'It should just work. Set this if you have installed SuperCollider in an unusual place or if it fails to find sclang by default. If you have created a .supercollider.yaml config file in your project directory that will take precedence over this setting.'
    sclangConf:
      type: 'string'
      default: ''
      title: '(Optional) Path to sclang_conf.yaml'
      description: 'It should just work. This is the config file that sets the include paths for supercollider. It is updated when using the Quarks.gui to add or remove packages. Example: ~/Library/Application Support/SuperCollider/sclang_conf.yaml'
    updateProjectFolders:
      type: 'boolean'
      default: true
      description: 'Automatically add installed Quarks and the class library to your project.'
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
    @controller = new Controller()
    @controller.start()

  deactivate: ->
    @controller.stop()
    @controller = null

  serialize: ->
    {}

  provide: () ->
    @controller.provider
