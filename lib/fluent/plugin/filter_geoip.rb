require 'geoip'
require 'lru_redux'
require 'fluent/plugin/filter'

module Fluent::Plugin
  class GeoipFilter < Filter
    Fluent::Plugin.register_filter('geoip', self)

    def initialize
      @geoip_cache = LruRedux::Cache.new(8192)
      super
    end

    config_param :database_path, :string, :default => File.dirname(__FILE__) + '/../../../data/GeoLiteCity.dat'
    config_param :key_name, :string, :default => 'client_ip'
    config_param :out_key, :string, :default => 'geo'
    config_param :flatten, :bool, :default => false

    def configure(conf)
      super
      begin
        @geoip = GeoIP.new(@database_path)
      rescue => e
        @geoip = GeoIP.new
        log.warn "Failed to configure parser. Use default pattern.", :error_class => e.class, :error => e.message
        log.warn_backtrace
      end
    end

    def filter(tag, time, record)
      ip_addr = record[@key_name]
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

  end
end
