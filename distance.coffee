#!/usr/bin/coffee
readline = require 'readline'
events = require 'events'

Puppy = (name, timeout) ->
  this.name = name
  this.last_seen = undefined
  this.leave_fn = -> console.log 'GONE'
  this.timeout = timeout || 4000
  this.timer = setTimeout this.leave_fn, this.timeout
  return this

Puppy::seen = ->
  this.last_seen = Date.now()
  clearTimeout this.timer
  this.timer = setTimeout this.leave_fn, this.timeout

calc_accuracy = (power, rssi) ->
  ratio = rssi / power

  if ratio < 1
    return Math.pow(ratio, 10)
  else
    return (0.89976) * Math.pow(ratio, 7.7095) + 0.111


izzy = new Puppy('Izzy', 4000)

rl = readline.createInterface
  input: process.stdin,
  output: process.stdout

rl.on 'line', (line) ->
  izzy.seen()

  out = line.split(' ')
  # "$UUID $MAJOR $MINOR $POWER $RSSI"
  point =
    uid: out[0]
    major: out[1]
    minor: out[2]
    power: out[3]
    rssi: out[4]
    received: new Date()

  point.accuracy = calc_accuracy(point.power, point.rssi)


  console.log (point.received / 1000), Math.ceil(point.accuracy)

# ./ibeacon_scan -b | ./distance.coffee | feedgnuplot --stream --domain --lines --timefmt '%s' --set 'format x "%H:%M:%S"'

# ./ibeacon_scan -b | ./distance.coffee | feedgnuplot --lines --points --legend 0 "data 0" --title "Test plot" --y2 1 --terminal 'dumb 120,60' --exit --stream 1
