require_relative 'helper'
require 'fluent/plugin/filter_geoip'

# setup
Fluent::Test.setup
config = %[
  @type geoip
  out_key geo
]
time = Time.now.to_i
tag = 'foo.bar'
driver = Fluent::Test::FilterTestDriver.new(Fluent::GeoipFilter, tag).configure(config, true)

# bench
require 'benchmark'
require 'ipaddr'
n = 100000
Benchmark.bm(7) do |x|
  x.report { driver.run { n.times { driver.emit({'client_ip' => IPAddr.new(rand(2**13)*2**19,Socket::AF_INET).to_s }, time) } } }
end
