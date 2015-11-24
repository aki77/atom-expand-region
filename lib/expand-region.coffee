_ = require 'underscore-plus'
{CompositeDisposable} = require 'atom'

module.exports =
class ExpandRegion
  editor: null
  editorElement: null
  lastSelections: []
  currentIndex: 0
  lastEditor: null

  expand: (event) =>
    @editorElement = event.currentTarget
    @editor = @editorElement.getModel()

    @candidates = @computeCandidates() unless @isActive()

    @editor.expandSelectionsForward (selection) =>
      candidate = @candidates.get(selection)
      return unless candidate
      currentRange = selection.getBufferRange()
      for range, index in candidate.ranges
        if currentRange.compare(range) is 1
          candidate.index = index
          return selection.setBufferRange(range, autoscroll: false)

    @saveState()
    @currentIndex++
    return

  shrink: (event) =>
    @editorElement = event.currentTarget
    @editor = @editorElement.getModel()
    return unless @isActive()
    return if @currentIndex is 0

    @currentIndex--
    @candidates.forEach((candidate, selection) =>
      if selection.destroyed
        if candidate.ranges.length > @currentIndex
          @candidates.delete(selection)
          range  = candidate.ranges[@currentIndex]
          selection = @editor.addSelectionForBufferRange(range, autoscroll: false)
          selection.clear() if range.isEmpty()
          @candidates.set(selection, candidate)
      else if candidate.ranges.length > @currentIndex
        range = candidate.ranges[@currentIndex]
        selection.setBufferRange(range, autoscroll: false)
        selection.clear() if range.isEmpty()
    )

    @saveState()

  saveState: ->
    @lastSelections = (selection.getBufferRange() for selection in @editor.getSelections())
    @lastEditor = @editor

  computeCandidates: ->
    @lastSelections = []
    @currentIndex = 0
    candidates = new Map

    scopeDescriptor = @editor.getRootScopeDescriptor()
    commands = atom.config.get('expand-region.commands', scope: scopeDescriptor)

    results = {}
    for {command, recursive} in commands
      for selectionRange, ranges of @computeRanges(command, recursive)
        results[selectionRange] = [] unless results[selectionRange]?
        results[selectionRange].push(ranges...)

    for selection in @editor.getSelections()
      selectionRange = selection.getBufferRange()
      candidate =
       ranges: [selectionRange]
       #index: 0

      if results[selectionRange]?
        candidate.ranges.push(results[selectionRange]...)

      candidates.set(selection, candidate)

    @uniq(candidates)

  uniq: (candidates) ->
    candidates.forEach (candidate) ->
      candidate.ranges.sort((a, b) ->
        b.compare(a)
      )
      candidate.ranges = _.uniq(candidate.ranges, true, (v) -> v.toString())
    candidates

  isActive: ->
    return false if @editor isnt @lastEditor
    return false if @lastSelections.length is 0

    selections = @editor.getSelections()
    return false if @lastSelections.length isnt selections.length

    for selection, index in selections
      return false unless selection.getBufferRange().isEqual(@lastSelections[index])

    true

  computeRanges: (command, recursive = false) ->
    state = new Map
    results = {}
    ranges = []

    for selection in @editor.getSelections()
      state.set(selection, selection.getBufferRange())

    scrollTop = @editorElement.getScrollTop()

    @editor.transact =>
      atom.commands.dispatch(@editorElement, command)

      for selection in @editor.getSelections()
        results[state.get(selection)] = [selection.getBufferRange()]

      selection2string = (selection) ->
        selection.getBufferRange().toString()

      if recursive
        while 1
          prevRanges = @editor.getSelections().map(selection2string)
          atom.commands.dispatch(@editorElement, command)
          currentRanges = @editor.getSelections().map(selection2string)
          break if _.isEqual(prevRanges, currentRanges)

          for selection in @editor.getSelections()
            results[state.get(selection)].push(selection.getBufferRange())

      @editorElement.setScrollTop(scrollTop) if @editorElement.getScrollTop() isnt scrollTop
      @editor.abortTransaction()

    # restore
    state.forEach((range, selection) =>
      if selection.destroyed
        @editor.addSelectionForBufferRange(range)
      else
        selection.setBufferRange(range)
    )

    results
