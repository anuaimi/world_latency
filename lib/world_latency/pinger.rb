require 'optparse'
require 'open3'
require 'json'

# from country_list.json
# FOR TESTING ONLY
COUNTRY_LIST = {"Africa"=>[["EG", "Egypt", "www.nbe.com.eg"], ["KE", "Kenya", "www.centralbank.go.ke"], ["MA", "Morocco", "www.bkam.ma"], ["NG", "Nigeria", "mtnbusiness.com.ng"], ["ZA", "South Africa", "www.resbank.co.za"]], "Asia"=>[["CN", "China", "www.boc.cn"], ["HK", "Hong Kong", "www.hkma.gov.hk"], ["IN", "India", "www.sbi.co.in"], ["ID", "Indonesia", "www.bni.co.id"], ["IL", "Israel", "www.bankisrael.gov.il"], ["JP", "Japan", "www.mizuhobank.com"], ["KR", "Korea", "www.kdb.co.kr"], ["KW", "Kuwait", "www.qualitynet.net"], ["MY", "Malaysia", "www.bnm.gov.my"], ["OM", "Oman", "www.omantel.net.om"], ["PK", "Pakistan", "www.sbp.org.pk"], ["PH", "Philippines", "www.bdo.com.phe"], ["QA", "Qatar", "www.ooredoo.com"], ["RU", "Russia", "www.sberbank.ru"], ["SA", "Saudi Arabia", "www.sama.gov.sa"], ["SG", "Singapore", "www.mas.gov.sg"], ["TH", "Thailand", "www.bot.or.th"], ["TR", "Turkey", "www.ziraat.com.tr"], ["TW", "Taiwan", "www.cbc.gov.tw"], ["AE", "United Arab Emirates", "www.centralbank.ae"], ["VN", "Vietnam", "www.sbv.gov.vn"]], "Europe"=>[["AT", "Austria", "www.oenb.at"], ["BE", "Belgium", "www.nbb.be"], ["CZ", "Czech Republic", "www.cnb.cz"], ["DK", "Denmark", "www.nationalbanken.dk"], ["FI", "Finland", "www.suomenpankki.fi"], ["DE", "Germany", "www.commerzbank.com"], ["GR", "Greece", "www.bankofgreece.gr"], ["FR", "France", "www.bnpparibas.com"], ["HU", "Hungary", "english.mnb.hu"], ["IT", "Italy", "www.unicreditgroup.eu"], ["NL", "Netherlands", "www.abnamro.nl"], ["NO", "Norway", "www.norges-bank.no"], ["PL", "Poland", "www.nbp.pl"], ["PT", "Portugal", "www.bportugal.pt"], ["RO", "Romania", "www.bnro.ro"], ["ES", "Spain", "www.bde.es"], ["SE", "Sweden", "www.handelsbanken.se"], ["CH", "Switzerland", "www.snb.ch"], ["UA", "Ukraine", "bank.gov.ua"], ["GB", "United Kingdom", "www.barclays.co.uk"]], "North America"=>[["CA", "Canada", "www.ctv.ca"], ["MX", "Mexico", "www.bancomer.com"], ["US", "United States", "www.jpmorganchase.com"]], "Oceania"=>[["AU", "Australia", "www.rba.gov.au"], ["NZ", "New Zealand", "www.rbnz.govt.nz"]], "South America"=>[["AR", "Argentina", "www.bna.com.ar"], ["BR", "Brazil", "www.bancobrasil.com.br"], ["CL", "Chile", "www.santander.cl"], ["CO", "Colombia", "www.grupobancolombia.com"], ["PE", "Peru", "www.viabcp.com"]]}


module WorldLatency

  # will ping all countries and return results
  class Pinger
    
    def initialize( source = 'localhost', database = nil)
      @source = source
      if database
        # load database from file
        file_data = File.read(database)
        @country_list = JSON.parse(file_data)
      else
        # use built-in list
        @country_list = COUNTRY_LIST
      end
    end

    def continent_list
      list = []
      @country_list.each { |continent|
        name = continent.first
        list << name
      }

      return list
    end

    def country_list
      list = []
      continents = continent_list

    end

    # get latency for each country
    def ping
      results = {}
      @country_list.each { |continent|
        name = continent[0]
        countries = continent[1]
        countries.each {|country|
          # ping site for country
          pinger = Pinger.new
          result, ping_times, avg_time = pinger.ping(country[2])
          # puts "#{country[1]} - #{country[2]} #{result} %.1f" % (avg_time * 1000)
          # round results to 4 deciment places
          results[country[0]] = (avg_time * 10000).round / 10000.0
        }

      }

      return true, results
    end

  end


  # ping a given host
  class Pinger
    
    NUM_PINGS = 2     # how many pings to do on a site

    def initialize
      @results = {}
    end

    def run_command( cmd)
      success = false
      output = ''

      Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
        case thread.value.exitstatus
          when 0
            success = true
            output = stdout.read
          when 2
            success = false # Transmission successful, no response.
          else
            success = false
        end
      end

      return success, output
    end

    # get time to desired site
    def ping( host = 'www.google.com')
        
      ping_times = []
      min_time, avg_time, max_time = 0

      # run ping executable
      ping_count = 0
      success = true
      while success and ping_count < NUM_PINGS 

        cmd = 'curl  -w "%{http_code} %{time_namelookup} %{time_connect}\n"  -o /dev/null -s http://' + host
        success, output = run_command( cmd)
        if success
          http_code, dns_lookup, latency = parse_results(output)
          ping_times << latency
          ping_count += 1
        else
          # site down??
          break
        end
      end

      if success == false
        return false, [], 0
      end

      # calc average
      total_time = 0
      ping_times.each {|time|
        total_time += time
      }
      avg_time = total_time / ping_times.count

      return true, ping_times, avg_time
    end

    # parse output of ping command
    def parse_results( results)

      # remove any /r/n from string
      # "200 0.194 0.349\n"
      results.chomp!

      # split into individual fields
      fields = results.split(' ')

      # was request successful
      http_code = fields[0].to_i
      if (http_code == 200) or (http_code == 301) or (http_code == 302) or (http_code == 303)
        dns_lookup = fields[1].to_f
        latency = fields[2].to_f - dns_lookup
        return http_code, dns_lookup, latency
      else
        return http_code, 0, 0
      end
    end

  end  
end
