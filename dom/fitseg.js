// Generated by CoffeeScript 1.6.1
(function() {
  var chars, fitseg, fs, loadDict, path, units, words;

  fs = require('fs');

  path = require('path');

  chars = {};

  words = [];

  units = {};

  loadDict = function(callback) {
    var dictDir, dictFiles, toCallback;
    dictDir = path.dirname(module.filename);
    dictFiles = {
      'chars.dic': 1,
      'words.dic': 1,
      'units.dic': 1
    };
    toCallback = function(file) {
      delete dictFiles[file];
      if (Object.keys(dictFiles).length > 0) {
        return false;
      }
      return callback();
    };
    fs.readFile("" + dictDir + "/dict/chars.dic", function(e, d) {
      d.toString().trim().split("\n").map(function(x) {
        var k, v, _ref;
        _ref = x.split(" "), k = _ref[0], v = _ref[1];
        chars[k] = v;
        return false;
      });
      return toCallback('chars.dic');
    });
    fs.readFile("" + dictDir + "/dict/words.dic", function(e, d) {
      words = d.toString().trim().split("\n");
      return toCallback('words.dic');
    });
    return fs.readFile("" + dictDir + "/dict/units.dic", function(e, d) {
      units = d.toString().trim().split("\n").filter(function(x) {
        if (/^#/.test(x)) {
          return false;
        } else {
          return x.trim();
        }
      });
      return toCallback('units.dic');
    });
  };

  module.exports = fitseg = (function() {

    function fitseg(file) {
      this.file = file;
    }

    fitseg.prototype.run = function() {
      var _this = this;
      return loadDict(function() {
        return fs.readFile(_this.file, function(e, d) {
          _this.fileData = d.toString();
          return _this.analyse();
        });
      });
    };

    fitseg.prototype.analyse = function() {
      return console.log(this.fileData);
    };

    return fitseg;

  })();

}).call(this);