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
    ip_iddr = '93.184.216.34'

    d1.run do
      d1.emit({'client_ip' => ip_iddr})
    end
    emits = d1.emits
    assert_equal 1, emits.length
    assert_equal 'test', emits[0][0] # tag
    geo_object = emits[0][2]['geo']
    assert_equal [-70.8228, 42.150800000000004], geo_object['coordinates']
    assert_equal 'US', geo_object['country_code']
    assert_equal 'Norwell', geo_object['city']
    assert_equal 'MA', geo_object['region_code']
  end

end
