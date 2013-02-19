class fitball
  constructor: -> #initialize
    @mcList = []
    @radius = 120
    @dtr = Math.PI/180
    @maxEles = 20 # max fitball elements
    @size = 250
    @tspeed = 10
    @d = 300
    @lasta = 1
    @lastb = 1
  roll: -> #action begin
    i = 0
    mouseX = 0;
    mouseY = 0;
    active = false; #active update

    @vessel = document.getElementById 'vessel'
    @fitEles = @vessel.getElementsByTagName 'a' #get all fitball elements
    @fitEleLength = @fitEles.length
    for i in [0...@fitEleLength]
      tag = {}
      tag.offsetWidth = @fitEles[i].offsetWidth
      tag.offsetHeight = @fitEles[i].offsetHeight
      @mcList.push tag #an array for positions
    @sineCosine(0,0,0)
    @positionAll()
    vessel = @vessel
    @vessel.onmouseover = ->
      active = true
    @vessel.onmouseover = ->
      active = false
    @vessel.onmousemove = (e)->
      e = window.event || e;
      mouseX = e.clientX - (vessel.offsetLeft + vessel.offsetWidth/2)
      mouseY = e.clientY - (vessel.offsetTop + vessel.offsetHeight/2)
      mouseX /= 5
      mouseY /= 5
    #update begin
    update = =>
      a = 0
      b = 0
      c = 0
      if active
        a = (-Math.min( Math.max( -mouseY, -@size ), @size ) / @radius ) * @tspeed
        b = (Math.min( Math.max( -mouseX, -@size ), @size ) / @radius ) * @tspeed
      else 
        a = @lasta * 0.98
        b = @lastb * 0.98
      @lasta = a
      @lastb = b
      if Math.abs(a) <= 0.01 &&  Math.abs(b) <= 0.01
        return false
      @sineCosine(a, b, c)
      max = @mcList.length
      for i in [0...max]
        rx1 = @mcList[i].cx
        ry1 = @mcList[i].cy*@ca + @mcList[i].cz*(-@sa)
        rz1 = @mcList[i].cy*@sa + @mcList[i].cz*@ca
        rx2 = rx1*@cb+rz1*@sb
        ry2 = ry1
        rz2 = rx1*(-@sb) + rz1*@cb
        rx3 = rx2*@cc + ry2*(-@sc)
        ry3 = rx2*@sc + ry2*@cc
        rz3 = rz2
        @mcList[i].cx = rx3
        @mcList[i].cy = ry3
        @mcList[i].cz = rz3
        per = @d/(@d+rz3)
        @mcList[i].x = rx3*per - 2
        @mcList[i].y = ry3*per
        @mcList[i].scale = per
        @mcList[i].alpha = (per-0.6) * 10/6;
      @doPosition()
      @depthSort()
    #update end
    setInterval(update, 30);
  doPosition: ->
    l = @vessel.offsetWidth/2
    t = @vessel.offsetHeight/2
    max = @mcList.length
    for i in [0...max]
      @fitEles[i].style.left = @mcList[i].cx + l - @mcList[i].offsetWidth/2 + 'px'
      @fitEles[i].style.top = @mcList[i].cy + t - @mcList[i].offsetHeight/2 + 'px'
      @fitEles[i].style.fontSize = Math.ceil(12*@mcList[i].scale/2) + 8 + 'px'
      @fitEles[i].style.filter = "alpha(opacity="+100*@mcList[i].alpha+")"
      @fitEles[i].style.opacity = @mcList[i].alpha
  depthSort: ->
    tmp = []
    l = @fitEles.length
    for i in [0...l]
      tmp.push @fitEles[i]
    tmp.sort (a, b)->
      if a.cz > b.cz
        return -1
      else if a.cz < b.cz
        return 1
      else
        return 0
    for i in [0...l]
      tmp[i].style.zIndex = i
    
  sineCosine: (a, b, c)->
    @sa = Math.sin(a * @dtr)
    @ca = Math.cos(a * @dtr)
    @sb = Math.sin(b * @dtr)
    @cb = Math.cos(b * @dtr)
    @sc = Math.sin(c * @dtr)
    @cc = Math.cos(c * @dtr)
  positionAll: ->
    phi = 0
    theta = 0
    max = @mcList.length
    fragment = document.createDocumentFragment();
    tmp = []
    for i in [0...@fitEleLength]
      tmp.push(@fitEles[i])
    tmp.sort ()-> #sort random
      Math.random() < 0.5 ? 1 : -1;
    for i in [0...@fitEleLength]
      fragment.appendChild(tmp[i])
    @vessel.appendChild(fragment); #append fitballs to vessel
    for i in [1...max+1]
      phi = Math.acos(-1+(2*i-1)/max)
      theta = Math.sqrt(max*Math.PI)*phi
      @mcList[i-1].cx = @radius * Math.cos(theta)*Math.sin(phi)
      @mcList[i-1].cy = @radius * Math.sin(theta)*Math.sin(phi)
      @mcList[i-1].cz = @radius * Math.cos(phi)
      @fitEles[i-1].style.left = @mcList[i-1].cs + @vessel.offsetWidth/2 - @mcList[i-1].offsetWidth/2 + 'px'
      @fitEles[i-1].style.top = @mcList[i-1].cy + @vessel.offsetHeight/2 - @mcList[i-1].offsetHeight/2 + 'px'

window.onload = ()->
  fb = new fitball
  fb.roll()