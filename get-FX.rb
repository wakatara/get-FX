#!/usr/bin/env ruby
require 'httparty'

@arguments = ARGV
@base_currency = "SGD"
# comma delimited string of currencies you want to track
@currencies = "CAD,USD,AUD,GBP,EUR,HKD"
# nb: make sure price.db is writable by your system (chmod ugo+w etc)
@price_db="/Users/daryl/Documents/Finances/price.db"

def get_exchange_rates_for_date(date)
  url = "https://api.fixer.io/#{date}?base=#{@base_currency}&symbols=#{@currencies}"
  response = HTTParty.get(url)
  exchange_rates = response.parsed_response
  record_in_prices_db(exchange_rates)
end

def record_in_prices_db(exchange_rates)
  File.open(@price_db, "a") do |f|
    f << "\n"
    f << "# Exchange rates for #{exchange_rates["date"]} via fixer.io\n"
    for rate in exchange_rates["rates"]
      f << "P "
      f << exchange_rates["date"] + " "
      f << exchange_rates["base"] + " "
      f << rate[0].to_s + " "
      f << rate[1].to_s + "\n"
    end
  end
end

def help_file
  print "get_currency_prices\n"
  print "\n"
  print "A Ledger utility for recording currencies in your prices db file.\n"
  print "\n"
  print "Usage:\n"
  print "  get_currency_prices\n"
  print "  get_currency_prices --from <iso date>\n"
  print "  get_currency_prices -h | --help\n"
  print "  get_currency_prices --version\n"
  print "\n"
  print "Options:\n"
  print "  <none>        Retrieves latest exchange rates and writes\n"
  print "                them to the specified price database\n"
  print "  --from        Retrieves exchange rates from date specified\n"
  print "                up until today and writes to specified price\n"
  print "                database\n"
  print "  -h --help     Show this screen.\n"
  print "  --version     Show version.\n"
end

if @arguments[0] == "--from"
  Date.parse(@arguments[1]).upto(Date.today) do |date|
    get_exchange_rates_for_date(date) if (!date.saturday? && !date.sunday?)
  end
elsif (@arguments[0] == "--help" || @arguments[0] == "-h")
  help_file
elsif (@arguments[0] == "--version")
  print "get_currency_prices version 0.1\n"
else
  date = Date.today
  get_exchange_rates_for_date("latest") if (!date.saturday? && !date.sunday?)
end
