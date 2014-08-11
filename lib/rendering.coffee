

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

formatObj = (obj) ->
  if showClass obj
    klass = formatClass(obj.class)
  else
    klass = ''
  classAs = if isMetaClass(obj.class) then 'Class' else obj.class
  css = cssClass[classAs] or ''
  if css
    css += " supercollider"
  """
    #{klass} <span class="#{css}">#{obj.asString}</span>
  """

formatClass = (className) ->
  """<span class="entity name class">#{className}</span>"""

formatMethod = (obj) ->
  klass = formatClass(obj.class)
  star = if isMetaClass(obj.class) then '*' else ''
  """#{klass}:<span class="method">#{star}#{obj.method}</span>"""

formatFile = (obj) ->
  if obj.file
    """<span class="file">#{obj.file}:#{obj.charPos}</span>"""
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
        line = """
          <div class="bt-name">
            #{method} <span class="frame-address">#{frame.address}</span>
          </div>
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

        line = """
          <div class="bt-name">
            a Function #{dfn}<span class="frame-address">#{frame.address}</span>
          </div>
        """
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
        link = """ open-file="#{sourcePath}:#{sourceCharPos}" """
        ll = """
          <div class='bt-line open-file' #{link}>
            #{line}
          </div>
        """
      else
        ll = """<div class='bt-line'>#{line}</div>"""

      lines.push(ll)

  joined = lines.join('')
  "<div class='bt'>#{joined}</div>"

renderError = (err, expression) ->
  error = err.error
  msg = error.errorString or err.type
  msgh = "<div><strong>#{msg}</strong></div>"
  lines = []

  # if err.type == 'SyntaxError'
  #   serr = parseSyntaxError(error.error.stdout)

  # dup of errorString for now
  # lines.push "<strong>#{error.what}</strong>"

  if error.receiver
    lines.push row('<em>Receiver</em>', formatObj(error.receiver))

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

module.exports =
  renderError: renderError
  formatBacktrace: formatBacktrace
