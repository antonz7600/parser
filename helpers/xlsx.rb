# frozen_string_literal: true

require 'caxlsx'

def export(country, shops, prices, local_prices, search_item)
  Axlsx::Package.new do |p|
    p.workbook.add_worksheet(name: search_item.to_s) do |sheet|
      sheet.add_row ['Country', 'Shop', 'Price(BYN)  ', 'Local price']
      (0..prices.length - 1).each do |i|
        sheet.add_row [country[i].to_s, shops[i].to_s, prices[i].to_s, local_prices[i].to_s]
      end
    end
    p.serialize('prices.xlsx')
  end
  puts('Successfully exported to prices.xlsx')
end
