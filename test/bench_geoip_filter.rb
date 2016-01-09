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
  # 8192 random IP
  x.report { driver.run { n.times { driver.emit({'client_ip' => IPAddr.new(rand(2**13)*2**19,Socket::AF_INET).to_s }, time) } } }
end


# Without LRU cache
#              user     system      total        real
#         11.410000   2.730000  14.140000 ( 15.431248)
# With LRU cache(8192) & random  1024 IP
#              user     system      total        real
#          1.250000   0.070000   1.320000 (  1.322339)
# With LRU cache(8192) & random  8192 IP
#              user     system      total        real
#          1.890000   0.210000   2.100000 (  2.102445)
# With LRU cache(8192) & random 16384 IP
#              user     system      total        real
#          8.450000   2.070000  10.520000 ( 12.170379)
# With LRU cache(8192) & random 65536 IP
#              user     system      total        real
#         11.890000   2.820000  14.710000 ( 16.051674)

# fluent-plugin-geoip
# (https://github.com/y-ken/fluent-plugin-geoip)
#              user     system      total        real
#         11.540000   0.270000  11.810000 ( 12.685000)

