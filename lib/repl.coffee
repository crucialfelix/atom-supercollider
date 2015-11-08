PostWindow = require('./post-window')
Bacon = require('baconjs')
url = require('url')
os = require('os')
Q = require('q')
supercolliderjs = require('supercolliderjs')
escape = require('escape-html')
rendering = require './rendering'
growl = require 'growl'
_ = require 'underscore'
untildify = require 'untildify'
fs = require('fs')

Q.longStackSupport = true;


module.exports =
class Repl

  constructor: (@uri="sclang://localhost:57120", projectRoot, @onClose) ->
    @projectRoot = projectRoot
    @ready = Q.defer()
    @makeBus()
    @state = null
    @debug = atom.config.get 'supercollider.debug'
    if @debug
      console.log 'Supercollider REPL [DEBUG=true]'

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
    @recompiling = false

    opts =
      stdin: false
      echo: false
      debug: @debug

    if @projectRoot
      opts.cwd = @projectRoot
      process.chdir(@projectRoot)
    else
      dir = process.cwd()

    supercolliderjs.resolveOptions(null, opts)
      .then (options) =>
        if @debug
          console.log 'resolvedOptions:', options
        @bus.push rendering.displayOptions(options)
        options.errorsAsJSON = true
        @bootProcess(dir, options)

  bootProcess: (dir, options) ->
    if @debug
      console.log 'bootProcess', dir, options

    pass = () =>
      if @debug
        console.log 'booted'
      @ready.resolve()

    fail = (error) =>
      @ready.reject(error)

      # state = @sclang.state
      switch @state
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
          @bus.push("<div class='error text'>FAILED TO BOOT: state=#{@state}</div>")
          errorString = String(error)
          @bus.push("<div class='pre error text'>#{errorString}</div>")

    lastErrorTime = null

    options = this.preflight(options)
    @sclang = this.makeSclang(options)

    onBoot = () =>
      @sclang.initInterpreter().then(pass, fail)

    try
      @sclang.boot().then(onBoot, fail)
    catch error
      console.error 'Failed to boot sclang:', error
      console.trace()
      fail(error, true)

  makeSclang: (options) ->
    # construct an SCLang interpreter
    sclang = new supercolliderjs.sclang(options)

    unlisten = (sclang) ->
      for event in ['exit', 'stdout', 'stderr', 'error', 'state']
        sclang?.removeAllListeners(event)

    sclang.on 'state', (state) =>
      @state = state
      if state
        @bus.push("<div class='state #{state}'>#{state}</div>")

    sclang.on 'exit', () =>
      @bus.push("<div class='state dead'>sclang exited</div>")
      unless @recompiling
        if atom.config.get 'supercollider.growlOnError'
          growl("sclang exited", {title: "SuperCollider"})
      unlisten(sclang)
      sclang = null

    sclang.on 'stdout', (d) =>
      d = rendering.cleanStdout(d)
      d = rendering.stylizeErrors(d)
      @bus.push("<div class='pre stdout'>#{d}</div>")

    sclang.on 'stderr', (d) =>
      d = rendering.cleanStdout(d)
      d = rendering.stylizeErrors(d)
      @bus.push("<div class='pre stderr'>#{d}</div>")

    sclang.on 'error', (err) =>
      errorTime = new Date()
      err.errorTime = errorTime
      @bus.push rendering.renderError(err, null)
      if atom.config.get 'supercollider.growlOnError'
        show = true
        if lastErrorTime?
          show = (errorTime - lastErrorTime) > 1000
        if show
          growl(err.error.errorString, {title: 'SuperCollider'})
        lastErrorTime = errorTime

    return sclang

  preflight: (options) ->
    # precheck: does sclang, sclang_config exist ?
    opts = _.clone(options)
    if options.sclang
      if !fs.existsSync(options.sclang)
        @bus.push("<div class='error-label'>Executable not found:#{options.sclang}</div>")
    if options.sclang_conf
      conf = untildify(options.sclang_conf)
      if !fs.existsSync(conf)
        # if sclang_config.yaml does not exist then warn and remove it from options
        # so you can still boot
        @bus.push("<div class='warning-label'>sclang_config does not exist (will use defaults):#{conf}</div>")
        delete opts.sclang_conf
      else
        opts.sclang_conf = conf

    # if no sclang_config was specified and there IS a file in default place
    # then add that
    return opts

  eval: (expression, noecho=false, nowExecutingPath=null) ->

    deferred = Q.defer()

    ok = (result) =>
      @bus.push "<div class='pre out'>#{result}</div>"
      deferred.resolve(result)

    err = (error) =>
      deferred.reject(error)
      error.errorTime = new Date()
      @bus.push rendering.renderError(error, expression)
      # dbug = JSON.stringify(error, undefined, 2)
      # @bus.push "<div class='pre debug'>#{dbug}</div>"

    @ready.promise.then =>
      noecho = true
      unless noecho
        if expression.length > 80
          echo = expression.substr(0, 80) + '...'
        else
          echo = expression
        @bus.push "<div class='pre in'>#{echo}</div>"

      # expression path asString postErrors getBacktrace
      @sclang.interpret(expression, nowExecutingPath, true, false, true)
        .then(ok, err)

    deferred.promise

  recompile: ->
    @recompiling = true
    if @sclang?
      @sclang.quit()
        .then () =>
          @startSCLang()
    else
      @startSCLang()

  isCompiled: ->
    @state is 'ready'
    # @sclang?.state is 'ready'

  warnIsNotCompiled: ->
    @bus.push "<div class='error stderr'>Library is not compiled</div>"

  cmdPeriod: ->
    @eval("CmdPeriod.run;", true)

  clearPostWindow: ->
    @postWindow.clearPostWindow()
