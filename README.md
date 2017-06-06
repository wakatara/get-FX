# Get FX - An exchange rates price DB utility for Ledger-CLI

## What It Is

Get FX is a simple, robust, easily understandable ruby script utility for use with the [Ledger CLI accounting program](http://ledger-cli.org) with one small gem dependency for getting exchange rates into the price database for Ledger.

## Why It Is

Asking in the very helpful irc channel `#ledger`, every pointer I had to stocking the price database fx-wise either didn't work, or was overly complex (and didn't work), so I rolled up my sleeves and spent an hour bashing out a simple, understandable script I figured anyone could use (and modify easily.).

I started using Ledger-CLI to handle my consulting and personal accounting finances after getting tired of over-complicated accounting desktop and SaaS programs and, in particular, the fact that their data files were neither easily portable, nor exportable, nor future proof. It's hard to beat text for portability and ubiquity.

## What It Does

It runs out and populates your price database with foreign exchange rates by day in the format the price db in Ledger expects.

Get FX is triggered from the command line (and is `cron`-friendly).

If no arguments are provided, it queries the FX exchange service [fixer.io](http://fixer.io) for the specified base currency and currencies (in later version I'll make these both arguments) and then writes those results into the specified Ledger price database in the required format.

If you provide a `--from <date>` argument, it will gather all the exchange rates for every day specified in the from argument (weekdays only, since exchanges are closed weekends) and write those up to the present day in the price database.

Ledger price database information gets written like this to the file with a separating space at head and tail of the block of lines and comment.

```
# Exchange rates for 2017-06-05 via fixer.io
P 2017-06-05 SGD AUD 0.96776
P 2017-06-05 SGD CAD 0.97639
P 2017-06-05 SGD GBP 0.56065
P 2017-06-05 SGD HKD 5.64
P 2017-06-05 SGD USD 0.72383
P 2017-06-05 SGD EUR 0.64346
```

The script is append-only to the end of the current price database and does not examine its contents to see if it's creating duplicates or conflicting entries. If you automate this with cron though, you'll rarely have to worry about it except perhaps dealing with some sort of failure on any particular day and needing to go back and get rates.

## Constraints

The script uses ISO standards, because... *standards*, so currencies are represented in their 3-letter ISO format which assumes you are tracking them that way in your Ledger file (ie. USD, GBP, CAD, EUR, SGP, HKD etc and not as symbols like "$", "¥", or "£"). Also, it expects and uses the ISO yyyy-mm-dd standard used internationally (though not in 'Murika.).

Exchange rates are pulled from flipper.io which updates once a day with market close, so this may not be a good solution if you are fx trading or similar. This is more for people who just need to understand their accounts in response to exchange rate fluctuations over time.

## Installation and Configuration

For this first release, there is still a teensy bit of manual configuration until I automate this as a homebrew formula or gem in its own right. Installation and the tiny bit of configuration are trivial though, so here's the walkthrough.

### Dependencies

There is one dependency: `HTTParty` which parses the json response from the fx exchange server. So, you need to install it or `get-FX` will throw an error when run. It's simple though especially if you're already doing anything ruby-esque.

```
🚀  gem install httparty
```  

Voila. Done. Painless, right?

### Configuring

Take the script and put it in your preferred location that you will trigger by the full path to it or that's in your executables path. Make sure you make the script executable by you with a `chmod u+x /path/to/get-FX` if it isn't (also, make sure that the price database is writable by others ie `chmod ugo+w /path/to/price.db`).

There are 3 options within the script you need to edit via text editor:

1. `@base_currency` is a string of the currency you keep your books in (or you preferred one). generally this is going to be the 3 letter currency code for your country.
2. `@currencies` is a comma-separated string of the currencies you want to get exchange rates for, relative to the base currency.
3. `@price_db` is the full path string to the location of your ledger price database. Make sure this is writable by the system or the script will throw an error and the script will not write to the price.db

Here's an actual example from what I use as I need to deal with all these separate currencies due to customers or expenses in various countries.

```
@base_currency = "SGD"
# comma delimited string of currencies you want to track
@currencies = "CAD,USD,AUD,GBP,EUR,HKD"
# nb: make sure price.db is writable by your system (chmod ugo+w etc)
@price_db="/Users/daryl/Documents/Finances/price.db"
```

That's all there is to it. You are now ready to trigger the script at any time. You can either do this manually or read on for doing that with `cron`.

## Triggering daily via cron

If your system has a way of executing tasks on a scheduled basis, you can simply call the the script at a regular time every day.

Unfortunately, on OSX, Apple replaced the venerable (and easily understandable) `cron` utility with the impenetrable launchd configuration files. It takes a teensy amount of work, but you can read on my blog here[how to re-enable cron in your osx system](https://daryl.wakatara.com/enabling-cron-in-osx-10-10-yosemite) (it works for any OSX 10.9 or higher and is currently running on my Sierra laptop no problem) to easily set this up for daily updates to your price database file.

Then this is a simple matter of creating a daily cron job at the same time every day (make sure you pick a time when your computer will be on all the time. Cron does not retry missed jobs.).

Then simply `crontab -e` to create a new entry and put something like this in:

```
05 18 * * 1,2,3,4,5 /path/to/get-FX.rb
```

Which will trigger `get-FX` every weekday at 5 minutes after 6 to grab the exchange rates you've specified.


## ToDo

* There are currently no tests and errors are not recovered from gracefully
* Script requires some hand editing for base, currencies, and file path - I would like these to be parsed args on the command for future versions (just like ledger! :stuck_out_tongue_winking_eye: )
* Installable via brew or gem so it's effortless for people to install and get started using it with ledger
* Thinking it would be nice if a check command checked the file for missing days and then inserted those into the proper place for you

## Contributing

This meets my current needs to I'll only be inching it forward when I have time (and I aim to keep it as simple as possible), so any help, suggestions or additions welcome. In particular, happy to accept Pull Requests if you wanted to add some easy functionality to this.
