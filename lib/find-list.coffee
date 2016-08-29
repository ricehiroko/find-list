FindListView = require './find-list-view'
{CompositeDisposable} = require 'atom'

module.exports = FindList =
  findListView: null
  subscriptions: null
  findPanel: null
  active: false
  
  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @findListView ||= new FindListView
    @FindListView = new FindListView()
    @bottomPanel = atom.workspace.addBottomPanel(item: @FindListView.getElement(), visible: false, priority: 110)
    @subscriptions.add atom.commands.add 'atom-workspace', 'find-list:toggle': => @toggle()
    @activatePlugin()

  deactivate: ->
    @subscriptions.dispose()
    @findListView.destroy()

  activatePlugin: ->
    return if @active

    @active = true

    fnrVersion = atom.packages.getLoadedPackage('find-and-replace').metadata.version
    fnrHasServiceAPI = parseFloat(fnrVersion) >= 0.194

    if fnrHasServiceAPI
      @initializeServiceAPI()
    else
      console.log "legacy api not supported"
    #   @initializeLegacyAPI()

    @subscriptions.add atom.commands.add 'atom-workspace',
      'find-and-replace:show': => @discoverMarkers()
      'find-and-replace:toggle': => @discoverMarkers()
      'find-and-replace:show-replace': => @discoverMarkers()
      'core:cancel': => @clearBindings()
      'core:close': => @clearBindings()

  initializeServiceAPI: ->
    atom.packages.serviceHub.consume 'find-and-replace', '0.0.1', (fnr) =>
      console.log "consume find and replace"
      console.log fnr
      console.log @findListView
      @findListView.fnrAPI = fnr
  
  discoverMarkers: ->
    # binding.discoverMarkers() for id,binding of @bindingsById
    console.log "discover markers"
    @findListView.discoverMarkers()
    
  clearBindings: ->
    console.log "clear bindings"

  # serialize: ->
    # findListViewState: @findListView.serialize()

  toggle: ->
    if @bottomPanel.isVisible()
      @bottomPanel.hide()
    else
      @bottomPanel.show()
    
