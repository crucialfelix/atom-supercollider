url = require('url')
Repl = require('./repl')
{$, Range} = require 'atom'


module.exports =
class Controller

  constructor: (@workspaceView, directory) ->
    @defaultURI = "sclang://localhost:57120"
    @projectRoot = directory.path
    @repls = {}
    @activeRepl = null
    @markers = []

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
          @destoryRepl()
        delete @repls[uri]

      repl = new Repl(uri, @projectRoot, onClose)
      @activateRepl repl
      @repls[uri] = repl
      window = repl.createPostWindow()
      repl.startSCLang()
      window

  stop: ->
    for repl in @repls
      repl.stop()
    @destroyRepl()
    @repls = {}

  activateRepl: (repl) ->
    @activeRepl = repl
    console.log repl
    @activeRepl.unsubscriber = repl.emit.subscribe (event) =>
      @handleReplEvent(event)

  destroyRepl: () ->
    @activeRepl?.unsubscriber()
    @activeRepl = null

  handleReplEvent: (event) ->
    error = event.value()
    if error.index == 0
      @openToSyntaxError(error.file, error.line, error.char)

  openPostWindow: (uri) ->
    repl = @repls[uri]

    if repl
      @activateRepl repl
    else
      fileOpener = (event) =>
        target = event.originalEvent.target
        return unless target
        $target = $(target)
        if not $target.is('.open-file')
          $target = $target.parents('.open-file').eq(0)
          return unless $target.length
        link = $target.attr('open-file')
        [path, charPos] = link.split(':')
        if ',' in charPos
          [lineno, char] = charPos.split(',')
          @openFile(path, null, parseInt(lineno), parseInt(char))
        else
          @openFile(path, parseInt(charPos))

      atom.workspace.open(uri, split: 'right', searchAllPanes: true)
        .then () =>
          @activateRepl @repls[uri]
          $('.post-window').on 'click', fileOpener

  clearPostWindow: ->
    @activeRepl?.clearPostWindow()

  recompile: ->
    @destroyMarkers()
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


    doIt = () =>
      unflash = @evalFlash(range)

      onSuccess = () ->
        unflash('eval-success')

      onError = (error) =>
        if error.type is 'SyntaxError'
          unflash('eval-syntax-error')
          if path
            # offset syntax error by position of selected text in file
            row = range.getRows()[0] + error.error.syntaxErrors.line - 1
            col = error.error.syntaxErrors.charPos
            @openToSyntaxError(path, parseInt(row), parseInt(col))
        else
          # runtime error
          unflash('eval-error')

      @activeRepl.eval(expression, false, path)
        .then(onSuccess, onError)

    if @activeRepl
      # if stuck in compile error
      # then post warning and return
      unless @activeRepl.isCompiled()
        console.log 'not compiled'
        return
      doIt()
    else
      @openPostWindow(@defaultURI)
        .then doIt

  openToSyntaxError: (path, line, char) ->
    @openFile(path, null, line, char)

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

  openFile: (uri, charPos, row, col)->
    options =
      initialLine: row
      initialColumn: col
      split: 'left'
      activatePane: false
      searchAllPanes: true

    atom.workspace.open(uri, options)
      .then (editor) =>
        setMark = (point) =>
          editor.setCursorBufferPosition(point)
          expression = editor.lineForBufferRow(point[0])
          range = [point, [point[0], expression.length - 1]]
          @destroyMarkers()

          marker = editor.markBufferRange(range, invalidate: 'touch')
          decoration = editor.decorateMarker(marker,
            type: 'line',
            class: 'line-error')
          @markers.push marker

        if row?
          return setMark([row, col])

        text = editor.getText()
        cursor = 0
        li = 0
        for ll in text.split('\n')
          cursor += (ll.length + 1)
          if cursor > charPos
            return setMark([li, cursor - charPos - ll.length])
          li += 1

  destroyMarkers: () ->
    @markers.forEach (m) ->
      m.destroy()
    @markers = []

  evalFlash: (range) ->
    editor = atom.workspace.getActiveEditor()
    marker = editor.markBufferRange(range, invalidate: 'touch')
    decoration = editor.decorateMarker(marker,
                    type: 'line',
                    class: "eval-flash")
    # return fn to flash error/success and destroy the flash
    (cssClass) ->
      decoration.update(type: 'line', class: cssClass)
      destroy = ->
        marker.destroy()
      setTimeout(destroy, 100)
