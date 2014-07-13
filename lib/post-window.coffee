
{ScrollView} = require 'atom'


module.exports =
class PostWindow extends ScrollView

  constructor: (@uri, @bus) ->
    super

    @bus?.onValue (msg) =>
      if @destroyed
        Bacon.More
      else
        @addMessage(msg)

  serialize: ->

  destroy: ->
    @unsubscribe()
    @destroyed = true

  getTitle: ->
    "#{@uri}"

  @content: ->
    @div class: 'post-window', tabindex: -1, =>
      @div class:"scroll-view", =>
        @div outlet:"posts", class:"lines"

  addMessage: (text) ->
    @posts.append "<div>#{text}</div>"

# handleEvents: ->
  # @subscribe this, 'core:move-up', => @scrollUp()
  # @subscribe this, 'core:move-down', => @scrollDown()
  # @subscribe this, 'core:save-as', =>
  #   @saveAs()
  #   false
  # @subscribe this, 'core:copy', =>
  #   return false if @copyToClipboard()

  # @subscribeToCommand atom.workspaceView, 'post-window:zoom-in', =>
  #   zoomLevel = parseFloat(@css('zoom')) or 1
  #   @css('zoom', zoomLevel + .1)
  #
  # @subscribeToCommand atom.workspaceView, 'post-window:zoom-out', =>
  #   zoomLevel = parseFloat(@css('zoom')) or 1
  #   @css('zoom', zoomLevel - .1)
  #
  # @subscribeToCommand atom.workspaceView, 'post-window:reset-zoom', =>
  #   @css('zoom', 1)

  # copyToClipboard: ->
  #   return false if @loading
  #
  #   selection = window.getSelection()
  #   selectedText = selection.toString()
  #   selectedNode = selection.baseNode
  #
  #   # Use default copy event handler if there is selected text inside this view
  #   return false if selectedText and selectedNode? and $.contains(@[0], selectedNode)
  #
  #   atom.clipboard.write(@[0].innerHTML)
  #   true
  #

  # isEqual: (other) ->
  #   @[0] is other?[0] # Compare DOM elements
