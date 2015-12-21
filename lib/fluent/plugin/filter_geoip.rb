require 'geoip'
require 'lru_redux'

module Fluent
  class GeoipFilter < Filter
    Plugin.register_filter('geoip', self)

    def initialize
      @geoip_cache = LruRedux::Cache.new(10000)
      super
    end

    config_param :database_path, :string, :default => '/usr/share/GeoIP/GeoIP.dat'
    config_param :key_name, :string, :default => 'client_ip'
    config_param :out_key, :string, :default => 'geo'
    config_param :flatten, :bool, :default => false

    def configure(conf)
      @geoip = GeoIP.new(@geoip_database)
      super
    end

    def filter(tag, time, record)
      ip_addr = record[@geoip_lookup_key]
      unless ip_addr.nil?
        geo_ip = @geoip_cache.getset(ip_addr) { get_geoip(ip_addr) }
        if flatten
          record.merge! hash_flatten(geo_ip, [@out_key])
        else
          record[@out_key] = geo_ip
        end
      end
      record
    end

    private

    def get_geoip(ip_addr)
      geo_ip = @geoip.city(ip_addr)
      data = {}
      return data if geo_ip.nil?
      data["coordinates"] = [geo_ip["longitude"], geo_ip["latitude"]]
      data["country_code"] = geo_ip["country_code2"]
      data["city"] = geo_ip["city_name"]
      data["region_code"] = geo_ip["region_name"]
      data
    end

    def hash_flatten(a, keys=[])
      ret = {}
      a.each{|k,v|
        ks = keys + [k]
        if v.class == Hash
          ret.merge!(hash_flatten(v, ks))
        else
          ret.merge!({ks.join('_')=> v})
        end
      }
      ret
    end

  end if defined?(Filter) # Support only >= v0.12
end
