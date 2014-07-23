PostWindow = require './post-window'
Bacon = require('baconjs')
url = require('url')
SuperColliderJS = require 'supercolliderjs'
RcFinder = require('rcfinder')
os = require('os')


module.exports =
class Repl

  constructor: (@uri="sclang://localhost:57120", projectRoot, @onClose) ->
    @projectRoot = projectRoot

  stop: ->
    @sclang?.quit()
    @postWindow.destroy()

  createPostWindow: ->
    unless @bus
      @makeBus()

    onClose = () =>
      @sclang?.quit()
      @onClose()

    @postWindow = new PostWindow(@uri, @bus, onClose)

  makeBus: ->
    @bus = new Bacon.Bus()

  startSCLang: () ->
    opts = @getPreferences()
    opts.stdin = false
    opts.echo = false
    @sclang = new SuperColliderJS.sclang(opts)
    @sclang.boot()

    @sclang.on 'stdout', (d) =>
      @bus.push("<div class='pre out'>#{d}</div>")
    @sclang.on 'stderr', (d) =>
      @bus.push("<div class='pre error'>#{d}</div>")

  eval: (expression, noecho=false) ->
    unless noecho
      if expression.length > 80
        echo = expression.substr(0, 80) + '...'
      else
        echo = expression
      # <span class='prompt'>=&gt;</span>
      @bus.push "<div class='pre in'>#{echo}</div>"

    escaped = expression.replace(/[\n\r]/g, '__NL__')
                        .replace(/\"/g, '\\"')
    command = "\"#{escaped}\".replace(\"__NL__\", Char.nl).interpret;\n"
    @sclang.write command

  recompile: ->
    @sclang?.quit()
    @startSCLang()

  cmdPeriod: ->
    # aka panic !
    @eval("CmdPeriod.run;", true)

  clearPostWindow: ->
    @postWindow.clearPostWindow()

  getPreferences: ->
    prefsFinder = new RcFinder('.supercolliderrc', {})
    opts = prefsFinder.find(@projectRoot)
    unless opts
      opts = {}
      switch os.platform()
        when 'win32'
          opts.path = ''
        when 'darwin'
          opts.path = "/Applications/SuperCollider/SuperCollider.app/Contents/Resources"
        else
          opts.path = '/usr/local/bin'
    opts
