# fluent-plugin-geoip-filter

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-geoip-filter.svg)](https://badge.fury.io/rb/fluent-plugin-geoip-filter)
[![Build Status](https://travis-ci.org/bungoume/fluent-plugin-geoip-filter.svg?branch=master)](https://travis-ci.org/bungoume/fluent-plugin-geoip-filter)
[![Dependency Status](https://gemnasium.com/bungoume/fluent-plugin-geoip-filter.svg)](https://gemnasium.com/bungoume/fluent-plugin-geoip-filter)

[Fluentd](http://fluentd.org) filter plugin to geolocate.


## Installation

```bash
# for fluentd
$ gem install fluent-plugin-geoip-filter

# for td-agent2
$ sudo td-agent-gem install fluent-plugin-geoip-filter
```


## Usage

### Example 1:

```xml
<filter access.nginx.**>
  @type geoip
</filter>
```

Assuming following inputs are coming:

```json
access.nginx: {
  "client_ip":"93.184.216.34",
  "scheme":"http", "method":"GET", "host":"example.com",
  "path":"/", "query":"-", "req_bytes":200, "referer":"-",
  "status":200, "res_bytes":800, "res_body_bytes":600, "taken_time":0.001, "user_agent":"Mozilla/5.0"
}
```

then output bocomes as belows:

```json
access.nginx: {
  "client_ip":"93.184.216.34",
  "scheme":"http", "method":"GET", "host":"example.com",
  "path":"/", "query":"-", "req_bytes":200, "referer":"-",
  "status":200, "res_bytes":800, "res_body_bytes":600, "taken_time":0.001, "user_agent":"Mozilla/5.0",
  "geo": {
    "coordinates": [-70.8228, 42.1508],
    "country_code": "US",
    "city": "Norwell",
    "region_code": "Massachusetts",
  }
}
```


## Parameters
- key_name *field_key*

    Target key name. default client_ip.

- out_key *string*

    Output prefix key name. default geo.

- database_path *file_path*

    Database file(GeoIPCity.dat) path.
    Get from [MaxMind](http://dev.maxmind.com/geoip/legacy/geolite/)

- flatten *bool*
    join hashed data by '_'. default false.


## TODO

* patches welcome!


## Contributing

1. Fork it ( https://github.com/bungoume/fluent-plugin-geoip-filter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Copyright

Copyright (c) 2015 Yuri Umezaki


## License

[Apache License, Version 2.0.](http://www.apache.org/licenses/LICENSE-2.0)
