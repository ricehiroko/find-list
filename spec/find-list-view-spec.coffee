FindListView = require '../lib/find-list-view'

describe "FindListView", ->
  [workspaceElement, activationPromise, findActivationPromise, editor, findView, changeTextSpy] = []
    
  getFindAtomPanel = ->
    workspaceElement.querySelector('.find-and-replace').parentNode

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('find-list')

    waitsForPromise ->
      atom.workspace.open()
    
    runs ->
      jasmine.attachToDOM(workspaceElement)
      editor = atom.workspace.getActiveTextEditor()
      editor.setText("""
        apples
        oranges
        apples oranges apples
      """)
      
      changeTextSpy = jasmine.createSpy('changeFindText')

      findActivationPromise = atom.packages.activatePackage("find-and-replace").then ({mainModule}) ->
        mainModule.createViews()
        {findView} = mainModule
        findView.findEditor.getModel().onDidStopChanging changeTextSpy
      

  describe "when find and replace is executed", ->
      
    it "shows lines of find text", ->
      runs ->
        atom.commands.dispatch workspaceElement, 'find-and-replace:toggle'
      
      waitsForPromise ->
        activationPromise

      waitsForPromise ->
        findActivationPromise
      
      runs ->      
        findView.findEditor.setText('apple')
        atom.commands.dispatch(findView.findEditor.element, 'find-and-replace:confirm')
        findListElement = workspaceElement.querySelector('.find-list .list-group')
        console.log findListElement
        console.log workspaceElement.querySelector('.find-list .list-group > li')
