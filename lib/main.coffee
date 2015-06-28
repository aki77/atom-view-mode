{CompositeDisposable, Disposable} = require 'atom'
StatusBarView = require './status-bar-view'

module.exports =
  subscriptions: null
  viewEditors: null
  openRegex: null

  config:
    openPatterns:
      description: 'Regex of file name to open by `view-mode`.'
      default: ''
      type: 'string'

  activate: (state) ->
    @viewEditorsSubscriptions = new WeakMap()
    @statusBarView = new StatusBarView(@viewEditorsSubscriptions)

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-text-editor:not(mini)',
      'view-mode:toggle': ({target}) =>
        editor = target?.getModel?()
        @toggle(editor) if editor
    @subscriptions.add atom.commands.add '.tree-view',
      'view-mode:selected-entry': ({currentTarget: target}) =>
        entry =  target?.querySelector('.selected .name')
        filePath = entry?.dataset.path
        return unless filePath
        editor = atom.workspace.open(filePath).then((editor) =>
          @toggle(editor)
        )

    @subscriptions.add(atom.config.observe('view-mode.openPatterns', (pattern) =>
      if pattern.length > 0
        @openRegex = new RegExp(pattern, 'i')
      else
        @openRegex = null
    ))

    @subscriptions.add(atom.workspace.observeTextEditors((editor) =>
      if editor.getPath()?.match(@openRegex)
        @toggle(editor)
    ))

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null
    @viewEditorsSubscriptions = null
    @statusBarView?.detach()
    @statusBarView = null

  toggle: (editor) ->
    editorView = atom.views.getView(editor)
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
    @statusBarView.update()
