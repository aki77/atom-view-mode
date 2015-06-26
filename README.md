# view-mode package

Read only mode.

[![Gyazo](http://i.gyazo.com/96813055d83507973f70dde16944ba12.gif)](http://gyazo.com/96813055d83507973f70dde16944ba12)

Inspired by [view.el](http://emacswiki.org/emacs/ViewMode)

## Keymap

**default**

```coffeescript
# 'atom-text-editor:not(mini)':
#   'ctrl-x ctrl-q': 'view-mode:toggle'

'atom-text-editor.view-mode:not(mini)':
  'q': 'view-mode:toggle'

  # emacs like
  'n': 'core:move-down'
  'p': 'core:move-up'

  # vi like
  'h': 'editor:move-to-beginning-of-word'
  'l': 'editor:move-to-end-of-word'
  'j': 'core:move-down'
  'k': 'core:move-up'
  'b': 'core:page-up'
  'space': 'core:page-down'

  # less like
  'g': 'core:move-to-top'
  'shift-g': 'core:move-to-bottom'
  'f': 'core:page-down'

# tree-view
'.tree-view':
  'v': 'view-mode:selected-entry'
```

## TODO

- [ ] Style Tweaks
- [ ] unwritable files opened in view-mode
