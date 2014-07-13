PostWindow = require './post-window'
Bacon = require('baconjs')
url = require('url')
# SuperColliderJS = require 'supercolliderjs'
# Session = require './session'


module.exports =
class Controller

  constructor: (@workspaceView, directory) ->
    @postWindows = {}
    @busses = {}
    @activeURI = null
    @defaultURI = "sclang://localhost:57120"

  start: ->
    @workspaceView.command "supercollider:open-post-window", =>
      @openPostWindow(@defaultURI)
    @workspaceView.command "supercollider:eval", =>
      @eval()

    atom.workspace.registerOpener (uriToOpen) =>
      try
        {protocol, hostname, port} = url.parse(uriToOpen)
      catch error
        return
      return unless protocol is 'sclang:'

      # returns it
      @createPostWindow(uriToOpen)

  stop: ->
    # @postWindow.destroy()
    # @client?.end()

  openPostWindow: (uri, fn) ->
    @activeURI = uri
    # if atom.workspace.paneForUri(uri)
    #   console.log 'exists'
    if uri of @postWindows
      # it exists, activate it
      return

    atom.workspace.open(uri, split: 'right', searchAllPanes: true)
      .done (postWindow) ->

        if fn
          fn()

        # testing...
        # bus = @busForURI(uri)
        # for i in [1..100]
        #   bus.push("good morning")

        # register for close event

  createPostWindow: (uri) ->
    win = new PostWindow(uri, @busForURI(uri))
    @postWindows[uri] = win
    win

  busForURI: (uri) ->
    bus = @busses[uri]
    unless bus
      bus = new Bacon.Bus()
      @busses[uri] = bus
    bus

  currentExpression: ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?
    editor.getSelectedText() or editor.getText()

  eval: ->
    expression = @currentExpression()

    doEval = =>
      bus = @busForURI(@activeURI)
      # bus.push "<span class='prompt'>=></span> <pre><code>#{expression}</code></pre>"
      bus.push "<span class='prompt'>=></span> #{expression}"

    if @activeURI
      doEval()
    else
      @openPostWindow @defaultURI, doEval

  # clear
  # recompile

  getPreferences: ->
    RcFinder = require('rcfinder')
    prefsFinder = new RcFinder('.supercolliderjs', {})
    prefsFinder.find(@directory) || {}
