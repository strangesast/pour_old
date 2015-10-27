(function() {
  var Account, Schema, mongoose, passportLocalMongoose;

  mongoose = require('mongoose');

  Schema = mongoose.Schema;

  passportLocalMongoose = require('passport-local-mongoose');

  Account = new Schema({
    username: String,
    password: String
  });

  Account.plugin(passportLocalMongoose);

  module.exports = mongoose.model('Account', Account);

}).call(this);
