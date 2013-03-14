fs = require 'fs'
path = require 'path'

chars = {}
words = []
units = {}

loadDict = (callback)->
  dictDir = path.dirname(module.filename)
  dictFiles = {
    'chars.dic':1,
    'words.dic':1,
    'units.dic':1
  }
  toCallback = (file)->
    delete dictFiles[file]
    if Object.keys(dictFiles).length > 0
      return false
    callback()

  fs.readFile "#{dictDir}/dict/chars.dic", (e, d)->
    d.toString().trim().split("\n").map (x)->
      [k, v] = x.split(" ")
      chars[k] = v
      false
    toCallback('chars.dic')

  fs.readFile "#{dictDir}/dict/words.dic", (e, d)->
    words = d.toString().trim().split("\n")
    toCallback('words.dic')

  fs.readFile "#{dictDir}/dict/units.dic", (e, d)->
    units = d.toString().trim().split("\n").filter (x)->
      if /^#/.test(x) then return false else return x.trim()
    toCallback('units.dic')

module.exports = class fitseg
  constructor: (file)->
    @file = file
  run: ->
    loadDict =>
      fs.readFile @file, (e, d)=>
        @fileData = d.toString()
        @analyse()
  analyse: ->
    console.log @fileData
