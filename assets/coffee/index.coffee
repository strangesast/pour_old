class Icon
  constructor: (@canvas, radius = 100) ->
    @percentage = 0
    @set_radius(radius)
    @set_percentage(0, null, false)

  set_radius: (radius) ->
    @radius = Math.floor(radius/2)
    @canvas.width = 2*@radius
    @canvas.height = 2*@radius

  @requestId = 0
  @percentage = 0

  loading_bar: (percent) ->
    lw = 10
    rads = percent*2*Math.PI/100
    ctx = canvas.getContext('2d')
    r = @radius
    offset = -Math.PI/2
    ctx.beginPath()
    ctx.moveTo(r, r)
    ctx.arc r, r, r, offset, rads+offset, no
    ctx.lineTo(r, r)
    ctx.fillStyle = 'black'
    ctx.closePath()
    ctx.fill()
    ctx.beginPath()
    ctx.moveTo(r, r)
    ctx.arc r, r, r-lw, offset, Math.PI*2+offset, no
    ctx.lineTo(r, r)
    ctx.fillStyle = 'white'
    ctx.closePath()
    ctx.fill()
    ctx.font = "20px Verdana"
    ctx.fillStyle = 'black'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText("#{Math.floor(percent)}%", r, r-lw)
  set_percentage: (percent, time, anim=false) ->
    if percent != @percentage
      diff = percent - @percentage
      if anim
        @animate_loading_bar(@percentage, percent, if time? then time else diff*10)
      else
        @loading_bar(percent)
    @percentage = percent
  clear_percentage: ->
    ctx = @canvas.getContext('2d')
    ctx.clearRect 0, 0, @radius*2, @radius*2

  animate_loading_bar: (p1, p2, time) ->
    @clear_percentage()
    @loading_bar(p1)
    _this = @
    set_request_id = (id) ->
      _this.requestId = id
    if @requestId?
      @stop_animation()
    requestId = window.requestAnimationFrame(((start_time, time_length) ->
      draw = ->
        p = (Date.now() - start_time) / time_length
        _this.loading_bar.call(_this, p1 + p*(p2-p1))
        if p < 1 and requestId?
          requestId = window.requestAnimationFrame draw
          set_request_id(requestId)
    )(Date.now(), time))
  stop_animation: ->
    window.cancelAnimationFrame @requestId
    @requestId = null


class BeerIcon extends Icon
  #col1 = '#C04800'
  #col2 = '#D86000'
  #col3 = '#F79400'
  #col4 = '#D87800'
  [backCol, beerCol, foamCol, textCol] = [\
  'rgb(241,215,68)'
  'rgb(240,216,96)'
  'rgb(245,223,134)'
  'rgb(245,245,245)'
  ]
  #'rgb(231,202,85)'
  backCol = 'rgb(100, 100, 100)'

  loading_bar: (percent) ->
    p = percent / 100
    r = @radius
    h = 2*r
    pad = 0.1*h #padding
    mfh = 0.15*h #max foam height
    ctx = @canvas.getContext '2d'

    #clear = ->
    ctx.fillStyle = backCol
    ctx.fillRect(0, 0, h, h)
    #glass = ->
    ctx.fillStyle = 'rgba(0, 0, 0, 0.1)'
    ctx.fillRect(pad, pad, h-2*pad, h-2*pad)
    #beer = ->
    ctx.fillStyle = beerCol
    ctx.fillRect(pad, h - pad - (h- 2*pad-mfh)*p, h-2*pad, p*(h-2*pad-mfh))
    #foam = ->
    ctx.fillStyle = foamCol
    ctx.fillRect(pad, h - pad - (h- 2*pad)*p, h-2*pad, mfh*p)
    #sides = ->
    ctx.fillStyle = backCol
    ctx.beginPath()
    ctx.moveTo(0, 0)
    ctx.lineTo(0.5*r, 0)
    ctx.lineTo(0.6*r, h)
    ctx.lineTo(0, h)
    ctx.lineTo(0, 0)
    ctx.closePath()
    ctx.fill()
    ctx.beginPath()
    ctx.moveTo(h, 0)
    ctx.lineTo(h-0.5*r, 0)
    ctx.lineTo(h-0.6*r, h)
    ctx.lineTo(h, h)
    ctx.lineTo(h, 0)
    ctx.closePath()
    ctx.fill()
    #fill_text_of_color = (fsize, color) ->
    fsize = Math.max(Math.floor(h/10), 30)
    ctx.font = "#{fsize}px Verdana"
    ctx.fillStyle = textCol
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    text = "#{Math.floor(percent)}%"
    ctx.fillText(text, r, r)
    


makeRequest = (url, method, data, progress_listener) ->
  return new Promise (resolve, reject) ->
    request = new XMLHttpRequest()
    request.open(method, url, true)
    if method != "GET"
      request.setRequestHeader('Content-Type', 'application/json')
    request.onload = ->
      if request.status >= 200 and request.status < 400
        try
          # json
          data = JSON.parse(request.responseText)
        catch
          # probably not json
          data = request.responseText
        return resolve(data)
      else
        return reject("request failed")

    request.onerror = ->
      reject("request failed")

    request.addEventListener("progress", progress_listener)
    if data
      request.send JSON.stringify data
    else
      request.send()

loading_canvas = document.getElementById('loading-canvas')
canvas = document.getElementById('test-canvas')
pour_button = document.getElementById 'pour'
pour_output = document.getElementById 'pour-output'
pour_input = document.getElementById 'pour-input'
pour_progress = document.getElementById 'pour-progress'
icon = new Icon(loading_canvas, 100)

beericon = new BeerIcon canvas, 500
beericon.set_percentage 100, 5000, true

pour_button.addEventListener 'click', (e) ->
  val = pour_input.value
  console.log val
  console.log val == "" or not isNaN(val)
  if val == "" or isNaN(val)
    return
  makeRequest('/pour', 'POST', amount: val, null).then (response) ->
    icon.clear_percentage()
    if 'error' of response
      console.log "ERROR"
      console.log response.error
      return Promise.reject(response.error)
    return response['socket_url']
  .then (rel_url) ->
    console.log rel_url
    socket_addr = 'ws://' + document.URL.split('://')[1] + rel_url
    console.log socket_addr
    socket = new WebSocket socket_addr
    console.log "socket"
    console.log socket
    socket.onmessage = (event) ->
      console.log 'message'
      data = event.data
      console.log data
        
      #data = JSON.parse(event.data)
      #a = data.all
      #[ticks, time] = a.split(':')[1].trim().split(' ')
      #if data.update
      #  pour_progress.setAttribute 'value', "#{ticks/val*100}"
      #  perc = ticks / val* 100
      #  icon.set_percentage(perc, null, false)
      #  beericon.set_percentage(perc, null, false)
      #pour_output.textContent = a
