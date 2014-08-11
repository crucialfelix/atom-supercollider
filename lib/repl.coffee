PostWindow = require('./post-window')
Bacon = require('baconjs')
url = require('url')
os = require('os')
Q = require('q')
supercolliderjs = require('supercolliderjs')
escape = require('escape-html')
rendering = require './rendering'


module.exports =
class Repl

  constructor: (@uri="sclang://localhost:57120", projectRoot, @onClose) ->
    @projectRoot = projectRoot
    @ready = Q.defer()

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
    opts =
      stdin: false
      echo: false

    pass = () =>
      @ready.resolve()

    fail = (error) =>
      @ready.reject()
      state = @sclang.state
      @bus.push("<div class='error'>ERROR: #{state}</div>")

    # returns a promise chain
    supercolliderjs.resolveOptions(null, opts)
      .then (options) =>
        @sclang = new supercolliderjs.sclang(options)

        @sclang.on 'stdout', (d) =>
          @bus.push("<div class='pre out'>#{d}</div>")
        @sclang.on 'stderr', (d) =>
          @bus.push("<div class='pre error'>#{d}</div>")

        @sclang.boot()
          .then () =>
            @sclang.initInterpreter()
              .then(pass, fail)

  eval: (expression, noecho=false, nowExecutingPath=null) ->

    classic = atom.config.get 'atom-supercollider.classicRepl'

    ok = (result) =>
      @bus.push "<div class='pre out'>#{result}</div>"

    err = (error) =>
      stdout = escape(error.error.stdout.trim())

      if classic
        @bus.push "<div class='error pre'>#{stdout}</div>"
      else
        @bus.push rendering.renderError(error, expression)

        # dbug = JSON.stringify(error, undefined, 2)
        # @bus.push "<div class='pre debug'>#{dbug}</div>"

    @ready.promise.then =>
      unless noecho
        if expression.length > 80
          echo = expression.substr(0, 80) + '...'
        else
          echo = expression
        # <span class='prompt'>=&gt;</span>
        @bus.push "<div class='pre in'>#{echo}</div>"

      # expression path asString postErrors
      @sclang.interpret(expression, nowExecutingPath, true, classic)
        .then(ok, err)

  recompile: ->
    @sclang?.quit()
    @startSCLang()

  cmdPeriod: ->
    @eval("CmdPeriod.run;", true)

  clearPostWindow: ->
    @postWindow.clearPostWindow()
