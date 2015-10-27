should = require 'should'
mongoose = require 'mongoose'
Account = require "../models/account"
db = null

describe 'Account', ->
  before((done) ->
   db = mongoose.connect('mongodb://127.0.0.1/test')
   done()
  )

  after((done) ->
     mongoose.connection.close()
     done()
  )

  beforeEach((done) ->
    account = new Account(
      username: '12345'
      password: 'testy'
    )
  
    account.save((error) ->
      if (error)
        console.log('error' + error.message)
      else
        console.log('no error')
      done()
    )
  )
  
  it 'find a user by username', (done) ->
    Account.findOne(username: '12345', (err, account) ->
      account.username.should.eql '12345'
      console.log "   username: ", account.username
      done()
    )

  afterEach (done) ->
    Account.remove({}, ->
      done()
    )
