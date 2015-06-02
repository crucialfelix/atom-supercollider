
{ScrollView} = require 'atom-space-pen-views'
$ = require 'jquery'
Bacon = require('baconjs')


class PostWindow extends ScrollView

  constructor: (@uri, @bus, @onClose) ->
    super

    @bus?.onValue (msg) =>
      if @destroyed
        Bacon.NoMore
      else
        @addMessage(msg)
        @scrollToBottom()

  serialize: ->

  destroy: ->
    @destroyed = true
    @onClose()

  getTitle: ->
    "#{@uri}"

  getModel: ->

  @content: ->
    @div class: 'native-key-bindings post-window', tabindex: -1, =>
      @div outlet: "scroller", class: "scroll-view editor editor-colors", =>
        @div outlet: "posts", class: "lines"

  addMessage: (text) ->
    @posts.append "<div>#{text}</div>"

  clearPostWindow: ->
    @posts.empty()

  # these are just to satisfy atom's deprecation checkers
  # that are worried that this ScrollView subclass still has 'on'
  onDidChangeTitle: ->
  onDidChangeModified: ->


module.exports = PostWindow
