require 'selenium-webdriver'

PRICE_RU_UA = '//*[@id="item-wherebuy-table"]/tbody/tr/td[3]/a'
SHOPS_RU_UA = '//td[4]/a/img'

PRICE_BY = '/html/body/div[1]/div/div/div/div/div/div[2]/div[1]/main/div/div/div[2]/div[2]/div[2]/div/div[2]/table/tbody/tr/td[1]/p/a/span'
SHOPS_BY = '/html/body/div[1]/div/div/div/div/div/div[2]/div[1]/main/div/div/div[2]/div[2]/div[2]/div/div[2]/table/tbody/tr/td[4]/div[1]/a[1]/img'


def fetch_shops_prices(browser_russia, browser_belarus, browser_ukraine)
  prices_local_russia = browser_russia.find_elements(:xpath, PRICE_RU_UA)
  shops_russia = browser_russia.find_elements(:xpath, SHOPS_RU_UA)

  prices_local_ukraine = browser_ukraine.find_elements(:xpath, PRICE_RU_UA)
  shops_ukraine = browser_ukraine.find_elements(:xpath, SHOPS_RU_UA)

  prices_local_belarus = browser_belarus.find_elements(:xpath, PRICE_BY)
  shops_belarus = browser_belarus.find_elements(:xpath, SHOPS_BY)

  shops_russia.map! { |shop| shop.attribute("alt") }
  shops_ukraine.map! { |shop| shop.attribute("alt") }
  shops_belarus.map! { |shop| shop.attribute("alt") }

  prices_russia_global = Array.new
  prices_belarus_global = Array.new
  prices_ukraine_global = Array.new

  oxr = Money::Bank::OpenExchangeRatesBank.new(Money::RatesStore::Memory.new)
  oxr.app_id = ENV['PARSER_APP_ID']
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
end
