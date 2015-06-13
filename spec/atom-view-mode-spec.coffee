# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "ViewMode", ->
  [workspaceElement, activationPromise, editor, editorElement] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('view-mode')

    waitsForPromise ->
      atom.packages.activatePackage('status-bar')

    waitsForPromise ->
      atom.workspace.open().then (_editor) ->
        editor = _editor
        editorElement = atom.views.getView(editor)
        editor.setText('123')

  describe "when the view-mode:toggle event is triggered", ->
    it "isInputEnabled() = false", ->
      expect(editorElement.component.isInputEnabled()).toBe(true)
      atom.commands.dispatch(editorElement, 'view-mode:toggle')

      waitsForPromise ->
        activationPromise

      runs ->
        expect(editorElement.component.isInputEnabled()).toBe(false)

        atom.commands.dispatch(editorElement, 'view-mode:toggle')
        expect(editorElement.component.isInputEnabled()).toBe(true)

    it "disables undo() & redo()", ->
      editor.setText('abc')
      editor.setText('def')
      editor.undo()
      expect(editor.getText()).toBe('abc')

      atom.commands.dispatch(editorElement, 'view-mode:toggle')

      waitsForPromise ->
        activationPromise

      runs ->
        editor.undo()
        expect(editor.getText()).toBe('abc')
        editor.redo()
        expect(editor.getText()).toBe('abc')

        atom.commands.dispatch(editorElement, 'view-mode:toggle')
        editor.setText('def')
        editor.undo()
        expect(editor.getText()).toBe('abc')
        editor.redo()
        expect(editor.getText()).toBe('def')

    it "disables pasteText()", ->
      editor.selectAll()
      editor.copySelectedText()
      expect(atom.clipboard.read()).toBe('123')
      editor.setText('abc')

      atom.commands.dispatch(editorElement, 'view-mode:toggle')

      waitsForPromise ->
        activationPromise

      runs ->
        editor.pasteText()
        expect(editor.getText()).toBe('abc')

        atom.commands.dispatch(editorElement, 'view-mode:toggle')
        editor.pasteText()
        expect(editor.getText()).toBe('abc123')
