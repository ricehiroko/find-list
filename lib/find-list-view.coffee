path = require 'path'
{$, SelectListView, TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class FindListView extends SelectListView
  @content: ->
    @div class: 'select-list find-list', =>
      @div class: 'button-pane', =>
        @button class: 'toggle-button', outlet: 'toggleButton', =>
          @span class: 'btn-icon icon-chevron-down', outlet: 'btnIcon'
      @subview 'filterEditorView', new TextEditorView(mini: true)
      @div class: 'error-message', outlet: 'error'
      @div class: 'loading', outlet: 'loadingArea', =>
        @span class: 'loading-message', outlet: 'loading'
        @span class: 'badge', outlet: 'loadingBadge'
      @ol class: 'list-group', outlet: 'list'

  fnrAPI : null
  finds : []
  editor : null
  bufferSelection : null
  
  initialize: () ->
    super
    @filterEditorView.hide()
    @loadingArea.hide()
    @subscriptions = new CompositeDisposable
    @toggleButton.on 'click', (e) => @toggle()
    @list.attr({"padding-top": 0, margin: 0})
  
  newEditor: (@editor) ->
    if atom.config.get('editor.fontFamily') isnt ""
      @element.style.fontFamily = atom.config.get('editor.fontFamily')

    @subscriptions.dispose()
    if @fnrAPI
      @layer = @fnrAPI.resultsMarkerLayerForTextEditor(@editor)
      @bufferSelection = @editor.getSelectedBufferRange()
      @refreshFinds()
      @selectItemForRange(@bufferSelection)
      @subscriptions.add @layer.onDidUpdate () =>
        @refreshFinds()
      @subscriptions.add @editor.onDidChangeSelectionRange (event) =>
        @bufferSelection = event.newBufferRange
        @selectItemForRange(@bufferSelection)
        
  refreshFinds: () ->
    if @list?.isVisible()
      @finds = @layer.getMarkers()
      @setItems(@finds)
  
  clearFinds: () ->
    @finds = []

  viewForItem: (item) ->
    if @editor
      start_pnt = item.getStartBufferPosition()
      end_pnt = item.getEndBufferPosition()
      highlight = @editor.getTextInBufferRange([start_pnt, end_pnt])
      highlight = "<span class=matchedText>" + highlight + "</span>"
      line = @editor.lineTextForBufferRow(start_pnt.row)
      div = document.createElement('li')
      line = line.substr(0, start_pnt.column) + highlight + line.substr(end_pnt.column)
      start_row = start_pnt.row+1
      line = "<span class=lineNumber>" + start_row + "</span>" + line
      div.innerHTML = line
      
      return div
    else
      "error"
  
  selectItemForRange: (range) ->
    for f, ii in @finds
      if range.isEqual(f.getBufferRange())
        @selectItemView(@list.find("li:eq(" + ii + ")"))

  toggle: ->
    if @list?.isVisible()
      @list.slideUp()
      @error.slideUp()
      @btnIcon.removeClass('icon-chevron-down')
      @btnIcon.addClass('icon-chevron-up')
    else
      @list.slideDown()
      @error.slideDown()
      @btnIcon.removeClass('icon-chevron-up')
      @btnIcon.addClass('icon-chevron-down')
  
  confirmed: (item) ->
    @editor.setSelectedBufferRange([item.getStartBufferPosition(), item.getEndBufferPosition()])

  show: ->
    @panel ?= atom.workspace.addBottomPanel(item: this, visible: false, priority: 110)
    @panel.show()

  hide: ->
    @panel?.hide()

  destroy: ->
    @subscriptions.dispose()
    # super
