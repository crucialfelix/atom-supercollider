url = require('url')
Repl = require('./repl')
{$} = require 'atom'


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
      fileOpener = (event) =>
        target = event.originalEvent.target
        return unless target
        $target = $(target)
        if not $target.is('.open-file')
          $target = $target.parents('.open-file').eq(0)
          return unless $target.length
        link = $target.attr('open-file')
        @openFileLink(link)

      atom.workspace.open(uri, split: 'right', searchAllPanes: true)
        .then () =>
          @activeRepl = @repls[uri]
          $('.post-window').on 'click', fileOpener

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

    selection = editor.getLastSelection()
    expression = selection.getText()
    if expression
      range = selection.getBufferRange()
    else
      # execute the line you are on
      pos = editor.getCursorBufferPosition()
      row = editor.getCursorScreenRow()
      if row?
        range = new Range([row, 0], [row + 1, 0])
        expression = editor.lineForBufferRow(row)
      else
        range = null
        expression = null
    [expression, range]

  currentPath: ->
    editor = atom.workspace.getActiveEditor()
    return unless editor?
    editor.getPath()

  eval: ->
    return unless @editorIsSC()
    [expression, range] = @currentExpression()
    @evalWithRepl(expression, @currentPath(), range)

  evalWithRepl: (expression, path, range) ->
    @destroyMarkers()

    return unless expression

    if @activeRepl
      @activeRepl.eval(expression, false, path)
    else
      @openPostWindow(@defaultURI)
        .then () =>
          @activeRepl.eval(expression, false, path)

  openHelpFile: ->
    unless @editorIsSC()
      return false
    [expression, range] = @currentExpression()

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

  openFileLink: (link)->
    [uri, pos] = link.split(':')
    line = 0
    col = 0
    options =
      initialLine: line
      initialColumn: col
      split: 'left'
      activatePane: false
      searchAllPanes: true

    atom.workspace.open(uri, options)
      .then (editor)->
        text = editor.getText()
        cursor = 0
        li = 0
        for line in text.split('\n')
          cursor += (line.length + 1)
          if cursor > pos
            editor.setCursorBufferPosition([li, 0])
            # editor.markBufferRange
            return
          li += 1
