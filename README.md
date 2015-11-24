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

Follow [the Atom guide](https://atom.io/docs/latest/using-atom-basic-customization#language-specific-settings-in-your-config-file) on language-specific configuration to adjust how regions are selected per language. Edit `~/.atom/config.cson` and use the [default settings](https://github.com/aki77/atom-expand-region/blob/master/settings/expand-region.cson) as a reference.

For example, if you want to select words with dashes first in CSS (instead of words without dashes), you could change your `config.cson` to something like:

```cson
'.source.css':
  'expand-region':
    commands: [
      # Note how `expand-region:select-word` is no longer here 
      # like it is in the defaults
      {
        command: 'expand-region:select-word-include-dash',
        recursive: false
      }
      # etc...
    ]
```

And now if you expanded while your cursor was—for example—between `x` and `t` in `text-align`, rather than selecting `text` first, you'd select the whole `text-align` property.
