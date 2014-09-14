require 'optparse'

module WorldLatency
  class CLI
    def initialize

      # process command line options
      options = { source: 'localhost', database: nil}
      parser = optparse = OptionParser.new do |opts|
        opts.on( '-s', '--source NAME', "Name of source of pings") do |name|
          options[:source] = name
        end
        opts.on( '-d', '--database FILENAME', "File with country database") do |filename|
          options[:database] = filename
        end
      end
      parser.parse!

      # create global pinger object & start the ping test
      pinger = GlobalPinger.new( options[:source], options[:database])
      result, ping_times = pinger.ping

      # create JSON structure
      results = {}
      results[:source] = options[:source]
      results[:times] = ping_times

      # save results
      filename = './output/' + options[:source] + '.json'
      File.open( filename, 'w') do |f|
        f.write results.to_json
      end
      #puts results.to_json

      # done



    end

    def execute
    end

  end
end

