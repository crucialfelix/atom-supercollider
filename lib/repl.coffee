PostWindow = require('./post-window')
AutoCompleter = require('./autocomplete')
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
    @autocompleter = new AutoCompleter(@)
    if @debug
      console.log 'Supercollider REPL [DEBUG=true]'

  stop: ->
    @sclang?.quit()
    @postWindow.destroy()

  createPostWindow: ->

    onClose = () =>
      @sclang?.quit()
      @onClose()

    @postWindow = new PostWindow(@uri, @postBus, onClose)

  getSuggestions: (options) ->
    @autocompleter.getSuggestions(options)

  makeBus: ->
    @postBus = new Bacon.Bus()
    @controllerBus = new Bacon.Bus()

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
        sclangPath = atom.config.get 'supercollider.sclangPath'
        if sclangPath
          options.sclang = sclangPath

        sclangConf = atom.config.get 'supercollider.sclangConf'
        if sclangConf
          options.sclang_conf = sclangConf

        if @debug
          console.log 'resolvedOptions:', options
        @postBus.push rendering.displayOptions(options)
        options.errorsAsJSON = true
        @bootProcess(dir, options)

  bootProcess: (dir, options) ->
    if @debug
      console.log 'bootProcess', dir, options

    pass = () =>
      if @debug
        console.log 'booted'
      @ready.resolve()
      @autocompleter.updateClassList()

    fail = (error) =>
      # dirs
      # stdout
      # errors
      switch @state
        when 'compileError'
          i = 0
          for error in error.errors
            @postBus.push rendering.renderParseError(error)
            error.index = i
            @controllerBus.push({type: 'error', error: error})
            i += 1
        else
          # initFailure
          # descrepency
          # systemError
          @postBus.push("<div class='error text'>FAILED TO BOOT: state=#{@state}</div>")
          errorString = String(error)
          @postBus.push("<div class='pre error text'>#{errorString}</div>")

      @controllerBus.push({type: 'paths', paths: error.dirs})

      # unhandled rejection.
      # bluebird is now complaining
      # that nothing is watching @ready
      # but this is an internal promise
      # could add my own fail handler to it that just logs
      @ready.reject(error)

    lastErrorTime = null

    options = this.preflight(options)

    if options is false
      return

    @sclang = this.makeSclang(options)

    onBoot = (response) =>
      @controllerBus.push({type: 'paths', paths: response.dirs})
      @sclang.storeSclangConf().then(pass, fail)

    try
      @sclang.boot().then(onBoot, fail)
    catch error
      console.error 'Failed to boot sclang:', error
      console.trace()
      fail(error, true)

  makeSclang: (options) ->
    # construct an SCLang interpreter
    sclang = new supercolliderjs.lang.SCLang(options)

    unlisten = (sclang) ->
      for event in ['exit', 'stdout', 'stderr', 'error', 'state']
        sclang?.removeAllListeners(event)

    sclang.on 'state', (state) =>
      @state = state
      if state
        @postBus.push("<div class='state #{state}'>#{state}</div>")
        if state is 'ready'
          # if ready then emit that paths changed in case it's a programatic recompile
          @controllerBus.push({type: 'paths', paths: @sclang.compilePaths()})

    sclang.on 'exit', () =>
      @postBus.push("<div class='state dead'>sclang exited</div>")
      unless @recompiling
        if atom.config.get 'supercollider.growlOnError'
          growl("sclang exited", {title: "SuperCollider"})
      unlisten(sclang)
      sclang = null

    sclang.on 'stdout', (d) =>
      d = rendering.cleanStdout(d)
      d = rendering.stylizeErrors(d)
      @postBus.push("<div class='pre stdout'>#{d}</div>")

    sclang.on 'stderr', (d) =>
      d = rendering.cleanStdout(d)
      d = rendering.stylizeErrors(d)
      @postBus.push("<div class='pre stderr'>#{d}</div>")

    sclang.on 'error', (err) =>
      errorTime = new Date()
      err.errorTime = errorTime
      @postBus.push rendering.renderError(err, null)
      if atom.config.get 'supercollider.growlOnError'
        show = true
        if lastErrorTime?
          show = (errorTime - lastErrorTime) > 1000
        if show
          growl(err.error.errorString, {title: 'SuperCollider'})
        lastErrorTime = errorTime

    return sclang

  preflight: (options) ->
    # precheck: does sclang and sclang_conf.yaml exist ?
    opts = _.clone(options)
    if options.sclang
      if !fs.existsSync(options.sclang)
        @postBus.push("<div class='error-label'>Executable not found: #{options.sclang}</div>
          <div class='help'>Set the path to sclang in the atom-supercollider package settings.</div>
        ")
        # halt preflight here
        return false

    if opts.sclang_conf
      conf = untildify(opts.sclang_conf)
      if !fs.existsSync(conf)
        @postBus.push("<div class='warning-label'>#{opts.sclang_conf} does not yet exist</div>
          <div class='warning-label'>It will be created when you add Quarks</div>
        ")

    return opts

  eval: (expression, noecho=false, nowExecutingPath=null, returnString=true) ->

    deferred = Q.defer()

    ok = (result) =>
      # we need to convert to string for printing if our output is a JSON object
      printable = if returnString then result else JSON.stringify(result)
      @postBus.push "<div class='pre out'>#{printable}</div>"
      deferred.resolve(result)

    err = (error) =>
      deferred.reject(error)
      error.errorTime = new Date()
      @postBus.push rendering.renderError(error, expression)
      # dbug = JSON.stringify(error, undefined, 2)
      # @postBus.push "<div class='pre debug'>#{dbug}</div>"

    @ready.promise.then =>
      noecho = true
      unless noecho
        if expression.length > 80
          echo = expression.substr(0, 80) + '...'
        else
          echo = expression
        @postBus.push "<div class='pre in'>#{echo}</div>"

      # expression path asString postErrors getBacktrace
      @sclang.interpret(expression, nowExecutingPath, returnString, false, true)
        .then(ok, err)

    deferred.promise

  recompile: ->
    @recompiling = true
    @ready = Q.defer()
    if @sclang?
      @sclang.quit()
        .then () =>
          @startSCLang()
    else
      @startSCLang()

  isCompiled: ->
    @state is 'ready'

  warnIsNotCompiled: ->
    @postBus.push "<div class='error stderr'>Library is not compiled</div>"

  cmdPeriod: ->
    @eval("CmdPeriod.run;", true)

  clearPostWindow: ->
    @postWindow.clearPostWindow()
