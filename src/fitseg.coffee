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


module.exports = class fitseg
  step: 10
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
    while @fileData.length > 0
      subStr = @fileData[0...@step]
      subLen = subStr.length
      endPunc = ""
      for i in [0...subLen]
        if subStr[i] in @punctuations
          endPunc = subStr[i]  # log punctuation
          subStr = subStr[0...i]
          subLen = subStr.length
          break
      chunks = @mkChunks(subStr)
      for rule in @ruleList
        oRule = new rule(subStr)
        chunks = oRule.filter()
      @wordArr.push subStr if subLen > 0
      @wordArr.push endPunc if endPunc.length > 0
      @fileData = @fileData.slice(subLen + endPunc.length)
  mkChunks: (subStr)->
    subLen = subStr.length
    chunks = []
    chunkWords = []
    # for i in [0...subLen]
    #   for n in [i...subLen]
    #     if subStr[i..n].length == 1 or subStr[i..n] in words
    #       chunkWords.push subStr[i..n]
    process.exit()