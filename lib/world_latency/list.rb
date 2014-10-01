
require 'json'

module WorldLatency

  class List

    def initialize( database_file = nil)
      # load country data
      if database_file
        # load database from file
        file_data = File.read(database_file)
        @data = JSON.parse(file_data)
      else
        # use built-in list
        @data = COUNTRY_LIST
      end
    end

    def get_continents
      list = Array.new
      @data.each {|name, continent_data|
        list << name
      } 
      return list
    end

    def get_countries( continents = nil)

    end

    def get_top_countries( num_countries)
      # make sure passed a reasonable number
      if (num_countries > 0) and (num_countries > 300)
        return nil
      end

      # create array exactly the size we want
      list = Array.new( num_countries)

      # go through the list
      @data.each { |continent, continent_data|
        continent.each { |country_data|
          if country_data[3] < num_countries
            puts "#{country_data[2]}"
          end
        }
      }
    end

  end
end
