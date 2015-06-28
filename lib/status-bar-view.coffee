module.exports =
class StatusBarView

  constructor: (@viewEditorsSubscriptions) ->
    @container = document.createElement("div")
    @container.classList.add('inline-block')

    icon = document.createElement('span')
    icon.classList.add('icon', 'icon-book', 'commits-behind-label')
    @container.appendChild(icon)

    element = document.createElement("span")
    element.classList.add('status-bar-view-mode', 'text-info')
    element.textContent = 'ViewMode'
    @container.appendChild(element)

  initialize: (@statusBar) ->
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem(@update)

  update: =>
    item = atom.workspace.getActivePaneItem()
    if item? and @viewEditorsSubscriptions.has(item)
      @attach()
    else
      @detach()

  # Private

  attach: ->
    unless @tile
      @tile = @statusBar?.addRightTile(item: @container, priority: 20)

  detach: ->
    @tile?.destroy()
    @tile = null
