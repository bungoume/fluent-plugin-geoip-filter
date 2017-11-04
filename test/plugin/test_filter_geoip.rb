require 'helper'

class GeoipFilterTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    @type geoip
    key_name client_ip
    out_key geo
  ]

  def create_driver(conf=CONFIG)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::GeoipFilter).configure(conf)
  end

  def test_configure
    d = create_driver(CONFIG)
    assert_equal 'client_ip', d.instance.config['key_name']
    assert_equal 'geo', d.instance.config['out_key']
  end

  def test_emit
    d1 = create_driver(CONFIG)
    ip_iddr = '93.184.216.34'

    d1.run(default_tag: 'test') do
      d1.feed({'client_ip' => ip_iddr})
    end
    emits = d1.filtered
    assert_equal 1, emits.length
    geo_object = emits[0][1]['geo']
    assert_equal [-70.8228, 42.150800000000004], geo_object['coordinates']
    assert_equal 'US', geo_object['country_code']
    assert_equal 'Norwell', geo_object['city']
    assert_equal 'MA', geo_object['region_code']
  end

  def test_emit_flatten
    d1 = create_driver(%[
      @type geoip
      key_name ip_iddr
      flatten
    ])
    ip_iddr = '93.184.216.34'

    d1.run(default_tag: 'test') do
      d1.feed({'ip_iddr' => ip_iddr})
    end

    emits = d1.filtered
    assert_equal 1, emits.length
    geo_object = emits[0][1]
    assert_equal [-70.8228, 42.150800000000004], geo_object['geo_coordinates']
    assert_equal 'US', geo_object['geo_country_code']
    assert_equal 'Norwell', geo_object['geo_city']
    assert_equal 'MA', geo_object['geo_region_code']
  end

end
