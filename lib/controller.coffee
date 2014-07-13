PostWindow = require './post-window'
Bacon = require('baconjs')
url = require('url')
SuperColliderJS = require 'supercolliderjs'


module.exports =
class Controller

  constructor: (@workspaceView, directory) ->
    @directory = directory.path
    @postWindows = {}
    @busses = {}
    @sclangs = {}
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

      @startSCLang(uriToOpen)

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

  startSCLang: (uri) ->
    opts = @getPreferences()
    opts.stdin = false
    opts.echo = false
    sclang = new SuperColliderJS.sclang(opts)
    sclang.boot()

    bus = @busForURI(uri)
    sclang.on 'stdout', (d)->
      bus.push("<pre>#{d}</pre>")
    sclang.on 'stderr', (d)->
      bus.push("<pre class='error'>#{d}</pre>")

    @sclangs[uri] = sclang

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
