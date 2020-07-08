require 'selenium-webdriver'

def get_browser
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--disable-popup-blocking')
  options.add_argument('--disable-translate')
  # options.add_argument('--headless')
  options.add_argument('log-level=3')
  Selenium::WebDriver.for :chrome, options: options
end
