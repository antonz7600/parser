require 'nokogiri'
require 'selenium-webdriver'
require 'httparty'
require 'money'
require 'eu_central_bank'
require 'money/bank/open_exchange_rates_bank'
require 'caxlsx'

Selenium::WebDriver::Chrome::Service.driver_path = "C:/chromedriver.exe"
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--ignore-certificate-errors')
options.add_argument('--disable-popup-blocking')
options.add_argument('--disable-translate')
options.add_argument('--headless')
browser_russia = Selenium::WebDriver.for :chrome, options: options
browser_belarus = Selenium::WebDriver.for :chrome, options: options
browser_ukraine = Selenium::WebDriver.for :chrome, options: options

url_russia = 'https://www.e-katalog.ru/prices/lg-24mk430h/'
url_belarus = 'https://catalog.onliner.by/display/lg/24mk430hb/prices?town_id=17030'
url_ukraine = 'https://ek.ua/prices/lg-24mk430h/'

browser_russia.get(url_russia)
browser_belarus.get(url_belarus)
browser_ukraine.get(url_ukraine)

sleep(4)
prices_local_russia = browser_russia.find_elements(:xpath, '//*[@id="item-wherebuy-table"]/tbody/tr/td[3]/a')
shops_russia = browser_russia.find_elements(:xpath, '/html/body/div[5]/table/tbody/tr/td[1]/div[7]/div[1]/table[2]/tbody/tr/td[4]/a/img')

prices_local_ukraine = browser_ukraine.find_elements(:xpath, '/html/body/div[5]/table/tbody/tr/td[1]/div[7]/div[1]/table[2]/tbody/tr/td[3]/a')
shops_ukraine = browser_ukraine.find_elements(:xpath, '/html/body/div[5]/table/tbody/tr/td[1]/div[7]/div[1]/table[2]/tbody/tr/td[4]/a/img')

prices_local_belarus = browser_belarus.find_elements(:xpath, '/html/body/div[1]/div/div/div/div/div/div[2]/div[1]/main/div/div/div[2]/div[2]/div[2]/div/div[2]/table/tbody/tr/td[1]/p/a/span')
shops_belarus = browser_belarus.find_elements(:xpath, '/html/body/div[1]/div/div/div/div/div/div[2]/div[1]/main/div/div/div[2]/div[2]/div[2]/div/div[2]/table/tbody/tr/td[4]/div[1]/a[1]/img')

shops_russia.map! { |shop| shop.attribute("alt") }
shops_ukraine.map! { |shop| shop.attribute("alt") }
shops_belarus.map! { |shop| shop.attribute("alt") }

prices_russia_global = Array.new
prices_belarus_global = Array.new
prices_ukraine_global = Array.new

oxr = Money::Bank::OpenExchangeRatesBank.new(Money::RatesStore::Memory.new)
oxr.app_id = 'f2ad01ea0b01477ea0aee43b49725074'
oxr.update_rates
Money.default_bank = oxr
Money.locale_backend = nil

rate = Money.default_bank.get_rate('RUB', 'BYN').to_f
prices_local_russia.each do |price_local|
  price_value = price_local.text.match(/[0-9 ]+/).to_s.delete(' ').to_f
  prices_russia_global.append((price_value * rate).round(2))
end

rate = Money.default_bank.get_rate('UAH', 'BYN').to_f
prices_local_ukraine.each do |price_local|
  price_value = price_local.text.match(/[0-9 ]+/).to_s.delete(' ').to_f
  prices_ukraine_global.append((price_value * rate).round(2))
end

prices_local_belarus.each do |price_local|
  price_value = price_local.text.match(/[0-9 ,]+/).to_s.delete(' ').gsub!(',','.').to_f
  prices_belarus_global.append(price_value)
end

prices_local_russia.map! { |price| price.text.strip }
prices_local_ukraine.map! { |price| price.text.strip }

country = ["RUS"] * shops_russia.length + ["UA"] * shops_ukraine.length + ["BLR"] * shops_belarus.length
local_prices = prices_local_russia + prices_local_ukraine
prices = prices_russia_global +  prices_ukraine_global + prices_belarus_global
shops = shops_russia + shops_ukraine + shops_belarus

Axlsx::Package.new do |p|
  p.workbook.add_worksheet(:name => "#{browser_belarus.title.to_s.split('Цены')[0]}") do |sheet|
    sheet.add_row ["Country", "Shop", "Price(BYN)  ", "Local price"]
    (0..prices.length-1).each do |i|
      sheet.add_row [country[i].to_s, shops[i].to_s, prices[i].to_s, local_prices[i].to_s]
    end
  end
  p.serialize('prices.xlsx')
end

browser_russia.close
browser_belarus.close
browser_ukraine.close