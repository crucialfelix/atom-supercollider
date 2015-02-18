path = require('path')
moment = require('moment')


row = (caption, content) ->
  cap = if caption then "#{caption}" else "&nbsp;"
  """
    <div class="tr"><div class="th">#{cap}</div>
     <div class="td">#{content}</div></div>
  """

cssClass =
  String: "string quoted double"
  Symbol: "entity name symbol"
  Float: "constant numeric"
  Integer: "constant numeric"
  True: "keyword control"
  False: "keyword control"
  Nil: "keyword control"
  Class: "entity name class"

noShowClasses = [
  'True'
  'False'
  'Nil'
]

showClass = (obj) ->
  # skip if
  # class in Nil False True
  # if "an Interpreter"
  if obj.class in noShowClasses
    return false
  if isMetaClass(obj.class)
    return false
  re = new RegExp("(a|an) #{obj.class}")
  if re.exec(obj.asString)
    return false
  return true

unfolder = (title, content) ->
  id = ('' + Math.random()).replace('0.', 'fold')
  """
    <div>
      <input type="checkbox" id="#{id}" class="unfolder"/>
      <label for="#{id}" class="toggle-label"><span class="unfold-icon">&#9654;</span><span class="fold-icon">&#9660;</span>
         #{title}
      </label>

      <div class="fold">
        #{content}
       </div>
    </div>
  """

formatObj = (obj) ->
  if showClass obj
    klass = formatClass(obj.class)
  else
    klass = ''
  classAs = if isMetaClass(obj.class) then 'Class' else obj.class
  css = cssClass[classAs] or ''
  if css
    css += " supercollider"

  asString = obj.asString.replace("<", "&lt;").replace(">", "&gt;")
  title = """#{klass} <span class="#{css}">#{asString}</span>"""

  if obj.vars? and obj.vars.length
    vsl = []
    for v in obj.vars
      fmtV = formatObj v.value
      vsl.push("""<tr><th>#{v.name}</th><td> #{fmtV}</td></tr>""")
    rows = vsl.join("")
    vs = """<table class="object-vars">#{rows}</table>"""
    unfolder(title, vs)
  else
    title


formatClass = (className) ->
  """<span class="entity name class">#{className}</span>"""

formatMethod = (obj) ->
  klass = formatClass(obj.class)
  star = if isMetaClass(obj.class) then '*' else ''
  """#{klass}:<span class="method">#{star}#{obj.method}</span>"""

formatFile = (obj) ->
  if obj.file
    uri = "#{obj.file}:#{obj.charPos}"
    """<span class="file"><a href="scclass://#{uri}">#{uri}</a></span>"""
  else
    ''

isMetaClass = (className) ->
  return /Meta_/.exec(className)

errorClassRe = /^Meta_[a-zA-Z]+Error$/

shouldSkipFrame = (frame) ->
  if frame.type is 'Method' and frame.method is 'new'
    if errorClassRe.exec(frame.class)
      return true
  return false

formatBacktrace = (bt) ->
  lines = []
  for frame in bt
    unless shouldSkipFrame(frame)
      sourcePath = frame.file
      sourceCharPos = frame.charPos
      if frame.type is "Method"
        method = formatMethod(frame)
        file = formatFile(frame)
        title = """
          <div class="bt-name">
            #{method} <span class="frame-address">#{frame.address}</span>
          </div>
          """
        line = """
          <div class="bt-link">#{file}</div>
        """
      else
        if frame.context
          method = formatMethod(frame.context)
          file = formatFile(frame.context)
          dfn = "defined in #{method}"
          sourcePath = frame.context.file
          sourceCharPos = frame.context.charPos
        else
          dfn = ''

        title = """
          <div class="bt-name">
            a <span class="entity name class supercollider">Function</span> #{dfn}<span class="frame-address">#{frame.address}</span>
          </div>
        """

        line = ""

        if frame.context
          line += """
            <div class="bt-link">#{file}</div>
          """
        # else
        #   line += "<div>in path #{nowExecutingPath}</div>"
        # else it in the intepreter context
        # either the file you ran it from
        # or another nowExecutingPath

        if frame.source
          srcCss = "supercollider source"
          line += """<div class="#{srcCss}">#{frame.source}</div>"""

      if frame.args
        line += """<h5>Args</h5>"""
        argCss = "variable parameter function supercollider"
        for arg in frame.args
          formattedVal = formatObj(arg.value)
          if arg.value.class is "Function"
            # append sourceCode and context
            formattedVal = "<div>#{formattedVal}</div>"
            if arg.value.sourceCode
              formattedVal += """
                <div class="pre source">#{arg.value.sourceCode}</div>
              """
          line += row("<span class='#{argCss}'>#{arg.name}</span>",
            formattedVal)

      if frame.vars
        line += """<h5>Vars</h5>"""
        varCss = "keyword control supercollider"
        for arg in frame.vars
          line += row("<span class='#{varCss}'>#{arg.name}</span>",
            formatObj(arg.value))

      if sourcePath
        uri = "#{sourcePath}:#{sourceCharPos}"
        title = """<a href="scclass://#{uri}">#{title}</a>"""

      ll = """<div class='bt-line'>#{title}#{line}</div>"""

      lines.push(ll)

  joined = lines.join('')

  "<div class='bt'>#{joined}</div>"

