FindList = require '../lib/find-list'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "FindList", ->
  [workspaceElement, activationPromise, findActivationPromise] = []

  getFindAtomPanel = ->
    workspaceElement.querySelector('.find-and-replace').parentNode

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('find-list')

    waitsForPromise ->
      atom.workspace.open('find-list-spec.coffee')
    
    runs ->
      jasmine.attachToDOM(workspaceElement)

      findActivationPromise = atom.packages.activatePackage("find-and-replace").then ({mainModule}) ->
        mainModule.createViews()
        {findView} = mainModule
    
  describe "when the find-and-replace:toggle event is triggered", ->
    it "hides and shows the panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.find-list')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'find-and-replace:toggle'

      waitsForPromise ->
        activationPromise

      waitsForPromise ->
        findActivationPromise

      runs ->
        expect(workspaceElement.querySelector('.find-list')).toExist()
        findListElement = workspaceElement.querySelector('.find-list')
        expect(findListElement).toBeVisible()
        
        atom.commands.dispatch workspaceElement, 'find-and-replace:toggle'
        expect(findListElement).not.toBeVisible()
