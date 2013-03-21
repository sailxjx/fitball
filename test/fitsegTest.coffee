path = require 'path'
baseDir = path.dirname module.filename
srcDir = "#{baseDir}/../src"
fitseg = require "#{srcDir}/fitseg"
ofit = new fitseg("#{baseDir}/asset/yanjiusheng.txt")
ofit.run()
