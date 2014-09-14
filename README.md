
World Latency 
-------------
Tool to calculate global latency from various countries around the world to a given server

Sometimes its handy to know how much slower your site/service is to users in various countries around the world.  Normally getting this data is very difficult as clients don't normally include latency data when they load your website or use your API.  Running this script on your server will very quickly and easily give you a data on the latency from common countries to your server.  This can be useful so that you can ensure that you are creating a UX that works everywhere around the world, not just to users close to your data center.  This can also be useful if you are looking to compare two or more data centers and see which is better for your key markets.  

###Testing Single Server / Location###

The latency tester is a ruby script that has a database of websites in various countries around the world.  It uses that database to do timings to each country.  To run it, all you need is to have [Ruby](https://www.ruby-lang.org/en/) (1.9 or higher) and [Curl](http://curl.haxx.se/) installed.  On most OSs, this should be very easy to do.

To get latency results for each country, run the following script on your server.

    # ruby global_latency.rb

This will output data for each of the countries in the database.

###Testing Multiple Data Centres###
If you have servers in multiple locations, one of the things you need to decide is which data centre each country should be directed to.  It's usually easy to know which server to direct users to if their country is close to a data centre.  But if they are equally between several data centres, it becomes much harder.  This tool will create empirical data that can be used to make sure they are directed to the data centre with the lowest latency.

First, when you run the latency test, you'll want to embed the server or data centre name in the results.  This can be done by using the `--source` command-line option.

    # ruby global_latency.rb --source ca-yyz.nuaimi.com

 run the script.  This will embed the name inside the JSON results and be used when the results are collated with the results from other servers.


    # ruby sort_by_country.rb 

###Country Database###
Right now the database only lists the top 50 (or so) countries by [number of Internet users](http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users).  If a country that you care about it not on the list, it can be added easily.  Also, if you have a problem with the URL for a country or just want to change it, that's also easy.

The master version of the database is in `data/country.json`.  Edit this file with the changes that you want.  If you want to varify that the URL you are adding is indeed in the country you think it is, you can use MaxMind's [database](https://www.maxmind.com/en/geoip_demo)

Once you have updated the country data file, you can run the latency test.  use the '-d' command line option to specify the database filename

    # ruby global_latency.rb -d './data/country.json'

If you think that others would benefit from your changes, please fork this project, make the changes and then send me a pull request.  Thanks in advance!

Note, by default, the ruby script includes a copy of the country database.  This was done so that the script was totally self-contained and would be easier to install on a large number of servers.  If you have updated the database and want to add it to the ruby script, you will need to convert it from JSON to a Ruby Hash and replace the COUNTRY_LIST constant at the top of the script.  Using irb, you can use the following snippet.

    > require 'json'; JSON.parse(File('./data/country.json'))

###Implementation Details###
The script works by doing 'reverse pings'.  That is it has a database of countries and an associated URL of a large website in that country.  The script pings each of the websites and records the time to do so. The ouput is in JSON so that is can easily be analyzed by another program. Since a lot of websites outside of North America and Europe block network pings, the script does a simple HTTP GET and measures the time to 1st byte.  This is not exactly comparable to a network ping but in my measurements, the times are very close. 

I went through some trial and error in setting up the country database. Initially, I thought the best sites to ping would be big local banks.  But it turns out in the developing world, many banks host their website in another country.  In the end, I settled on using ISPs.  Most ISPs probably host their own website so 

###Development Notes###
- tried to find sites in each country.  found that in the developing world, a lot of sites host in the US or use CloudFlare 
- tried using ping.  found a lot of sites in the developing world block ping. 
- moved to using curl and its ability to do timings.  found that they were very similar to ping times.  In the end, these are probably more representative of what we're trying to accomplish
- found that a lot of sites return a 301/302 when you request just the domain.  Since we don't want to include redirect times, needed to update the list with the actual URL.  This possibly makes the list a bit more brittle as these URLs may change.  In the future can create a small utility script to check all the sites and get the updated URL for the home page
- when I created the list of sites, I tried to find large sites that would probably want to be hosted in the local country.  This let me to use the central bank or a big local bank.  Issue with this is that many of them force SSL, which would change the timing.  
- realized that don't care if site is SSL or not.  Even if initial response is a 301 or a 302, our timings are accurate

