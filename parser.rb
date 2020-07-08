require 'nokogiri'
require 'selenium-webdriver'
require 'httparty'
require 'money'
require 'eu_central_bank'
require 'money/bank/open_exchange_rates_bank'
require 'caxlsx'
require_relative 'helpers/browser.rb'
require_relative 'helpers/search.rb'
require_relative 'helpers/fetcher.rb'
require_relative 'helpers/xlsx.rb'

search_item = gets

Selenium::WebDriver::Chrome::Service.driver_path = ENV['PARSER_SELENIUM_PATH']

browser_russia = get_browser
browser_belarus = get_browser
browser_ukraine = get_browser

URL_RUSSIA = 'https://www.e-katalog.ru'
URL_BELARUS = 'https://catalog.onliner.by'
URL_UKRAINE = 'https://ek.ua'

browser_russia.get(URL_RUSSIA)
browser_belarus.get(URL_BELARUS)
browser_ukraine.get(URL_UKRAINE)

russia_good, belarus_good, ukraine_good = get_page(browser_russia, browser_belarus, browser_ukraine, search_item)

browser_russia.get(russia_good)
browser_belarus.get(belarus_good)
browser_ukraine.get(ukraine_good)

oxr = Money::Bank::OpenExchangeRatesBank.new(Money::RatesStore::Memory.new)
oxr.app_id = ENV['PARSER_APP_ID']
Money.default_bank = oxr
Money.locale_backend = nil

update_rates(oxr)
prices_local_russia, prices_russia_global, shops_russia = fetch_russia_ukraine(browser_russia, 'RUB')
prices_belarus_global, shops_belarus = fetch_belarus(browser_belarus)
prices_local_ukraine, prices_ukraine_global, shops_ukraine = fetch_russia_ukraine(browser_ukraine, 'UAH')

browser_russia.close
browser_belarus.close
browser_ukraine.close

country = ["RUS"] * shops_russia.length + ["UA"] * shops_ukraine.length + ["BLR"] * shops_belarus.length
local_prices = prices_local_russia + prices_local_ukraine
prices = prices_russia_global +  prices_ukraine_global + prices_belarus_global
shops = shops_russia + shops_ukraine + shops_belarus

export(country, shops, prices, local_prices, search_item)
