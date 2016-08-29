path = require 'path'
{$, $$$, View, TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class FindListView extends View 
  fnrAPI : null
  
  constructor: () ->
    console.log "find list view created"
    @subscriptions = new CompositeDisposable
    
  #   # Create root element
  #   @element = document.createElement('div')
  #   @element.classList.add('find-list')
  # 
  #   # Create message element
  #   message = document.createElement('div')
  #   message.textContent = "The FindList package is Alive! It's ALIVE!"
  #   message.classList.add('message')
  #   @element.appendChild(message)

  # Returns an object that can be retrieved when package is activated
  # serialize: ->
  
  discoverMarkers: () ->
    console.log "findlistview discoverMarkers"
    if editor = atom.workspace.getActiveTextEditor()
      if @fnrAPI?
        results_marker = @fnrAPI.resultsMarkerLayerForTextEditor(editor)
        # console.log results_marker
        markers = results_marker.getMarkers()
        # console.log markers
        for marker in markers
          start_pnt = marker.getStartBufferPosition()
          end_pnt = marker.getEndBufferPosition()
          highlight = editor.getTextInBufferRange([start_pnt, end_pnt])
          line = editor.lineTextForBufferRow(start_pnt.row)
          console.log start_pnt.row+1 + " " + line
        # editorElement = atom.views.getView(editor)
        # console.log editorElement
      else
        console.log "no fnr"
    else
      console.log "couldn't get editor"
    
  # Tear down any state and detach
  destroy: ->
    # @element.remove()
    super
  # 
  # getElement: ->
  #   @element
