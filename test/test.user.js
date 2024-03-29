// Generated by CoffeeScript 1.9.3
(function() {
  var Account, db, mongoose, should;

  should = require('should');

  mongoose = require('mongoose');

  Account = require("../models/account");

  db = null;

  describe('Account', function() {
    before(function(done) {
      db = mongoose.connect('mongodb://127.0.0.1/test');
      return done();
    });
    after(function(done) {
      mongoose.connection.close();
      return done();
    });
    beforeEach(function(done) {
      var account;
      account = new Account({
        username: '12345',
        password: 'testy'
      });
      return account.save(function(error) {
        if (error) {
          console.log('error' + error.message);
        } else {
          console.log('no error');
        }
        return done();
      });
    });
    it('find a user by username', function(done) {
      return Account.findOne({
        username: '12345'
      }, function(err, account) {
        account.username.should.eql('12345');
        console.log("   username: ", account.username);
        return done();
      });
    });
    return afterEach(function(done) {
      return Account.remove({}, function() {
        return done();
      });
    });
  });

}).call(this);
