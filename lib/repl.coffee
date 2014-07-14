PostWindow = require './post-window'
Bacon = require('baconjs')
url = require('url')
SuperColliderJS = require 'supercolliderjs'


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

  eval: (expression) ->
    # <span class='prompt'>=&gt;</span>
    @bus.push "<div class='pre in'>#{expression}</div>"
    @sclang.write expression

  recompile: ->
    @sclang?.quit()
    @startSCLang()

  clearPostWindow: ->
    @postWindow.clearPostWindow()

  getPreferences: ->
    RcFinder = require('rcfinder')
    prefsFinder = new RcFinder('.supercolliderjs', {})
    prefsFinder.find(@projectRoot) || {}
