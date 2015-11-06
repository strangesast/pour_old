mongoose = require 'mongoose'
Schema = mongoose.Schema

Pour = new Schema(
  startTime:
    type: Date
  endTime:
    type: Date
    default: Date.now
  totalTics: Number
  totalTime: Number
  username:
    type: ObjectId
    ref: 'Account'
)

module.exports = mongoose.model 'Pour', Pour
