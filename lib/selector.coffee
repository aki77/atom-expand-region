_ = require 'underscore-plus'
{Range} = require 'atom'

module.exports =
class Selector

  @select: (event, type, args...) ->
    editor = event.target.getModel?()
    return unless editor

    method = "select#{type}"
    editor.expandSelectionsForward((selection) =>
      @[method](selection, args...)
    )

  @selectWord = (selection, includeCharacters = []) ->
    nonWordCharacters = atom.config.get('editor.nonWordCharacters', scope: selection.cursor.getScopeDescriptor())
    for char in includeCharacters
      nonWordCharacters = nonWordCharacters.replace(char, '')
    wordRegex = new RegExp("[^\\s#{_.escapeRegExp(nonWordCharacters)}]+", "g")
    options = {wordRegex, includeNonWordCharacters: false}
    selection.setBufferRange(selection.cursor.getCurrentWordBufferRange(options))
    selection.wordwise = true
    selection.initialScreenRange = selection.getScreenRange()

  @selectScope = (selection) ->
    scopes = selection.cursor.getScopeDescriptor().getScopesArray()
    return unless scopes

    selectionRange = selection.getBufferRange()
    scopes = scopes.slice().reverse()
    {editor} = selection

    for scope in scopes
      scopeRange = editor.displayBuffer.bufferRangeForScopeAtPosition(scope, selection.cursor.getBufferPosition())

      if scopeRange?.containsRange(selectionRange) and not scopeRange?.isEqual(selectionRange)
        selection.setBufferRange(scopeRange)
        return

  @selectFold = (selection) ->
    selectionRange = selection.getBufferRange()
    {editor} = selection
    {languageMode} = editor

    for currentRow in [selectionRange.start.row..0]
      [startRow, endRow] = languageMode.rowRangeForFoldAtBufferRow(currentRow) ? []
      continue unless startRow?
      continue unless startRow <= selectionRange.start.row and selectionRange.end.row <= endRow
      foldRange = new Range([startRow, 0], [endRow, editor.lineTextForBufferRow(endRow).length])

      if foldRange?.containsRange(selectionRange) and not foldRange?.isEqual(selectionRange)
        selection.setBufferRange(foldRange)
        return

  @selectInsideParagraph = (selection) ->
    range = selection.cursor.getCurrentParagraphBufferRange()
    return unless range?
    selection.setBufferRange(range)
    selection.selectToBeginningOfNextParagraph()

  @selectInsideQuotes = (selection, char, includeQuotes) ->
    findOpeningQuote = (pos) ->
      start = pos.copy()
      pos = pos.copy()
      while pos.row >= 0
        line = editor.lineTextForBufferRow(pos.row)
        pos.column = line.length - 1 if pos.column is -1
        while pos.column >= 0
          if line[pos.column] is char
            if pos.column is 0 or line[pos.column - 1] isnt '\\'
              if isStartQuote(pos)
                return pos
              else
                return lookForwardOnLine(start)
          -- pos.column
        pos.column = -1
        -- pos.row
      lookForwardOnLine(start)

    isStartQuote = (end) ->
      line = editor.lineTextForBufferRow(end.row)
      numQuotes = line.substring(0, end.column + 1).replace( "'#{char}", '').split(char).length - 1
      numQuotes % 2

    lookForwardOnLine = (pos) ->
      line = editor.lineTextForBufferRow(pos.row)

      index = line.substring(pos.column).indexOf(char)
      if index >= 0
        pos.column += index
        return pos
      null

    findClosingQuote = (start) ->
      end = start.copy()
      escaping = false

      while end.row < editor.getLineCount()
        endLine = editor.lineTextForBufferRow(end.row)
        while end.column < endLine.length
          if endLine[end.column] is '\\'
            ++ end.column
          else if endLine[end.column] is char
            -- start.column if includeQuotes
            ++ end.column if includeQuotes
            return end
          ++ end.column
        end.column = 0
        ++ end.row
      return

    {editor, cursor} = selection
    start = findOpeningQuote(cursor.getBufferPosition())
    if start?
      ++ start.column # skip the opening quote
      end = findClosingQuote(start)
      if end?
        selection.setBufferRange([start, end])

  @selectInsideBrackets = (selection, beginChar, endChar, includeBrackets) ->
    findOpeningBracket = (pos) ->
      pos = pos.copy()
      depth = 0
      while pos.row >= 0
        line = editor.lineTextForBufferRow(pos.row)
        pos.column = line.length - 1 if pos.column is -1
        while pos.column >= 0
          switch line[pos.column]
            when endChar then ++ depth
            when beginChar
              return pos if -- depth < 0
          -- pos.column
        pos.column = -1
        -- pos.row

    findClosingBracket = (start) ->
      end = start.copy()
      depth = 0
      while end.row < editor.getLineCount()
        endLine = editor.lineTextForBufferRow(end.row)
        while end.column < endLine.length
          switch endLine[end.column]
            when beginChar then ++ depth
            when endChar
              if -- depth < 0
                -- start.column if includeBrackets
                ++ end.column if includeBrackets
                return end
          ++ end.column
        end.column = 0
        ++ end.row
      return

    {editor, cursor} = selection
    start = findOpeningBracket(cursor.getBufferPosition())
    if start?
      ++ start.column # skip the opening quote
      end = findClosingBracket(start)
      if end?
        selection.setBufferRange([start, end])
