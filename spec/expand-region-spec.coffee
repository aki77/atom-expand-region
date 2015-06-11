path = require 'path'

describe "ExpandRegion", ->
  [activationPromise, editor, editorElement] = []

  beforeEach ->
    activationPromise = atom.packages.activatePackage('expand-region')

    waitsForPromise ->
      atom.packages.loadPackage('expand-region').loadSettings()

    waitsForPromise ->
      url = path.join(__dirname, 'fixtures', 'sample.coffee')
      atom.workspace.open(url).then (_editor) ->
        editor = _editor
        editorElement = atom.views.getView(editor)

  describe 'activate', ->
    beforeEach ->
      editor.setCursorScreenPosition([3, 15])

    it 'expand selection', ->
      atom.commands.dispatch editorElement, 'expand-region:expand'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(editor.getSelectedText()).toBe('arg2')

        atom.commands.dispatch editorElement, 'expand-region:expand'
        expect(editor.getSelectedText()).toBe('arg1 + arg2')

        atom.commands.dispatch editorElement, 'expand-region:expand'
        expect(editor.getSelectedText()).toBe('(arg1 + arg2)')

        atom.commands.dispatch editorElement, 'expand-region:expand'
        expect(editor.getSelectedText()).toBe('(arg1 + arg2) * arg1')

        atom.commands.dispatch editorElement, 'expand-region:expand'
        expect(editor.getSelectedText()).toBe('((arg1 + arg2) * arg1)')

        atom.commands.dispatch editorElement, 'expand-region:expand'
        expect(editor.getSelectedScreenRange()).toEqual [[2, 0], [3, 33]]

        atom.commands.dispatch editorElement, 'expand-region:expand'
        expect(editor.getSelectedScreenRange()).toEqual [[2, 0], [4, 0]]

        atom.commands.dispatch editorElement, 'expand-region:expand'
        expect(editor.getSelectedScreenRange()).toEqual [[0, 8], [8, 0]]

        atom.commands.dispatch editorElement, 'expand-region:expand'
        expect(editor.getSelectedScreenRange()).toEqual [[0, 7], [8, 1]]

        atom.commands.dispatch editorElement, 'expand-region:expand'
        expect(editor.getSelectedScreenRange()).toEqual [[0, 0], [6, 33]]

    it 'shrink selection', ->
      atom.commands.dispatch editorElement, 'expand-region:expand'

      waitsForPromise ->
        activationPromise

      runs ->
        for i in [0..8]
          atom.commands.dispatch editorElement, 'expand-region:expand'
        expect(editor.getSelectedScreenRange()).toEqual [[0, 0], [6, 33]]

        atom.commands.dispatch editorElement, 'expand-region:shrink'
        expect(editor.getSelectedScreenRange()).toEqual [[0, 7], [8, 1]]

        atom.commands.dispatch editorElement, 'expand-region:shrink'
        expect(editor.getSelectedScreenRange()).toEqual [[0, 8], [8, 0]]

        atom.commands.dispatch editorElement, 'expand-region:shrink'
        expect(editor.getSelectedScreenRange()).toEqual [[2, 0], [4, 0]]

        atom.commands.dispatch editorElement, 'expand-region:shrink'
        expect(editor.getSelectedScreenRange()).toEqual [[2, 0], [3, 33]]

        atom.commands.dispatch editorElement, 'expand-region:shrink'
        expect(editor.getSelectedText()).toBe('((arg1 + arg2) * arg1)')

        atom.commands.dispatch editorElement, 'expand-region:shrink'
        expect(editor.getSelectedText()).toBe('(arg1 + arg2) * arg1')

        atom.commands.dispatch editorElement, 'expand-region:shrink'
        expect(editor.getSelectedText()).toBe('(arg1 + arg2)')

        atom.commands.dispatch editorElement, 'expand-region:shrink'
        expect(editor.getSelectedText()).toBe('arg1 + arg2')

        atom.commands.dispatch editorElement, 'expand-region:shrink'
        expect(editor.getSelectedText()).toBe('arg2')

        atom.commands.dispatch editorElement, 'expand-region:shrink'
        expect(editor.getCursorScreenPosition()).toEqual [3, 15]

  describe 'multiple cursors', ->
    validResults = [
      [
        [[3, 13], [3, 17]]
        [[6, 13], [6, 17]]
      ]
      [
        [[3, 6], [3, 17]]
        [[6, 6], [6, 17]]
      ]
      [
        [[3, 5], [3, 18]]
        [[6, 5], [6, 18]]
      ]
      [
        [[3, 5], [3, 25]]
        [[6, 5], [6, 25]]
      ]
      [
        [[3, 4], [3, 26]]
        [[6, 4], [6, 26]]
      ]
      [
        [[2, 0], [3, 33]]
        [[5, 0], [6, 33]]
      ]
      [
        [[2, 0], [4, 0]]
        [[5, 0], [7, 0]]
      ]
      [
        [[0, 8], [8, 0]]
      ]
      [
        [[0, 7], [8, 1]]
      ]
      [
        [[0, 0], [6, 33]]
      ]
    ]

    beforeEach ->
      editor.setCursorScreenPosition([3, 15])

    it 'expand selection', ->
      editor.addCursorAtBufferPosition([6, 15])
      atom.commands.dispatch editorElement, 'expand-region:expand'

      waitsForPromise ->
        activationPromise

      runs ->
        for result in validResults
          expect(editor.getSelectedBufferRanges()).toEqual(result)
          atom.commands.dispatch editorElement, 'expand-region:expand'

    it 'shrink selection', ->
      editor.addCursorAtBufferPosition([6, 15])
      atom.commands.dispatch editorElement, 'expand-region:expand'

      waitsForPromise ->
        activationPromise

      runs ->
        count = validResults.length - 2
        for i in [0..count]
          atom.commands.dispatch editorElement, 'expand-region:expand'

        for result in validResults.reverse()
          expect(editor.getSelectedBufferRanges()).toEqual(result)
          atom.commands.dispatch editorElement, 'expand-region:shrink'
