http = require 'http'
express = require 'express'
router = express.Router()
Account = require '../../models/account'
passport = require 'passport'
#net = require 'net'
#server = http.createServer()
#WebSocketServer = require('ws').Server
#wss = new WebSocketServer server: server, path: '/pourlive'
#server.listen(3002)

router.get '/pour', (req, res) ->
  res.render 'pour', user: req.user

router.get '/test', (req, res) ->
  res.render 'test', user: req.user

router.get '/', (req, res, next) ->
  # get pour history
  #   last temps
  #   last pour
  # get recent users
  ob =
    user: req.user
    summary:
      avg_temp: '20F'
      total_dispensed: '20oz'
    drinkers: [
      'Tom Harvey'
      'George Costanza'
    ]
  res.render 'index', ob

router.get '/register', (req, res) ->
  if req.user
    return res.redirect '/user/' + req.user.username
  res.render 'register'

router.post '/register', (req, res) ->
  new_account = new Account(username: req.body.username)
  password = req.body.password
  Account.register(new_account, password, (err, account) ->
    if err
      return res.render 'register', account : account, err: err
    passport.authenticate('local')(req, res, ->
      res.redirect('/')
    )
  )

router.get '/login', (req, res) ->
  if req.user
    return res.redirect '/user/' + req.user.username
  res.render 'login', user : req.user

router.post '/login', passport.authenticate('local'), (req, res) ->
  res.redirect('/')

router.get '/logout', (req, res) ->
  req.logout()
  res.redirect('/')


router.get '/user/:account_name', (req, res) ->
  # user is logged in
  if req.user and req.user.username == req.params.account_name
    return res.render 'current_user', {user: req.user, account_name: req.params.account_name}

  # is not logged in
  else
    res.render 'other_user', {user: req.user, account_name: req.params.account_name}

router.all '/pour', (req, res) ->
  user = req.user
  #if not user
  #  return res.json error: "not logged in"

  body = req.body
  if 'amount' of body
    amount = body.amount
    #wss.on 'connection', (ws) ->
    #  client = new net.Socket()
    #  client.on 'data', (data) ->
    #    clean = data.toString().split('\r\n')[0]
    #    update = clean.indexOf('update') > -1
    #    end = clean.indexOf('end') > -1
    #    start = clean.indexOf('start') > -1

    #    ws.send(JSON.stringify(start: start, update: update, end: end, all: clean))

    #  client.on 'close', ->
    #    console.log 'client closed'

    #  client.connect 3001, '127.0.0.1', ->
    #    setTimeout ->
    #      console.log "writing to serial server"
    #      client.write(amount + '\n')
    #    , 500

    res.send socket_url: 'pourlive'

  else
    res.send socket_url: 'pourlive'
    #res.send body: body, user: user

module.exports = router
