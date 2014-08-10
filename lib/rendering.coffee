

row = (caption, content) ->
  cap = if caption then "#{caption}:" else "&nbsp;"
  """<div class="tr"><div class="th">#{cap}</div>
     <div class="td">#{content}</div></div>"""

formatObj = (obj) ->
  """<span class="class">#{obj.class}</span> <span>#{obj.asString}</span>"""

formatMethod = (obj) ->
  """<span class="class">#{obj.class}</span>:
    <span class="method">#{obj.method}</span>"""

module.exports =
  renderError: (err, expression) ->
    console.log err
    error = err.error
    msg = error.errorString or err.type
    msgh = "<div><strong>#{msg}</strong></div>"
    lines = []

    # dup of errorString for now
    # lines.push "<strong>#{error.what}</strong>"

    if error.receiver
      lines.push row('Receiver', formatObj(error.receiver))

    if error.selector
      lines.push row('Selector', error.selector)

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

    body = ''
    for line in lines
      body += "<div>#{line}</div>"
    ret = "<div class='error error-#{err.type}'>#{msgh}#{body}</div>"
    ret
