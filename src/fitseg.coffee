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

class rule
  constructor: (subStr)->
    @subStr = subStr

# Maximum matching
class mmRule extends rule
  filter: ->
    console.log "mmRule"

# Largest average word length
class lawlRule extends rule
  filter: ->

# Smallest variance of word lengths
class svwlRule extends rule
  filter: ->

# Largest sum of degree of morphemic freedom of one-character words
class lsdmfocwRule extends rule
  filter: ->

class chunk
  eles: []
  pos: 0
  constructor: (num)->
    @num = num
  push: (ele, pos)->
    if pos != @pos
      return false
    if @eles.length < @num
      @eles.push ele
      @pos += ele.length
      return true
    return false

module.exports = class fitseg
  step: 10
  cNum: 3 # chunk numbers
  fileData: ''
  wordArr: []
  punctuations: ',./><?;:\'"`~!@#^&*()-=+，。、《》？；’：”·！…（）\n'
  ruleList: [mmRule, lawlRule, svwlRule, lsdmfocwRule]
  constructor: (file)->
    @file = file
  run: ->
    loadDict =>
      fs.readFile @file, (e, d)=>
        @fileData = d.toString()
        @analyse()
  analyse: ->
    fileData = @fileData
    maxWordDepth = 3
    chunkCompare = (chunkList)=>  # compare chunks in the list, and finally return the chunk imploded length
      return 2
    while fileLen = fileData.length > 0

      chunkList = []
      for i in [maxWordDepth...0]
        if fileData[i-1] in @punctuations  # if there is a punctuation in the piece of data, drop out the formor chunklist data
          chunkList = []
        if fileData[0...i] in words
          oChunk = new chunk(3)
          oChunk.push(fileData[0...i], 0)
          chunkList.push oChunk
      oChunk = new chunk(3)
      oChunk.push(fileData[0], 0)
      chunkList.push oChunk

      for oChunk in chunkList
        chunkListTmp = []
        fromIdx = oChunk.pos + maxWordDepth
        toIdx = oChunk.pos
        for i in [fromIdx...toIdx]
          if fileData[i-1] in @punctuations
            chunkListTmp = []
          if fileData[toIdx...i] in words
            oChunkCopy = 
            # ...

      console.log chunkList
      process.exit()

      fileData = fileData.slice(chunkCompare(chunkList))