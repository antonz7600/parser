require 'selenium-webdriver'

RU_UA_PAGE = '//*[@id="ek-search"]'
RU_UA_PRICE = '//div[5]/div/a/span'

BY_PAGE = '//input'
BY_PRICE = '/html/body/div[1]/div[2]/ul/li[1]/div/div/div[1]/div/a'
BY_FRAME = '/html/body/div[3]/div/div/iframe'

def get_page(browser_russia, browser_belarus, browser_ukraine, value)
  begin
    browser_russia.find_element(:xpath, RU_UA_PAGE).send_keys(value)
    browser_belarus.find_element(:xpath, BY_PAGE).send_keys(value)
    browser_ukraine.find_element(:xpath, RU_UA_PAGE).send_keys(value)
  rescue
    abort("Failed to connect to sites, try again...")
  end
  get_price_list(browser_russia, browser_belarus, browser_ukraine)
end

def get_price_list(browser_russia, browser_belarus, browser_ukraine)
  begin
    browser_russia.find_element(:xpath, RU_UA_PRICE).click
    browser_belarus.switch_to.frame browser_belarus.find_element(:xpath, BY_FRAME)
    browser_belarus.find_element(:xpath, BY_PRICE).click
    browser_ukraine.find_element(:xpath, RU_UA_PRICE).click
  rescue
    abort("Failed to find items, please, try again...")
  end
  [browser_russia.current_url, browser_belarus.current_url, browser_ukraine.current_url]
end
