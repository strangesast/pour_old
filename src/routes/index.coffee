express = require 'express'
router = express.Router()
SerialPort = require('serialport').SerialPort


router.get '/', (req, res, next) ->
  ob =
    summary:
      avg_temp: '20F'
      total_dispensed: '20oz'
    drinkers: [
      'Tom Harvey'
      'George Costanza'
    ]

  res.render 'index', ob
  return

module.exports = router
