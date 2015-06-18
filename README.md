# expand-region package

expanding selection
[![Build Status](https://travis-ci.org/aki77/atom-expand-region.svg)](https://travis-ci.org/aki77/atom-expand-region)

[![Gyazo](http://i.gyazo.com/345e05e29cc1e6e1d103f49d50c52b01.gif)](http://gyazo.com/345e05e29cc1e6e1d103f49d50c52b01)

Inspired by [vim-expand-region](https://github.com/terryma/vim-expand-region)

## Features

* Support for multiple cursors.
* You can easily customize.

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

[default settings](https://github.com/aki77/atom-expand-region/blob/master/settings/expand-region.cson)
