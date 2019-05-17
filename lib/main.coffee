{CompositeDisposable} = require 'atom'
ExpandRegion = require './expand-region'
Selector = require './selector'

module.exports =
  subscriptions: null

  config:
    commands:
      type: 'array'
      default: [
        {
          command: 'editor:select-word'
          recursive: false
        }
        {
          command: 'expand-region:select-word-include-dash',
          recursive: false
        }
        {
          command: 'expand-region:select-word-include-dash-and-dot',
          recursive: false
        }
        {
          command: 'expand-region:select-fold'
          recursive: true
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
      items:
        type: 'object'
        properties:
          command:
            type: 'string'
          once:
            type: 'boolean'

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @expandRegion = new ExpandRegion

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'expand-region:expand': @expandRegion.expand
      'expand-region:shrink': @expandRegion.shrink
      'expand-region:select-word-include-dash': (event) -> Selector.select(event, 'Word', ['-'])
      'expand-region:select-word-include-dash-and-dot': (event) -> Selector.select(event, 'Word', ['-', '.'])
      'expand-region:select-tag-attribute': (event) -> Selector.select(event, 'Word', ['-', '.', '"', '=', '/'])
      'expand-region:select-scope': (event) -> Selector.select(event, 'Scope')
      'expand-region:select-fold': (event) -> Selector.select(event, 'Fold')
      'expand-region:select-inside-paragraph': (event) -> Selector.select(event, 'InsideParagraph')
      'expand-region:select-inside-single-quotes': (event) -> Selector.select(event, 'InsideQuotes', '\'', false)
      'expand-region:select-inside-double-quotes': (event) -> Selector.select(event, 'InsideQuotes', '"', false)
      'expand-region:select-inside-back-ticks': (event) -> Selector.select(event, 'InsideQuotes', '`', false)
      'expand-region:select-inside-parentheses': (event) -> Selector.select(event, 'InsideBrackets', '(', ')', false)
      'expand-region:select-inside-curly-brackets': (event) -> Selector.select(event, 'InsideBrackets', '{', '}', false)
      'expand-region:select-inside-angle-brackets': (event) -> Selector.select(event, 'InsideBrackets', '<', '>', false)
      'expand-region:select-inside-square-brackets': (event) -> Selector.select(event, 'InsideBrackets', '[', ']', false)
      'expand-region:select-inside-tags': (event) -> Selector.select(event, 'InsideBrackets', '>', '<', false)
      'expand-region:select-around-single-quotes': (event) -> Selector.select(event, 'InsideQuotes', '\'', true)
      'expand-region:select-around-double-quotes': (event) -> Selector.select(event, 'InsideQuotes', '"', true)
      'expand-region:select-around-back-ticks': (event) -> Selector.select(event, 'InsideQuotes', '`', true)
      'expand-region:select-around-parentheses': (event) -> Selector.select(event, 'InsideBrackets', '(', ')', true)
      'expand-region:select-around-curly-brackets': (event) -> Selector.select(event, 'InsideBrackets', '{', '}', true)
      'expand-region:select-around-angle-brackets': (event) -> Selector.select(event, 'InsideBrackets', '<', '>', true)
      'expand-region:select-around-square-brackets': (event) -> Selector.select(event, 'InsideBrackets', '[', ']', true)

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null
