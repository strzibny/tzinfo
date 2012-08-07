#--
# Copyright (c) 2008 Philip Ross
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#++

module TZInfo
  class ZoneinfoIndexes

    @@zoneinfo_loaded = false
  
    def initialize()
      if TZInfo::ZoneinfoTimezoneInfo.zoneinfo_present? and not @@zoneinfo_loaded
      @@zoneinfo_loaded = true
      puts 'loads'
      @zones = {}
      @countries = {}
      @timezones = []
      @input_dir = TZInfo::ZoneinfoTimezoneInfo.zoneinfo_dir
 
      Dir.foreach(@input_dir) {|file|
        if File.directory?(@input_dir + File::SEPARATOR + file)
          @timezones_dirs = ['Africa','America', 'Antarctica','Arctic', 'Asia', 'Atlantic', 'Australia','Brazil',
                             'Canada', 'Chile', 'Etc', 'Europe','Indian','Mexico','Mideast','Pacific','US']
          if @timezones_dirs.include?(file)
            load_zones(file)
          end
        else
          load_zone(file) unless /posix/.match(file)
        end
            
      }

      load_countries_and_zones
      end
    end

    # Adds new timezone to @zones
    def load_zone(file)
      if @zones[file].nil? 
        unless /\./.match(file)
          @zones[file] = TZDataZone.new(file) 

          # Loads all zone info at once, changed to use lazy loading for performance reasons
          # so it loads timezone but does not parse any binary file
          #instance = DataTimezone.new(ZoneinfoTimezoneInfo.new(file))
          instance = DataTimezone.new(TimezoneInfo.new(nil))
          
          TZInfo::Timezone.add(file, instance)
        end
      end                            
    end

    # Loads all timezone files from file names in the given directory and saves them in @zones
    def load_zones(directory)
      dir = Dir.new(@input_dir + File::SEPARATOR + directory)

      dir.each {|x|
        zone = directory + File::SEPARATOR + x

        if File.directory?(@input_dir + File::SEPARATOR + directory + File::SEPARATOR + x)
          load_zones(zone) unless /\./.match(zone)
        else
          load_zone(zone)
        end    
      }               
    end

    # Loads countries and timezones that go with them from iso3166.tab and zone.tab and stores the result in
    # @countries.
    def load_countries_and_zones
        
        IO.foreach(@input_dir + File::SEPARATOR + 'iso3166.tab') {|line|          
          if line =~ /^([A-Z]{2})\t(.*)$/
            code = $1
            name = $2
            @countries[code] = TZDataCountry.new(code, name)
          end
        }


        IO.foreach(@input_dir + File::SEPARATOR + 'zone.tab') {|line|          
          line.chomp!          

          if line =~ /^([A-Z]{2})\t([^\t]+)\t([^\t]+)(\t(.*))?$/
            code = $1
            location_str = $2
            zone_name = $3
            description = $5

            country = @countries[code]
            raise "Country not found: #{code}" if country.nil?
            
            location = TZDataLocation.new(location_str)
            
            zone = @zones[zone_name]   
            raise "Zone not found: #{zone_name}" if zone.nil?   

            description = nil if description == ''
            
            country.add_zone(TZDataCountryTimezone.new(zone, description, location))

            lo_n = location.longitude.to_s.gsub(/\/[0-9]*/, '')
            lo_d = location.longitude.to_s.gsub(/[0-9]*\//, '')
            la_n = location.latitude.to_s.gsub(/\/[0-9]*/, '')
            la_d = location.latitude.to_s.gsub(/[0-9]*\//, '')

            @timezones << [code, zone_name, lo_n, lo_d, la_n, la_d, description]
          end
        }

        # Creates CountryInfo for each country with all the associated timezones
        @countries.each do |code,country|
            # Creates CountryInfo for each country
            info = CountryInfo.new(code, country.name)

            # Adds timezones to CountryInfo for each country
            @timezones.each do |t|
              if code == t[0]
                info.timezone t[1], t[2], t[3], t[4], t[5], t[6]
              end
            end

            Country.add(code,Country.new(info))
        end

    end
  end
end