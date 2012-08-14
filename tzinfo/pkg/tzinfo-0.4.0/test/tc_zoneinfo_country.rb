=begin
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'test/unit'
require File.join(File.dirname(__FILE__), 'test_utils')
require 'tzinfo/country'
require 'tzinfo/zoneinfo_timezone_info'
require 'tzinfo/zoneinfo_indexes'

include TZInfo

class TCZoneinfoCountry < Test::Unit::TestCase

  def test_get_valid
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    c = Country.get('GB')
    
    assert c
    assert_equal('GB', c.code)
  end
    
  def test_get_not_exist
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_raises(InvalidCountryCode) {
      Country.get('ZZ')
    }
  end
  
  def test_get_invalid
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_raises(InvalidCountryCode) {
      Country.get('../Countries/GB')
    }
  end
  
  def test_get_nil
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_raises(InvalidCountryCode) {
      Country.get(nil)
    }
  end
  
  def test_get_case    
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_raises(InvalidCountryCode) {
      Country.get('gb')
    }
  end
    
  def test_new_nil
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_raises(InvalidCountryCode) {
      c = Country.new(nil)
    }        
  end
  
  def test_new_arg
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    c = Country.new('GB')
    assert_same(Country.get('GB'), c)    
  end
  
  def test_new_arg_not_exist    
    assert_raises(InvalidCountryCode) {
      Country.new('ZZ')
    }
  end 
  
  def test_all_codes
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    all_codes = Country.all_codes
    assert_kind_of(Array, all_codes)
  end
  
  def test_all
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    all = Country.all    
    assert_equal(Country.all_codes, all.collect {|c| c.code})
  end
  
  def test_code    
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_equal('US', Country.get('US').code)
  end
  
  def test_name
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_kind_of(String, Country.get('US').name)
  end
  
  def test_to_s
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_equal(Country.get('US').name, Country.get('US').to_s)
    assert_equal(Country.get('GB').name, Country.get('GB').to_s)
  end
  
  def test_zone_identifiers
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    zone_names = Country.get('US').zone_names
    assert_kind_of(Array, zone_names)
    assert_equal(true, zone_names.frozen?)    
  end
  
  def test_zone_names
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_equal(Country.get('US').zone_identifiers, Country.get('US').zone_names)
  end
  
  def test_zones
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    zones = Country.get('US').zones
    assert_kind_of(Array, zones)    
    assert_equal(Country.get('US').zone_identifiers, zones.collect {|z| z.identifier})
    
    zones.each {|z| assert_kind_of(TimezoneProxy, z)}
  end
  
  def test_zone_info
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    zones = Country.get('US').zone_info
    assert_kind_of(Array, zones)
    assert_equal(true, zones.frozen?)
    
    assert_equal(Country.get('US').zone_identifiers, zones.collect {|z| z.identifier})
    assert_equal(Country.get('US').zone_identifiers, zones.collect {|z| z.timezone.identifier})
    
    zones.each {|z| assert_kind_of(CountryTimezone, z)}
  end  
      
  def test_compare
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_equal(0, Country.get('GB') <=> Country.get('GB'))
    assert_equal(-1, Country.get('GB') <=> Country.get('US'))
    assert_equal(1, Country.get('US') <=> Country.get('GB'))
    assert_equal(-1, Country.get('FR') <=> Country.get('US'))
    assert_equal(1, Country.get('US') <=> Country.get('FR'))
  end
  
  def test_equality
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_equal(true, Country.get('GB') == Country.get('GB'))
    assert_equal(false, Country.get('GB') == Country.get('US'))
    assert(!(Country.get('GB') == Object.new))
  end
  
  def test_eql
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_equal(true, Country.get('GB').eql?(Country.get('GB')))
    assert_equal(false, Country.get('GB').eql?(Country.get('US')))
    assert(!Country.get('GB').eql?(Object.new))
  end
  
  def test_hash
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    assert_equal('GB'.hash, Country.get('GB').hash)
    assert_equal('US'.hash, Country.get('US').hash)
  end
  
  def test_marshal
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    c = Country.get('US')
    
    # Should get back the same instance because load calls Country.get.
    assert_same(c, Marshal.load(Marshal.dump(c)))
  end
  
  def test_reload
    #TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir = nil
    # If country gets reloaded for some reason, it needs to force a reload of
    # the country index.
    
    c = Country.get('US')
    assert_equal('US', Country.get('US').code)

    # Suppress redefined method warnings.
    without_warnings do
      load 'tzinfo/country.rb'
    end
    
    c = Country.get('US')
    assert_equal('US', Country.get('US').code)
  end
end
=end