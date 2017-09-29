fuzz = require('fuzzaldrin-plus')

module.exports =
class AutoCompleter
  constructor: (repl) ->
    @repl = repl
    @classes = null
    @docs = null
    # pre-allocate so it only gets compiled once
    # look for some set of period-separated identifiers before the cursor
    @prefixRegex = /([A-Za-z0-9_.]*)$/

  handleNakedPrefix: (prefix) ->
    # currently we onyly have classes in our naked database. If we
    # add global variables we'll need to tweak this
    names = fuzz.filter(@classes, prefix, {maxResults: 20})
    return ({
      text: name,
      description: @docs["Classes/#{name}"],
      type: "class"} for name in names)

  handleClassMemberPrefix: (className, prefix) ->
    candidates = []
    return @getClassMethods(className)
      .then (methods) =>
        for m in methods
          candidates.push({
            text: m.name,
            description: @makeMethodString(m),
            type: "method"
          })
        return candidates

  makeMethodString: (method) ->
    argStrings = []
    sep = ", "
    N = method.args.length
    if N == 0
      # no arguments, show without parens
      return method.name
    for i in [0..(N-1)]
      if method.argDefaults[i] == null
        argStrings.push(method.args[i])
      else
        argStrings.push("#{method.args[i]}=#{method.argDefaults[i]}")
    return "#{method.name}(#{argStrings.join(sep)})"

  # these introspection commands return nil instead of an empty list
  # if there aren't any methods/vars. bummer.
  getClassMethods: (className) ->
    code = """
    if(#{className}.class.methods.isNil, {[]}, {
      #{className}.class.methods.collect {
      	arg m;
      	(
      		\\name: m.name,
      		\\args: if(m.argNames.isNil, {[]}, {m.argNames[1..]}),
      		\\argDefaults: if(m.prototypeFrame.isNil, {[]}, {m.prototypeFrame[1..]})
      	)
      }
    })
    """
    return @repl.eval(code, true, null, false, false)

  getClassVars: (className) ->
    code = """
    if(#{className}.classVarNames.isNil, {[]}, {
      #{className}.classVarNames
    })
    """
    return @repl.eval(code, true, null, false, false)

  updateClassList: () ->
    @repl.eval('Class.allClasses', true, null, false, false)
      .then (result) =>
        @classes = result
    @repl.eval('SCDoc.documents.collect {arg doc; doc.summary}',
               true, null, false, false)
      .then (result) =>
        @docs = result

  getSuggestions: ({editor, bufferPosition}) =>
     # Get the text for the line up to the triggered buffer position
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    # this regex matches empty, so we should always get something
    prefix = line.match(@prefixRegex)[0]
    objs = prefix.split('.');
    if objs.length == 1
      return @handleNakedPrefix(objs[0])
    else if objs.length == 2 && objs[0] in @classes
      return @handleClassMemberPrefix(objs[0], objs[1])
    else
      return []
