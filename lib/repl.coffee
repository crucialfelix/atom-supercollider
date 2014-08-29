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
    @makeBus()

  stop: ->
    @sclang?.quit()
    @postWindow.destroy()

  createPostWindow: ->

    onClose = () =>
      @sclang?.quit()
      @onClose()

    @postWindow = new PostWindow(@uri, @bus, onClose)

  makeBus: ->
    @bus = new Bacon.Bus()
    @emit = new Bacon.Bus()

  startSCLang: () ->
    opts =
      stdin: false
      echo: false

    pass = () =>
      @ready.resolve()

    fail = (error) =>
      @ready.reject()

      state = @sclang.state
      switch state
        when 'compileError'
          # stdout
          # dirs
          i = 0
          for error in error.errors
            @bus.push rendering.renderParseError(error)
            error.index = i
            @emit.push(error)
            i += 1
        else
          # initFailure
          # descrepency
          # systemError
          @bus.push("<div class='error'>ERROR: #{state}</div>")
          @bus.push("<div class='pre error'>#{error}</div>")

    # returns a promise chain
    supercolliderjs.resolveOptions(null, opts)
      .then (options) =>
        @sclang = new supercolliderjs.sclang(options)

        @sclang.on 'state', (state) =>
          @bus.push("<div class='state'>#{state}</div>")

        @sclang.on 'stdout', (d) =>
          @bus.push("<div class='pre stdout'>#{d}</div>")
        @sclang.on 'stderr', (d) =>
          @bus.push("<div class='pre stderr'>#{d}</div>")

        onBoot = () =>
          @sclang.initInterpreter()
                      .then(pass, fail)

        @sclang.boot().then(onBoot, fail)

  eval: (expression, noecho=false, nowExecutingPath=null) ->

    deferred = Q.defer()

    classic = atom.config.get 'atom-supercollider.classicRepl'

    ok = (result) =>
      @bus.push "<div class='pre out'>#{result}</div>"
      deferred.resolve(result)

    err = (error) =>
      if classic
        stdout = escape(error.error.stdout.trim())
        @bus.push "<div class='error pre'>#{stdout}</div>"
      else
        @bus.push rendering.renderError(error, expression)
        # dbug = JSON.stringify(error, undefined, 2)
        # @bus.push "<div class='pre debug'>#{dbug}</div>"
      deferred.reject(error)

    @ready.promise.then =>
      unless noecho
        if expression.length > 80
          echo = expression.substr(0, 80) + '...'
        else
          echo = expression
        # <span class='prompt'>=&gt;</span>
        @bus.push "<div class='pre in'>#{echo}</div>"

      # expression path asString postErrors getBacktrace
      @sclang.interpret(expression, nowExecutingPath, true, classic, !classic)
        .then(ok, err)

    deferred.promise

  recompile: ->
    @sclang?.quit()
      .then () =>
        @startSCLang()

  isCompiled: ->
    @sclang?.state is 'ready'

  cmdPeriod: ->
    @eval("CmdPeriod.run;", true)

  clearPostWindow: ->
    @postWindow.clearPostWindow()
