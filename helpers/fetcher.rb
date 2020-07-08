require 'selenium-webdriver'
require 'money'
require 'eu_central_bank'
require 'money/bank/open_exchange_rates_bank'

PRICE_RU_UA = '//*[@id="item-wherebuy-table"]/tbody/tr/td[3]/a'
SHOPS_RU_UA = '//td[4]/a/img'
COLOR_PRICE_RU_UA = '//*[@id="item-wherebuy-table"]/tbody/tr/td[4]/a'
COLOR_SHOPS_RU_UA = '//td[5]/a/img'

PRICE_BY = '/html/body/div[1]/div/div/div/div/div/div[2]/div[1]/main/div/div/div[2]/div[2]/div[2]/div/div[2]/table/tbody/tr/td[1]/p/a/span'
SHOPS_BY = '/html/body/div[1]/div/div/div/div/div/div[2]/div[1]/main/div/div/div[2]/div[2]/div[2]/div/div[2]/table/tbody/tr/td[4]/div[1]/a[1]/img'

def update_rates(oxr)
  oxr.update_rates
end

def fetch_russia_ukraine(browser, currency)
  prices_local = browser.find_elements(:xpath, PRICE_RU_UA)
  shops = browser.find_elements(:xpath, SHOPS_RU_UA)
  if shops.length.zero?
    prices_local = browser.find_elements(:xpath, COLOR_PRICE_RU_UA)
    shops = browser.find_elements(:xpath, COLOR_SHOPS_RU_UA)
  end
  shops.map! { |shop| shop.attribute("alt") }
  prices_global = Array.new

  rate = Money.default_bank.get_rate(currency, 'BYN').to_f
  prices_local.each do |price_local|
    price_value = price_local.text.match(/[0-9 ]+/).to_s.delete(' ').to_f
    prices_global.append((price_value * rate).round(2))
  end

  prices_local.map! { |price| price.text.strip }
  puts(shops)
  puts(prices_global)
  [prices_local, prices_global, shops]
end

def fetch_belarus(browser_belarus)
  prices_local_belarus = browser_belarus.find_elements(:xpath, PRICE_BY)
  shops_belarus = browser_belarus.find_elements(:xpath, SHOPS_BY)
  shops_belarus.map! { |shop| shop.attribute("alt") }
  prices_belarus_global = Array.new

  prices_local_belarus.each do |price_local|
    price_value = price_local.text.match(/[0-9 ,]+/).to_s.delete(' ').gsub!(',','.').to_f
    prices_belarus_global.append(price_value)
  end
  puts(shops_belarus)
  puts(prices_belarus_global)
  [prices_belarus_global, shops_belarus]
end