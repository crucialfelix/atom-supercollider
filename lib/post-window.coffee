
{ScrollView} = require 'atom'


module.exports =
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
    @unsubscribe()
    @destroyed = true
    @onClose()

  getTitle: ->
    "#{@uri}"

  getModel: ->

  @content: ->
    @div class: 'post-window', tabindex: -1, =>
      @div outlet:"scroller", class:"scroll-view editor editor-colors", =>
        @div outlet:"posts", class:"lines"

  addMessage: (text) ->
    @posts.append "<div>#{text}</div>"

  clearPostWindow: ->
    @posts.empty()
