express = require 'express'
router = express.Router()
Account = require '../../models/account'
passport = require 'passport'

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

router.get '/login', (req, res, next) ->
  res.render 'login'

router.get '/register', (req, res) ->
  res.render 'register', {}

router.post '/register', (req, res) ->
  new_account = new Account(username: req.body.username)
  password = req.body.password
  Account.register(new_account, password, (err, account) ->
    if err
      return res.render 'register', account : account
    passport.authenticate('local')(req, res, ->
      res.redirect('/')
    )
  )

router.get '/login', (req, res) ->
  res.render 'login', user : req.user

router.post '/login', passport.authenticate('local'), (req, res) ->
  res.redirect('/')

router.get '/logout', (req, res) ->
  req.logout()
  res.redirect('/')

module.exports = router
