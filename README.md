# expand-region package

expanding selection
[![Build Status](https://travis-ci.org/aki77/atom-expand-region.svg)](https://travis-ci.org/aki77/atom-expand-region)

[![Gyazo](http://i.gyazo.com/acc77c9b51c45abf90a48156ed434ced.gif)](http://gyazo.com/acc77c9b51c45abf90a48156ed434ced)

Inspired by [vim-expand-region](https://github.com/terryma/vim-expand-region)

## Keymap

No keymap by default.

edit `~/.atom/keymap.cson`

```
'atom-text-editor':
  'alt-up': 'expand-region:expand'
  'alt-down': 'expand-region:shrink'
```

## Customize selected regions

edit `~/.atom/config.cson`

```coffeescript
# Default settings
'*':
  'expand-region':
    commands: [
      {
        command: 'editor:select-word'
        recursive: false
      }
      {
        command: 'core:select-all'
        recursive: false
      }
      {
        command: 'expand-region:select-inside-paragraph'
        recursive: false
      }
      {
        command: 'expand-region:select-inside-single-quotes'
        recursive: false
      }
      {
        command: 'expand-region:select-around-single-quotes'
        recursive: false
      }
      {
        command: 'expand-region:select-inside-double-quotes'
        recursive: false
      }
      {
        command: 'expand-region:select-around-double-quotes'
        recursive: false
      }
      {
        command: 'expand-region:select-inside-parentheses'
        recursive: true
      }
      {
        command: 'expand-region:select-around-parentheses'
        recursive: true
      }
      {
        command: 'expand-region:select-inside-curly-brackets'
        recursive: true
      }
      {
        command: 'expand-region:select-around-curly-brackets'
        recursive: true
      }
      {
        command: 'expand-region:select-inside-square-brackets'
        recursive: true
      }
      {
        command: 'expand-region:select-around-square-brackets'
        recursive: true
      }
    ]
'.text.html':
  'expand-region':
    commands: [
      {
        command: 'editor:select-word'
        recursive: false
      }
      {
        command: 'core:select-all'
        recursive: false
      }
      {
        command: 'expand-region:select-inside-single-quotes'
        recursive: false
      }
      {
        command: 'expand-region:select-around-single-quotes'
        recursive: false
      }
      {
        command: 'expand-region:select-inside-double-quotes'
        recursive: false
      }
      {
        command: 'expand-region:select-around-double-quotes'
        recursive: false
      }
      {
        command: 'expand-region:select-inside-angle-brackets'
        recursive: false
      }
      {
        command: 'expand-region:select-around-angle-brackets'
        recursive: false
      }
    ]

```
