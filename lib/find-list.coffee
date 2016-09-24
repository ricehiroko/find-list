FindListView = require './find-list-view'
{CompositeDisposable} = require 'atom'

module.exports = FindList =
  findListView: null
  subscriptions: null
  editor_subscription: null
  
  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @findListView = new FindListView
    fnrVersion = atom.packages.getLoadedPackage('find-and-replace').metadata.version
    fnrHasServiceAPI = parseFloat(fnrVersion) >= 0.194
    
    if fnrHasServiceAPI
      atom.packages.serviceHub.consume 'find-and-replace', '0.0.1', (fnr) =>
        @findListView.fnrAPI = fnr
        @showFind()
    else
      console.log "legacy api not supported"

    @subscriptions.add atom.commands.add 'atom-workspace',
      'find-and-replace:show': => @showFind()
      'find-and-replace:toggle': => @toggle()
      'find-and-replace:show-replace': => @showFind()
      'core:cancel': => @clearFinds()
      'core:close': => @clearFinds()
    
  deactivate: ->
    @subscriptions.dispose()
    @editor_subscription.dispose()
    @findListView.destroy()

  showFind: ->
    @newEditor()
    @findListView.show()

  newEditor: ->
    if @editor_subscription
      @editor_subscription.dispose()
    
    @editor_subscription = atom.workspace.onDidStopChangingActivePaneItem (paneItem) =>
      @newEditor()
    if editor = atom.workspace.getActiveTextEditor()
      @findListView.newEditor(editor)
    
  clearFinds: ->
    @findListView.clearFinds()
    if @findListView.isVisible()
      @findListView.hide()

  serialize: ->
    # findListViewState: @findListView.serialize()

  toggle: ->
    if @findListView.isVisible()
      @findListView.hide()
    else
      @newEditor()
      @findListView.show()
    
  
