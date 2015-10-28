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

pour_button = document.getElementById 'pour'
pour_output = document.getElementById 'pour-output'
pour_input = document.getElementById 'pour-input'
pour_progress = document.getElementById 'pour-progress'

pour_button.addEventListener 'click', (e) ->
  val = pour_input.value
  console.log val
  console.log val == "" or not isNaN(val)
  if val == "" or isNaN(val)
    return
  makeRequest('/pour', 'POST', amount: val, null).then (response) ->
    if 'error' of response
      console.log "ERROR"
      console.log response.error
      return Promise.reject(response.error)
    return response['socket_url']
  .then (socket_addr) ->
    console.log socket_addr
    socket = new WebSocket socket_addr
    console.log "socket"
    console.log socket
    socket.onmessage = (event) ->
      data = JSON.parse(event.data)
      a = data.all
      [ticks, time] = a.split(':')[1].trim().split(' ')
      if data.update
        pour_progress.setAttribute 'value', "#{ticks/val*100}"
      pour_output.textContent = a
