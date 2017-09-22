module.exports =
class AutoCompleter
  constructor: (repl) ->
    @repl = repl
    @classes = null
    @docs = null

  updateClassList: () ->
    @repl.eval('Class.allClasses', false, null, false)
      .then (result) =>
        @classes = result
    @repl.eval('SCDoc.documents', false, null, false)
      .then (result) =>
        console.log("got results")
        @docs = result


  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) =>
    return ({text: cls, type: 'class'} for cls in @classes)
