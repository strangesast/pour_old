app = require '../app'
url = require 'url'
debug = require('debug')('app:server')
http = require 'http'
WebSocketServer = require('ws').Server
cookieParser = require('cookie-parser')('the most toast')
util = require 'util'
net = require 'net'


normalizePort = (val) ->
  port = parseInt val, 10

  if isNaN port
    return val

  if port >= 0
    return port

  return false


onError = (error) ->
  unless error.syscall is 'listen'
    throw error

  bind = if typeof port is 'string'
  then 'Pipe ' + port
  else 'Port ' + port

  switch error.code
    when 'EACCES'
      console.error bind + ' requires elevated privileges'
      process.exit 1
      break

    when 'EADDRINUSE'
      console.error bind + ' is already in use'
      process.exit 1
      break

    else
      throw error

onListening = ->
  addr = server.address()

  bind = if typeof addr is 'string'
  then 'pipe ' + addr
  else 'port ' + addr.port

  debug 'Listening on ' + bind


port = normalizePort process.env.PORT || '3000'
app.set 'port', port

server = http.createServer app

wss = new WebSocketServer server: server, path: '/pourlive'

wss.on 'connection', (ws) ->
  console.log 'connection'

  location = url.parse ws.upgradeReq.url, true

  cookieParser ws.upgradeReq, null, (err) ->
    if err
      return console.log "ERR"
    cookies = ws.upgradeReq.signedCookies
    cookie = cookies['connect.sid']
    console.log "cookie: #{cookie}"
    #ws.send JSON.stringify keys: Object.keys(ws.upgradeReq), secret: ws.upgradeReq.signedCookies

    ws.on 'message', (message, flags) ->
      message = JSON.parse message
      ws.send JSON.stringify message: message

      amount = message.pour_amount
      ws.send JSON.stringify amount: amount
      if 'pour_amount' of message and not isNaN(amount)
        
        client = new net.Socket()
  
        client.on 'data', (data) ->
          clean = data.toString().split('\r\n')[0]
          update = clean.indexOf('update') > -1
          end = clean.indexOf('end') > -1
          start = clean.indexOf('start') > -1
          summary_object =
            start: start
            end: end
            all: clean

          if update
            if clean.indexOf 'flow' > -1
              [currflow, currtime] = clean.split('update-flow:').slice(-1)[0].trim().split(' ')
              summary_object.update =
                current: Number(currflow)
                total: Number(amount)
                time: Number(currtime)

          ws.send(JSON.stringify(summary_object))
  
        client.on 'close', ->
          console.log 'client closed'
  
        client.connect 3001, '127.0.0.1', ->
          setTimeout ->
            console.log "writing to serial server"
            client.write(amount + '\n')
          , 500
  
        ws.onclose = (event) ->
          client.destroy()
          console.log "socket destroyed"

  
  ws.on 'close', ->
    console.log 'disconnected'


server.listen port
server.on 'error', onError
server.on 'listening', onListening
