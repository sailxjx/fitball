// Generated by CoffeeScript 1.4.0
(function() {
  var fitball,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fitball = (function() {

    function fitball() {
      this.update = __bind(this.update, this);
      this.radius = 120;
      this.size = 250;
      this.tsSpeed = 10;
      this.dtr = Math.PI / 180;
      this.d = 300;
      this.elliptical = 1;
      this.srcHash = {};
      this.vessel = null;
      this.fits = [];
      this.mcList = [];
      this.length = 0;
      this.active = false;
      this.mouse = {};
      this.lasta = 1;
      this.lastb = 1;
      this.trigs = {};
    }

    fitball.prototype.roll = function() {
      this.readSrc();
      this.initDoms();
      return this.goRoll();
    };

    fitball.prototype.readSrc = function() {
      var i, source, srcArr, srcStr, srcTxt, _i, _ref, _results;
      source = document.getElementById('source');
      srcTxt = source.value;
      srcArr = srcTxt.split("\n");
      _results = [];
      for (i = _i = 0, _ref = srcArr.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        srcStr = srcArr[i].trim();
        if (srcStr === "") {
          continue;
        } else {
          _results.push(this.srcHash[srcStr] = 1);
        }
      }
      return _results;
    };

    fitball.prototype.initDoms = function() {
      var a, fragment, k, v, _ref;
      fragment = document.createDocumentFragment();
      _ref = this.srcHash;
      for (k in _ref) {
        v = _ref[k];
        a = document.createElement('a');
        a.innerHTML = k;
        fragment.appendChild(a);
      }
      this.vessel = document.getElementById('vessel');
      return this.vessel.appendChild(fragment);
    };

    fitball.prototype.goRoll = function() {
      var fits, i, length, mcList, tag, _i,
        _this = this;
      this.fits = fits = this.vessel.getElementsByTagName('a');
      this.length = length = fits.length;
      this.mcList = mcList = [];
      for (i = _i = 0; 0 <= length ? _i < length : _i > length; i = 0 <= length ? ++_i : --_i) {
        tag = {};
        tag.offsetWidth = fits[i].offsetWidth;
        tag.offsetHeight = fits[i].offsetHeight;
        mcList.push(tag);
      }
      this.positionAll();
      this.vessel.onmouseover = function() {
        return _this.active = true;
      };
      this.vessel.onmouseout = function() {
        return _this.active = false;
      };
      this.vessel.onmousemove = function(e) {
        e = window.event || e;
        _this.mouse.x = (e.clientX - (_this.vessel.offsetLeft + _this.vessel.offsetWidth / 2)) / 5;
        return _this.mouse.y = (e.clientY - (_this.vessel.offsetTop + _this.vessel.offsetHeight / 2)) / 5;
      };
      return setInterval(this.update, 30);
    };

    fitball.prototype.update = function() {
      var a, b, c, i, length, mcList, mouse, per, radius, rx1, rx2, rx3, ry1, ry2, ry3, rz1, rz2, rz3, size, trigs, tsSpeed, _i;
      a = b = c = 0;
      mouse = this.mouse;
      size = this.size;
      radius = this.radius;
      tsSpeed = this.tsSpeed;
      length = this.length;
      mcList = this.mcList;
      if (this.active) {
        a = (-Math.min(Math.max(-mouse.y, -size), size) / radius) * tsSpeed;
        b = (Math.min(Math.max(-mouse.x, -size), size) / radius) * tsSpeed;
      } else {
        a = this.lasta * 0.98;
        b = this.lastb * 0.98;
      }
      this.lasta = a;
      this.lastb = b;
      if (Math.abs(a) <= 0.01 && Math.abs(b) <= 0.01) {
        return false;
      }
      trigs = this.sineCosine(a, b, c);
      for (i = _i = 0; 0 <= length ? _i < length : _i > length; i = 0 <= length ? ++_i : --_i) {
        rx1 = mcList[i].cx;
        ry1 = mcList[i].cy * trigs.ca + mcList[i].cz * (-trigs.sa);
        rz1 = mcList[i].cy * trigs.sa + mcList[i].cz * trigs.ca;
        rx2 = rx1 * trigs.cb + rz1 * trigs.sb;
        ry2 = ry1;
        rz2 = rx1 * (-trigs.sb) + rz1 * trigs.cb;
        rx3 = rx2 * trigs.cc + ry2 * (-trigs.sc);
        ry3 = rx2 * trigs.sc + ry2 * trigs.cc;
        rz3 = rz2;
        mcList[i].cx = rx3;
        mcList[i].cy = ry3;
        mcList[i].cz = rz3;
        per = this.d / (this.d + rz3);
        mcList[i].x = (this.elliptical * rx3 * per) - (this.elliptical * 2);
        mcList[i].y = ry3 * per;
        mcList[i].scale = per;
        mcList[i].alpha = (per - 0.6) * (10 / 6);
      }
      return this.doPos();
    };

    fitball.prototype.positionAll = function() {
      var fragment, i, length, mcList, phi, radius, theta, tmp, _i, _j, _k, _results;
      phi = theta = i = 0;
      length = this.length;
      tmp = [];
      mcList = this.mcList;
      radius = this.radius;
      fragment = document.createDocumentFragment();
      for (i = _i = 0; 0 <= length ? _i < length : _i > length; i = 0 <= length ? ++_i : --_i) {
        tmp.push(this.fits[i]);
      }
      tmp.sort(function() {
        var _ref;
        return (_ref = Math.random() < 0.5) != null ? _ref : {
          1: -1
        };
      });
      for (i = _j = 0; 0 <= length ? _j < length : _j > length; i = 0 <= length ? ++_j : --_j) {
        fragment.appendChild(tmp[i]);
      }
      this.vessel.appendChild(fragment);
      _results = [];
      for (i = _k = 0; 0 <= length ? _k < length : _k > length; i = 0 <= length ? ++_k : --_k) {
        phi = Math.acos(-1 + (2 * i) / length);
        theta = Math.sqrt(length * Math.PI) * phi;
        mcList[i].cx = radius * Math.cos(theta) * Math.sin(phi);
        mcList[i].cy = radius * Math.sin(theta) * Math.sin(phi);
        mcList[i].cz = radius * Math.cos(phi);
        this.fits[i].style.left = mcList[i].cx + this.vessel.offsetWidth / 2 - mcList[i].offsetWidth / 2 + "px";
        _results.push(this.fits[i].style.top = mcList[i].cy + this.vessel.offsetHeight / 2 - mcList[i].offsetHeight / 2 + "px");
      }
      return _results;
    };

    fitball.prototype.sineCosine = function(a, b, c) {
      this.trigs.sa = Math.sin(a * this.dtr);
      this.trigs.ca = Math.cos(a * this.dtr);
      this.trigs.sb = Math.sin(b * this.dtr);
      this.trigs.cb = Math.cos(b * this.dtr);
      this.trigs.sc = Math.sin(c * this.dtr);
      this.trigs.cc = Math.cos(c * this.dtr);
      return this.trigs;
    };

    fitball.prototype.doPos = function() {
      var i, l, mcList, t, _i, _ref, _results;
      l = this.vessel.offsetWidth / 2;
      t = this.vessel.offsetHeight / 2;
      mcList = this.mcList;
      _results = [];
      for (i = _i = 0, _ref = this.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        this.fits[i].style.left = mcList[i].cx + l - mcList[i].offsetWidth / 2 + 'px';
        this.fits[i].style.top = mcList[i].cy + t - mcList[i].offsetHeight / 2 + 'px';
        this.fits[i].style.fontSize = Math.ceil(12 * mcList[i].scale / 2) + 8 + 'px';
        this.fits[i].style.filter = "alpha(opacity=" + 100 * mcList[i].alpha + ")";
        _results.push(this.fits[i].style.opacity = mcList[i].alpha);
      }
      return _results;
    };

    return fitball;

  })();

  window.onload = function() {
    var gen;
    gen = document.getElementById('gen');
    return gen.onclick = function() {
      var fb;
      fb = new fitball();
      return fb.roll();
    };
  };

}).call(this);
