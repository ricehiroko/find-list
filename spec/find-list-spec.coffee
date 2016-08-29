FindList = require '../lib/find-list'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "FindList", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('find-list')

  describe "when the find-list:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.find-list')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'find-list:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.find-list')).toExist()

        findListElement = workspaceElement.querySelector('.find-list')
        expect(findListElement).toExist()

        findListPanel = atom.workspace.panelForItem(findListElement)
        expect(findListPanel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'find-list:toggle'
        expect(findListPanel.isVisible()).toBe false

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.find-list')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'find-list:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        findListElement = workspaceElement.querySelector('.find-list')
        expect(findListElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'find-list:toggle'
        expect(findListElement).not.toBeVisible()
