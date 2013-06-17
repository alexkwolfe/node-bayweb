A node.js client for controlling BAYWeb Internet thermostats.

[![Build Status](https://secure.travis-ci.org/alexkwolfe/node-bayweb.png)](http://travis-ci.org/alexkwolfe/node-bayweb)


## Usage

Simply create a new Thermostat using the ID and Key from your BAYWeb Cloud EMS account. The callback is optional. 
If you provide one, then the thermostat data will be immediately fetched from Cloud EMS.

```javascript
var Thermostat = require('bayweb');

var stat = new Thermostat('ID', 'APIKEY', function(err) {
  if (err)
    console.log('Error fetching data from BAYWeb server: ' + err);
  else
    console.log('Loaded data from BAYWeb server!');
});
```

Once data is fetched, you can access the following properties...

```javascript
stat.insideTemp;       // integer indoor temperature
stat.insideHum;        // integer humidity reading
stat.activitySetPoint; // integer set point of current activity
stat.outsideTemp;      // integer outdoor temperature (provided by outdoor sensor or Cloud EMS)
stat.outsideHum;       // integer outdoor humidity (provided by Cloud EMS)
stat.windMph;          // integer wind speed (provided by Cloud EMS)
stat.solarIndex;       // integer solar index (provided by Cloud EMS)
stat.doorOpen;         // boolean is the door open?
stat.relay1;           // boolean is relay 1 (w2) open?
stat.relay2;           // boolean is relay 2 (y2) open?
stat.input1;           // if digital, boolean is input open? otherwise, integer temperature
stat.input2;           // if digital, boolean is input open? otherwise, integer temperature
stat.input3;           // if digital, boolean is input open? otherwise, integer temperature
```

In addition, the following properties can be accessed and modified...

```javascript
stat.activity;         // string 'occupied', 'away 1', 'away 2', or 'sleep'
stat.mode;             // string 'off', 'heat', or 'cool'
stat.hold;             // boolean true to hold temperature
stat.fan;              // string 'auto' or 'on'
stat.setPoint;         // integer value of the desired temperature set point
```

Make changes and save them to Cloud EMS...

```javascript
// set thermostat
stat.mode = 'cool';
stat.activity = 'occupied';
stat.setPoint = 76;

// save settings
stat.save(function(err) {
  if (err)
    return console.err(err)
  console.log('Saved!');
});
```

Refresh data from Cloud EMS...

```javascript
stat.fetch(function(err) {
  if (err)
    console.log('Error fetching thermostat data: ' + err);
  else
    console.log('Thermostat data fetched successfully');
});
```
