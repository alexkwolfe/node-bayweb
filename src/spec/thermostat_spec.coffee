assert = require('chai').assert
Thermostat = require('../thermostat')
nock = require('nock')

describe 'Checkstream', ->
  beforeEach ->
    @nock = nock('https://api.bayweb.com:443')
              .defaultReplyHeaders
                'server': 'Apache/2.2.17 (Ubuntu)'
                'x-powered-by': 'PHP/5.3.5-1ubuntu7.2'
                'keep-alive': 'timeout=15, max=100'
                'connection': 'Keep-Alive'
                'content-type': 'application/json'
    @stat = new Thermostat('12345', 'ABCDE')

  it 'should fetch', (done) ->
    res = timestamp:1368285744, iat:74, iah:0, act:1, mode:2, sp:78, act_sp:78, hold:0, fan:1, oat:73, oah:64, wind:11, solar:24, door:0, relay_w2:0, relay_y2:0, in1:74, in2:1, in3:-32768
    @nock.get('/v2/?action=data&id=12345&key=ABCDE').reply(200, "\n#{JSON.stringify(res)}")

    @stat.fetch (err) =>
      data = @stat.data
      assert.equal @stat.activity, 'away 1'
      assert.equal @stat.setPoint, 78
      assert.equal @stat.mode, 'cool'
      assert.equal @stat.fan, 'on'
      assert.isFalse @stat.hold

      assert.equal data.insideTemp, 74
      assert.equal data.insideHum, 0
      assert.equal data.activitySetPoint, 78
      assert.equal data.outsideTemp, 73
      assert.equal data.outsideHum, 64
      assert.equal data.windMph, 11
      assert.equal data.solarIndex, 24
      assert.isFalse data.doorOpen, false
      assert.equal data.relay1, false
      assert.equal data.relay2, false
      assert.equal data.input1, 74
      assert.equal data.input2, true
      assert.equal data.input3, null
      assert.deepEqual data.updatedAt, new Date(res.timestamp * 1000)
      done(err)


  activities = [ 'occupied', 'away 1', 'away 2', 'sleep' ]
  for activity, index in activities
    ( (i, activity) =>
      it "should set activity to #{activity}", (done) ->
        @nock.get("/v2/?action=set&act=#{i}&id=12345&key=ABCDE").reply(200, "\n{\"act\":\"#{i}\"}")
        @stat.activity = activity
        @stat.save(done)
    )(index, activity)


  modes = [ 'off', 'heat', 'cool']
  for mode, index in modes
    ( (i, m) =>
      it "should set mode to #{mode}", (done) ->
        @nock.get("/v2/?action=set&mode=#{i}&id=12345&key=ABCDE").reply(200, "\n{\"act\":\"#{i}\"}")
        @stat.mode = m
        @stat.save(done)
    )(index, mode)


  holds = [ false, true ]
  for hold, index in holds
    ( (i, h) =>
      it "should turn hold #{if h then 'on' else 'off'}", (done) ->
        @nock.get("/v2/?action=set&hold=#{i}&id=12345&key=ABCDE").reply(200, "\n{\"act\":\"#{i}\"}")
        @stat.hold = h
        @stat.save(done)
    )(index, hold)

  fans = [ 'auto', 'on' ]
  for fan, index in fans
    ( (i, f) =>
      it "should set fan to #{f}", (done) ->
        @nock.get("/v2/?action=set&fan=#{i}&id=12345&key=ABCDE").reply(200, "\n{\"act\":\"#{i}\"}")
        @stat.fan = f
        @stat.save(done)
    )(index, fan)