renderError = (err, expression) ->
  error = err.error
  msg = error.errorString or err.type
  if err.type is 'SyntaxError'
    msg = "#{error.msg}"

  errorTime = ""
  if err.errorTime?
    et = moment(err.errorTime).format("h:mm:ss.SSS")
    errorTime = "<span class='time'>#{et}</span>"

  msgh = "<div class='title'><strong>#{msg}</strong>#{errorTime}</div>"

  lines = []

  if err.type == 'SyntaxError'
    lines.push """
      <div class="bt">
        <div class="pre source supercollider">#{error.code}</div>
      </div>
    """
    if error.file != 'selected text'
      uri = "#{error.file}:#{error.line}"
      lines.push """
        <div open-file="#{uri}" class="open-file">
          in file #{error.file}
        </div>
      """

  if error.receiver
    lines.push row('Receiver', formatObj(error.receiver))

  if error.selector
    sel = """<span class="entity name symbol">#{error.selector}</span>"""
    lines.push row('Selector', sel)

  if error.args
    i = 0
    for a in error.args
      caption = if i then null else 'Args'
      lines.push row(caption, formatObj(a))
      i += 1

  if error.method
    lines.push row('Method', formatMethod(error.method))
  if error.alternateMethod
    lines.push row('Alternate Method', formatMethod(error.alternateMethod))
  if error.failedPrimitiveName
    lines.push row('failedPrimitiveName', error.failedPrimitiveName)
  if error.value
    lines.push row('Value', formatObj(error.value))
  if error.result
    lines.push row('Result', formatObj(error.result))

  if error.backtrace
    lines.push formatBacktrace(error.backtrace)

  body = ''
  for line in lines
    body += "<div>#{line}</div>"
  ret = """
    <div class='error error-#{err.type} source supercollider'>
      #{msgh}
      #{body}
    </div>
  """
  ret

renderParseError = (error) ->
  msgh = "<div class='title'><strong>#{error.msg}</strong></div>"
  # line,char
  uri = "#{error.file}:#{error.line},#{error.char}"
  abbrev = path.basename(error.file)
  file = """
    <div>
      in file <span title="#{uri}">#{abbrev}:#{error.line},#{error.char}</span>
    </div>
  """
  ret = """
    <div class='error error-ParseError open-file' open-file="#{uri}">
      #{msgh}
      #{file}
    </div>
  """
  ret

displayOptions = (options) ->

  rows = [
    '<div class="state config">config</div>'
    '<table class="config">'
  ]

  rower = (key, value) ->
    rows.push """<tr><th>#{key}:</th><td>#{value}</tr>"""

  if options.configPath
    rower "configFile",
      """<a href="#{options.configPath}">#{options.configPath}</a>"""
  else
    rower "config",
      "default"
  rower("sclang", options.sclang)

  rowsh = rows.join('')
  """
    <div>
      <table>#{rowsh}</table>
    </div>
  """


sc3 = /^sc3>\s*$/mg
escapeSequences = /\u001b\[[0-9]?[A-Za-z]/mg

cleanStdout = (s) ->
  if typeof s is 'string'
    s = s.replace(sc3, '')
    s = s.replace(escapeSequences, '')
  s

stylizeErrors = (d) ->
  if typeof d is 'string'
    d = d.replace(/^ERROR\:/gm,
      """<span class="error-label">ERROR:</span>""")
    d = d.replace(/^WARNING\:/gm,
      """<span class="warning-label">WARNING:</span>""")
    # server errors
    d = d.replace(/^FAILURE IN SERVER\:?/gm,
      """<span class="error-label scsynth">FAILURE IN SERVER:</span>""")
    d = d.replace(/^\*\*\* ERROR/gm,
      """<span class="error-label scsynth">*** ERROR</span>""")
  d

module.exports =
  renderError: renderError
  renderParseError: renderParseError
  formatBacktrace: formatBacktrace
  displayOptions: displayOptions
  cleanStdout: cleanStdout
  stylizeErrors: stylizeErrors
