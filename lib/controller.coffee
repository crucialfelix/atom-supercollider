url = require('url')
Repl = require('./repl')


module.exports =
class Controller

  constructor: (@workspaceView, directory) ->
    @defaultURI = "sclang://localhost:57120"
    @projectRoot = directory.path
    @repls = {}
    @activeRepl = null

  start: ->
    @workspaceView.command "supercollider:open-post-window", =>
      @openPostWindow(@defaultURI)
    @workspaceView.command "supercollider:clear-post-window", =>
      @clearPostWindow()
    @workspaceView.command "supercollider:recompile", =>
      @recompile()
    @workspaceView.command "supercollider:cmd-period", =>
      @cmdPeriod()
    @workspaceView.command "supercollider:eval", =>
      @eval()
    @workspaceView.command "supercollider:open-help-file", =>
      @openHelpFile()

    # open a REPL for sclang on this host/port
    atom.workspace.registerOpener (uri) =>
      try
        {protocol, hostname, port} = url.parse(uri)
      catch error
        return
      return unless protocol is 'sclang:'

      onClose = =>
        if @activeRepl is repl
          @activeRepl = null
        delete @repls[uri]

      repl = new Repl(uri, @projectRoot, onClose)
      @activeRepl = repl
      @repls[uri] = repl
      window = repl.createPostWindow()
      repl.startSCLang()
      window

  stop: ->
    for repl in @repls
      repl.stop()
    @activeRepl = null
    @repls = {}

  openPostWindow: (uri) ->
    repl = @repls[uri]

    if repl
      @activeRepl = repl
    else
      atom.workspace.open(uri, split: 'right', searchAllPanes: true)
        .then () =>
          @activeRepl = @repls[uri]

  clearPostWindow: ->
    @activeRepl?.clearPostWindow()

  recompile: ->
    if @activeRepl
      @activeRepl.recompile()
    else
      @openPostWindow(@defaultURI)

  cmdPeriod: ->
    @activeRepl?.cmdPeriod()

  editorIsSC: ->
    editor = atom.workspace.getActiveEditor()
    editor and editor.getGrammar().scopeName is 'source.supercollider'

  currentExpression: ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?
    expression = editor.getSelectedText()
    unless expression
      row = editor.getCursorScreenRow()
      if row?
        expression = editor.lineForBufferRow(row)
    expression

  eval: ->
    return unless @editorIsSC()
    @evalWithRepl(@currentExpression())

  evalWithRepl: (expression) ->
    return unless expression

    if @activeRepl
      @activeRepl.eval(expression)
    else
      @openPostWindow(@defaultURI)
        .then () =>
          @activeRepl.eval(expression)

  openHelpFile: ->
    unless @editorIsSC()
      return false
    expression = @currentExpression()

    base = null

    # Klass.openHelpFile
    klassy = /^([A-Z]{1}[a-zA-Z0-9\_]*)$/
    match = expression.match(klassy)
    if match
      base = expression
    else
      # 'someMethod'.openHelpFile
      # starts with lowercase has no punctuation, wrap in ''
      methody = /^([a-zA-Z0-9\_]*)$/
      match = expression.match(methody)
      if match
        base = "'#{expression}'"
      else
        # anything else just do a search
        stringy = /^([^"]+)$/
        match = expression.match(stringy)
        if match
          base = '"' + expression + '"'

    if base
      @evalWithRepl("#{base}.openHelpFile")
