require 'helper'

class GeoipFilterTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    type geoip
    key_name client_ip
    out_key geo
  ]

  def create_driver(conf=CONFIG,tag='test')
    Fluent::Test::FilterTestDriver.new(Fluent::GeoipFilter, tag).configure(conf)
  end

  def test_configure
    d = create_driver(CONFIG)
    assert_equal 'client_ip', d.instance.config['key_name']
    assert_equal 'geo', d.instance.config['out_key']
  end

  def test_emit
    d1 = create_driver(CONFIG)
  end

end
