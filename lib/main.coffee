{CompositeDisposable, Disposable} = require 'atom'
StatusBarView = require './status-bar-view'

module.exports =
  subscriptions: null
  viewEditors: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor:not(mini)',
      'view-mode:toggle': (event) => @toggle(event)

    @viewEditorsSubscriptions = new WeakMap()
    @statusBarView = new StatusBarView(@viewEditorsSubscriptions)

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null
    @viewEditorsSubscriptions = null
    @statusBarView?.detach()
    @statusBarView = null

  toggle: (event) ->
    editorView = event.target
    editor = editorView?.getModel?()
    return unless editor

    subscription = @viewEditorsSubscriptions.get(editor)
    if subscription
      subscription.dispose()
      @subscriptions.remove(subscription)
      @viewEditorsSubscriptions.delete(editor)
    else
      subscription = @enable(editor, editorView)
      @subscriptions.add(subscription)
      @viewEditorsSubscriptions.set(editor, subscription)

    @statusBarView.update()

  enable: (editor, editorView) ->
    {buffer} = editor
    subscriptions = new CompositeDisposable

    editorView.component.setInputEnabled(false)
    editorView.classList.add('view-mode')

    buffer.clearUndoStack()
    buffer.history.clearRedoStack()

    subscriptions.add(editor.onWillInsertText(({cancel}) ->
      cancel()
    ))

    undo = false
    subscriptions.add(buffer.onDidChange(({newRange, oldText}) ->
      return if undo
      undo = true
      buffer.setTextInRange(newRange, oldText, undo: 'skip')
      undo = false
      buffer.clearUndoStack()
      buffer.history.clearRedoStack()
    ))

    subscriptions.add(new Disposable ->
      editorView.component.setInputEnabled(true)
      editorView.classList.remove('view-mode')
    )

    subscriptions

  consumeStatusBar: (statusBar) ->
    @statusBarView.initialize(statusBar)
