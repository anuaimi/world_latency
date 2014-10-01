
# necessary when requiring fog without rubygems while also
# maintaining ruby 1.8.7 support (can't use require_relative)
__LIB_DIR__ = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift __LIB_DIR__ unless $LOAD_PATH.include?(__LIB_DIR__)

module WorldLatency

  require 'world_latency/cli'
  require 'world_latency/list'
  require 'world_latency/pinger'

  class Test
    def self.hi
      puts "Hello world!"
    end
  end

end

# define all continents & all countries
# filter =  
# d = WorldDatabase.new( filter)

# p = Pinger.new( source, list_of_sites)
# result, ping_times, ave_time = p.ping( site)
