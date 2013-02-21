class fitball
  init: ->
    @radius = 120
    @size = 250
    @tsSpeed = 10 # animate speed
    @dtr = Math.PI/180 # every degree
    @d = 300
    @elliptical = 1
    @srcHash = {}
    @vessel = null
    @fits = [] # dom list
    @mcList = [] # dom height/width/position list
    @length = 0
    @active = false # whether need to active mouse event
    @animate = true # animate or stop
    @mouse = {}
    @lasta = 1
    @lastb = 1
    @trigs = {}
    @max = 0
    @min = 10000
  roll: ->
    @init()
    @readSrc()
    @initDoms()
    @unbindEvents()
    @goRoll()
  unbindEvents: ->
    @vessel.onmouseover = null
    @vessel.onmouseout = null
    @vessel.onmousemove = null
    window.onkeyup = null
    clearInterval @si if typeof @si != 'undefined'
  readSrc: ->
    source = document.getElementById 'source'
    srcTxt = source.value
    srcArr = srcTxt.split "\n"
    for i in [0...srcArr.length]
      srcStr = srcArr[i].trim()
      if srcStr == ""
        continue
      else
        [word, num] = srcStr.split ','
        num = num || 1
        @srcHash[word] = 0 if typeof @srcHash[word] == 'undefined'
        @srcHash[word] += parseInt(num)
        if @max < @srcHash[word] then @max = @srcHash[word]
        if @min > @srcHash[word] then @min = @srcHash[word]
  initDoms: ->
    fragment = document.createDocumentFragment()
    distance = @max - @min
    for k,v of @srcHash
      a = document.createElement 'a'
      a.innerHTML = k
      if distance == 0 then scale = 1 else scale = Math.sin(Math.PI / 6 + Math.PI * (v - @min) / (3 * distance)) + 0.25
      a.scale = scale
      fragment.appendChild a
    @vessel = document.getElementById 'vessel'
    @vessel.innerHTML = ''
    @vessel.appendChild fragment
  goRoll: ->
    @fits = fits = @vessel.getElementsByTagName 'a'
    @length = length = fits.length
    @mcList = mcList = []
    for i in [0...length]
      tag = {}
      tag.offsetWidth = fits[i].offsetWidth
      tag.offsetHeight = fits[i].offsetHeight
      mcList.push tag
    @positionAll() # init all tag position
    @vessel.onmouseover = =>
      @active = true
    @vessel.onmouseout = =>
      @active = false
    @vessel.onmousemove = (e)=>
      e = window.event || e
      @mouse.x = (e.clientX - (@vessel.offsetLeft + @vessel.offsetWidth / 2)) / 5
      @mouse.y = (e.clientY - (@vessel.offsetTop + @vessel.offsetHeight / 2)) / 5
    @si = setInterval @update, 30
    stay = false
    window.onkeyup = (e)=>
      e = window.event || e
      kc = e.keyCode || e.keyCode
      if kc == 32 #space key
        if stay
          @si = setInterval @update, 30
          stay = false
        else
          clearInterval(@si)
          stay = true
  update: =>
    a = b = c = 0
    mouse = @mouse
    size = @size
    radius = @radius
    tsSpeed = @tsSpeed
    length = @length
    mcList = @mcList
    if @active
      a = (-Math.min(Math.max(-mouse.y, -size), size) / radius) * tsSpeed
      b = (Math.min(Math.max(-mouse.x, -size), size) / radius) * tsSpeed
    else
      a = @lasta * 0.98
      b = @lastb * 0.98
    @lasta = a
    @lastb = b
    if Math.abs(a) <= 0.01 && Math.abs(b) <= 0.01
      return false
    trigs = @sineCosine(a, b, c)
    for i in [0...length]
      rx1 = mcList[i].cx
      ry1 = mcList[i].cy * trigs.ca + mcList[i].cz * (-trigs.sa)
      rz1 = mcList[i].cy * trigs.sa + mcList[i].cz * trigs.ca;
      rx2 = rx1 * trigs.cb + rz1 * trigs.sb
      ry2 = ry1
      rz2 = rx1 * (-trigs.sb) + rz1 * trigs.cb
      rx3 = rx2 * trigs.cc + ry2 * (-trigs.sc)
      ry3 = rx2 * trigs.sc + ry2 * trigs.cc
      rz3 = rz2
      mcList[i].cx = rx3
      mcList[i].cy = ry3
      mcList[i].cz = rz3
      per = @d / (@d + rz3)  
      mcList[i].x = (@elliptical *  rx3 * per) - (@elliptical * 2)
      mcList[i].y = ry3 * per
      mcList[i].scale = per
      mcList[i].alpha = (per - 0.6) * (10 / 6)
    @doPos()
  positionAll: ->
    phi = theta = i = 0
    length = @length
    tmp = []
    mcList = @mcList
    radius = @radius
    fragment = document.createDocumentFragment()
    for i in [0...length]
       tmp.push @fits[i]
    tmp.sort ()-> # sort by random
      return Math.random() < 0.5 ? 1: -1   
    for i in [0...length]
      fragment.appendChild tmp[i]
    @vessel.appendChild fragment
    for i in [0...length]
      phi = Math.acos(-1 + (2*i) / length)
      theta = Math.sqrt(length*Math.PI) * phi
      mcList[i].cx = radius * Math.cos(theta)*Math.sin(phi)
      mcList[i].cy = radius * Math.sin(theta)*Math.sin(phi)
      mcList[i].cz = radius * Math.cos(phi)
      @fits[i].style.left = mcList[i].cx + @vessel.offsetWidth / 2 - mcList[i].offsetWidth / 2 + "px"
      @fits[i].style.top = mcList[i].cy + @vessel.offsetHeight / 2 - mcList[i].offsetHeight / 2 + "px"
  sineCosine: (a, b, c)->
    @trigs.sa = Math.sin(a * @dtr)
    @trigs.ca = Math.cos(a * @dtr)
    @trigs.sb = Math.sin(b * @dtr)
    @trigs.cb = Math.cos(b * @dtr)
    @trigs.sc = Math.sin(c * @dtr)
    @trigs.cc = Math.cos(c * @dtr)
    @trigs
  doPos: ->
    l = @vessel.offsetWidth / 2
    t = @vessel.offsetHeight / 2
    mcList = @mcList
    for i in [0...@length]
      @fits[i].style.left = mcList[i].cx + l - mcList[i].offsetWidth / 2 + 'px'
      @fits[i].style.top = mcList[i].cy + t - mcList[i].offsetHeight / 2 + 'px'
      @fits[i].style.fontSize = (Math.ceil(12 * mcList[i].scale / 2) + 8) * @fits[i].scale + 'px'
      @fits[i].style.filter = "alpha(opacity=" + 100 * mcList[i].alpha + ")"
      @fits[i].style.opacity = mcList[i].alpha
window.onload =->
  fb = new fitball()
  gen =  document.getElementById 'gen'
  gen.onclick = ->
    fb.roll()
  gen.click()