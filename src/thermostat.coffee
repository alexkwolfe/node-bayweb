request = require 'request'

class Thermostat

  @baseUrl = 'https://api.bayweb.com/v2/'

  ###
  Public: Instantiate a new Thermostat

  id: The thermostat identifier (from the API section of the BAYWeb Cloud EMS
  key: The API key for the thermostat (also from the API section of the BAYWeb Cloud EMS)
  cb: Optional callback. If specified, the Thermostat data will be immediately fetched and
      the callback invoked on success or error

  Returns nothing
  ###
  constructor: (@id, @key, cb) ->
    @data = {}
    @fetch cb if cb

  fetch: (cb) ->
    @req { action: 'data' }, (err, data) =>
      cb(err) if err and cb
      @activity = switch data.act
        when 0 then 'occupied'
        when 1 then 'away 1'
        when 2 then 'away 2'
        when 3 then 'sleep'
      @mode = switch data.mode
        when 0 then 'off'
        when 1 then 'heat'
        when 2 then 'cool'
      @setPoint = data.sp
      @hold = !!data.hold
      @fan = switch data.fan
        when 0 then 'auto'
        when 1 then 'on'
      @data =
        insideTemp: data.iat
        insideHum: data.iah
        activitySetPoint: data.act_sp
        outsideTemp: data.oat
        outsideHum: data.oah
        windMph: data.wind
        solarIndex: data.solar
        doorOpen: !!data.door
        relay1: !!data.relay_w2
        relay2: !!data.relay_y2
        input1: if data.in1 < 0 then null else if data.in1 <= 1 then !!data.in1 else data.in1
        input2: if data.in2 < 0 then null else if data.in2 <= 1 then !!data.in2 else data.in2
        input3: if data.in3 < 0 then null else if data.in3 <= 1 then !!data.in3 else data.in3
        updatedAt: new Date(data.timestamp * 1000)
      cb() if cb
    @

  ###
  Public: Save thermostat settings.

  The following properties are mutable and can be saved:
    * activity - 'occupied', 'away 1', 'away 2', or 'sleep'
    * mode - 'off', 'heat', or 'cool'
    * hold - true or false
    * fan - 'auto' or 'on'
    * setPoint - integer value of the currently desired set point

  cb: Optional callback. If specified, the callback will be invoked with two parameters. The first is an
      error if one occurred, otherwise null. The second is the BAYWeb server response.

  Returns nothing
  ###
  save: (cb) ->
    options =
      action: 'set'
      act: switch @activity
        when 'occupied' then 0
        when 'away 1' then 1
        when 'away 2' then 2
        when 'sleep' then 3
      mode: switch @mode
        when 'off' then 0
        when 'heat' then 1
        when 'cool' then 2
      hold: switch @hold
        when false then 0
        when true then 1
      fan: switch @fan
        when 'auto' then 0
        when 'on' then 1

    if @setPoint != @data.activitySetPoint
      if @mode == 'heat'
        options.heat_sp = @setPoint
      else if @mode == 'cool'
        options.cool_sp = @setPoint

    @req options, cb
    @


  ###
  Private: Make the HTTP request to the BAYWeb service and parse the JSON response body to an object.

  params: The parameters to pass. ID and Key are merged into these params.
  cb: The callback to invoke when the request has completed (or errored).

  Returns nothing
  ###
  req: (params, cb) ->
    params.id = @id
    params.key = @key
    for own key, value of params
      delete params[key] unless value?
    request Thermostat.baseUrl, { method: 'get', qs: params, strictSSL: false }, (err, res, body) ->
      if cb
        return cb(err) if err
        cb(null, JSON.parse(body))

module.exports = Thermostat